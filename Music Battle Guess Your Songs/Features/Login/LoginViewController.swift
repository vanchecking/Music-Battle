import UIKit
import AuthenticationServices

/// Handles user login UI and interactions.
final class LoginViewController: UIViewController {

    let viewModel: LoginViewModel
    private let contentView = LoginView()

    /// Initializes with a given view model.
    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func loadView() { view = contentView }

    /// Sets up the view, applies remote config, and starts loading artists and MusicKit authorization.
    override func viewDidLoad() {
        super.viewDidLoad()
        applyRemoteConfig()

        bindAppleButton()
        loadAndShowAnimatedArtists()

        RemoteConfigService.shared.fetch { [weak self] updated in
            guard updated else { return }
            DispatchQueue.main.async {
                self?.applyRemoteConfig()
            }
        }
        requestMusicKit()
    }

    private func bindAppleButton() {
        contentView.onAppleTap = { [weak self] in
            self?.didTapAppleSignIn()
        }
    }

    /// Requests MusicKit authorization asynchronously and preloads MusicKit.
    private func requestMusicKit() {
        Task {
            do {
                try await MusicService.shared.requestAuthorization()
                MusicService.shared.preloadMusicKit()
            } catch {
                ErrorHandler.shared.handle(error)
            }
        }
    }

    /// Updates UI texts and visibility based on remote config.
    private func applyRemoteConfig() {
        let rc = RemoteConfigService.shared
        contentView.updateTexts(
            title: rc.loginTitle,
            subtitle: rc.loginSubtitle,
            integrationsText: rc.loginIntegrationsText,
            showIntegrations: rc.loginShowIntegrations,
            showArtistsCarousel: rc.loginShowArtistsCarousel
        )
    }

    /// Loads artists asynchronously and displays them with animation. Shows mock artists on failure.
    private func loadAndShowAnimatedArtists() {
        Task { [weak self] in
            guard let self else { return }
            do {
                let result = try await viewModel.loadArtists()
                Logger.log("Artists Loaded ✅")

                self.contentView.showAnimated(result)

            } catch {
                Logger.log("Failed to load artists: \(error)")

                self.contentView.showAnimated(PlaceholderArtists.topTwelve(remoteURLs: RemoteConfigService.shared.loginArtistImageURLs))
            }
        }
    }

    /// Triggered when Apple Sign-In button is tapped; starts sign-in process asynchronously.
    @objc private func didTapAppleSignIn() {
        Task {
            AnalyticsService.shared.track(.loginStarted)
            await viewModel.signInWithApple()
        }
    }

    deinit {
        Logger.log("Deinit")
    }
}
