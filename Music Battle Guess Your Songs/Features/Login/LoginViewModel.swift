import Foundation
import Combine
import UIKit

// MARK: - error types for screens
enum LoginError: Error, Identifiable {
    var id: String { localizedDescription }
    case network
    case appleSignInFailed(String)
    var localizedDescription: String {
        switch self {
        case .network:
            return "Check your internet 🥺"
        case .appleSignInFailed(let msg):
            return msg
        }
    }
}

// MARK: - LoginViewModel
final class LoginViewModel {
    // MARK: - Dependencies
    private let authService: AuthenticationServiceProtocol
    private let diskImageLoader: ImageLoaderProtocol
    var onLoginSuccess: (() -> Void)?

    // MARK: - Outputs
    @Published var isLoading: Bool = false
    @Published var user: AppleUser?
    @Published var loginError: LoginError?

    // MARK: - Supported music genres for user preferences or display
    let genres = [
        "rock",
        "pop",
        "hip-hop",
        "jazz",
        "electronic",
        "latin",
        "latin",
        "classical",
        "metal",
        "r&b",
        "indie",
        "country",
        "dance"
    ]

    // MARK: - Init
    init(authService: AuthenticationServiceProtocol, diskImageLoader: ImageLoaderProtocol) {
        self.authService = authService
        self.diskImageLoader = diskImageLoader
    }

    /// Loads an image asynchronously for a given artist.
    /// - Parameter artist: The artist whose image should be loaded.
    /// - Returns: The loaded UIImage, or a placeholder if the URL is missing.
    /// This method uses async/await to load images off the main thread.
    /// Note: Caching images on disk or persisting copyrighted content is not allowed;
    /// only in-memory caching is permitted to respect copyright restrictions.
    func loadImage(for artist: ArtistImage) async throws -> UIImage {
        guard let url = artist.url else {
            // Return a placeholder image if no URL is available
            return UIImage(named: artist.assetPlaceholder) ?? UIImage(systemName: "photo")!
        }
        // Load image asynchronously from disk or network
        return try await diskImageLoader.loadImage(from: url)
    }

    // MARK: - Actions

    /// Initiates sign-in with Apple asynchronously.
    /// Updates UI state properties and handles errors.
    /// On success, creates or fetches a user profile and triggers success callback on main thread.
    func signInWithApple() async {
        isLoading = true
        loginError = nil

        do {
            let appleUser = try await authService.signInWithApple()
            self.user = appleUser
            await createUser(from: appleUser)  // call the async version
        } catch {
            // Update error state on main thread and log error
            await MainActor.run {
                self.loginError = .appleSignInFailed(error.localizedDescription)
            }
            ErrorHandler.shared.handle(error)
        }

        // Reset loading state on the main thread
        await MainActor.run {
            self.isLoading = false
        }
    }

    /// Creates or fetches a user profile asynchronously from CloudKit.
    /// Saves user ID locally and triggers login success callback on main thread.
    /// - Parameter appleUser: The Apple user info used to create or fetch profile.
    private func createUser(from appleUser: AppleUser) async {
            do {
                let profile = try await CloudKitService.shared
                    .fetchOrCreateUserProfile(
                        userID: appleUser.userId,
                        email: appleUser.email,
                        nickname: appleUser.fullName ?? "Player"
                    )
                Logger.log("User ready: \(profile)")
                AuthStorage.shared.saveUserID(appleUser.userId)
                
                let isNewUser = profile.totalBattles == 0

                let event: AnalyticsEvent = isNewUser
                            ? .signUpCompleted(method: "apple")
                            : .loginCompleted(method: "apple")
                
                AnalyticsService.shared.track(event)

                // Notify success on the main thread to update UI safely
                await MainActor.run {
                    self.onLoginSuccess?()
                }
            } catch {
                ErrorHandler.shared.handle(error)
            }
    }

    /// Loads a list of artists with their images asynchronously.
    /// Uses a throwing task group to parallelize image loading.
    /// - Returns: An array of ArtistImage objects with loaded images.
    func loadArtists() async throws -> [ArtistImage] {
        let artists = PlaceholderArtists.topTwelve(remoteURLs: RemoteConfigService.shared.loginArtistImageURLs)
        Logger.log(
            artists
                .compactMap { $0.url?.absoluteString }
                .joined(separator: " ")
        )

        // Use a task group to load images in parallel
        return try await withThrowingTaskGroup(of: (Int, ArtistImage).self) { group in
            for (index, artist) in artists.enumerated() {
                group.addTask {
                    let image = try await self.loadImage(for: artist)
                    var updated = artist
                    updated.loadedImage = image
                    return (index, updated)
                }
            }
            var temp: [(Int, ArtistImage)] = []
            for try await value in group {
                temp.append(value)
            }
            // Sort results by original order and return updated artists
            return temp
                .sorted { $0.0 < $1.0 }
                .map { $0.1 }
        }
    }
}
