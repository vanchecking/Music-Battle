import UIKit
import AVFoundation
import MusicKit

final class AppCoordinator {
    private let window: UIWindow
    private let navigationController = UINavigationController()

    private let authService: AppleAuthenticationService
    private let diskImageLoader: DiskImageLoader

    private var splashCoordinator: SplashCoordinator?
    private var loginCoordinator: LoginCoordinator?
    private var homeCoordinator: HomeCoordinator?
    private var battleModeCoordinator: BattleModeCoordinator?
    private var battleProcessCoordinator: BattleProcessCoordinator?
    private var battleResultCoordinator: BattleResultCoordinator?
    private var battleHistoryCoordinator: BattleHistoryCoordinator?
    private var settingsCoordinator: SettingsCoordinator?

    static func factory(window: UIWindow) -> AppCoordinator {
        return AppCoordinator(
            window: window,
            diskImageLoader: DiskImageLoader(),
            authService: AppleAuthenticationService())
    }

    private init(window: UIWindow,
                 diskImageLoader: DiskImageLoader,
                 authService: AppleAuthenticationService) {
        self.window = window
        self.authService = authService
        self.diskImageLoader = diskImageLoader
    }

    func start() {
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        if AuthStorage.shared.isLoggedIn {
            showHome()
        } else {
            showSplash()
        }
    }
    
    private func showPaywall() {
        clearCoordinators()
        AnalyticsService.shared.track(.paywallShown(source: "app_coordinator"))
        let paywall = PaywallViewController(viewModel: .init(service: SubscriptionService.shared))
        navigationController.setViewControllers([paywall], animated: false)
    }

    private func showSplash() {
        clearCoordinators()
        let splash = SplashCoordinator(navigationController: navigationController)
        splash.delegate = self
        splashCoordinator = splash
        splash.start()
    }

    func showBattleResult(score: BattleScore, player: AVPlayer) {
        clearCoordinators()
        let coordinator = BattleResultCoordinator(
            navigationController: navigationController,
            appCoordinator: self,
            battleScore: score,
            player: player)
        battleResultCoordinator = coordinator
        coordinator.start()
    }

    func showBattleProcess(tracks: [Track]) {
        clearCoordinators()
        let coordinator = BattleProcessCoordinator(
            navigationController: navigationController,
            appCoordinator: self,
            tracks: tracks)
        battleProcessCoordinator = coordinator
        coordinator.start()
    }
    func showHome() {
        clearCoordinators()

        let home = HomeCoordinator(
            navigationController: navigationController,
            appCoordinator: self)

        homeCoordinator = home
        home.start()
    }

    func showSettings() {
        let coordinator = SettingsCoordinator(
            navigationController: navigationController,
            appCoordinator: self)
        settingsCoordinator = coordinator
        coordinator.start()
    }

    func showBattleHistory() {
        let coordinator = BattleHistoryCoordinator(
            navigationController: navigationController,
            appCoordinator: self)
        battleHistoryCoordinator = coordinator
        coordinator.start()
    }

    func showBattleMode() {
        clearCoordinators()
        let coordinator = BattleModeCoordinator(
            navigationController: navigationController,
            appCoordinator: self)
        battleModeCoordinator = coordinator
        coordinator.start()
    }

    // Clear other coordinators
    func showLoginWithTransition() {
        clearCoordinators()
        let coordinator = LoginCoordinator(navigationController: navigationController,
                                           appCoordinator: self,
                                           authService: self.authService,
                                           diskImageLoader: self.diskImageLoader)
        loginCoordinator = coordinator
        coordinator.showLoginWithTransition()
    }

    private func clearCoordinators() {
        splashCoordinator = nil
        loginCoordinator = nil
        homeCoordinator = nil
        battleModeCoordinator = nil
        battleProcessCoordinator = nil
        battleResultCoordinator = nil
        battleHistoryCoordinator = nil
        settingsCoordinator = nil
    }

}

extension AppCoordinator: SplashCoordinatorDelegate {

    func splashDidFinish() {
        showLoginWithTransition()
    }
}
