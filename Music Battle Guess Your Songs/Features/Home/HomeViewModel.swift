import Foundation

final class HomeViewModel {

    // MARK: - Output

    var onStateChange: ((HomeViewState) -> Void)?
    var onLogoutSuccess: (() -> Void)?
    var onBattleModeTapped: (() -> Void)?
    var onBattleHistoryTapped: (() -> Void)?
    var onSettingsTapped: (() -> Void)?

    // MARK: - Private

    private var profile: UserProfile?

    // MARK: - Public

    func loadProfile() {
        onStateChange?(.loading)

        Task {
            await fetchProfile()
        }
    }

    // MARK: - Private
    private func fetchProfile() async {
        guard let userID = AuthStorage.shared.appleUserID else {
            onStateChange?(.error("User not found"))
            return
        }

        do {
            let profile = try await CloudKitService.shared.fetchUserProfile(userID: userID)
            self.profile = profile

            await MainActor.run {
                sendState()
            }
        } catch {
            ErrorHandler.shared.handle(error)
        }
    }

    private func sendState() {
        guard let profile else { return }

        let content = HomeViewState.Content(
            nickname: profile.nickname,
            rating: profile.rating,
            wins: profile.totalWins,
            battles: profile.totalBattles,
            coins: profile.wallet.coins,
            gems: profile.wallet.gems
        )

        onStateChange?(.content(content))
    }

    func logout() {
        AnalyticsService.shared.track(.logoutCompleted)
        AnalyticsService.shared.reset()
        AuthStorage.shared.logoutUser()
        onLogoutSuccess?()
    }

    func toBattleMode() {
        onBattleModeTapped?()
    }
}
