import UIKit

final class SettingsCoordinator {

    private let navigationController: UINavigationController
    private let appCoordinator: AppCoordinator

    init(navigationController: UINavigationController,
         appCoordinator: AppCoordinator) {
        self.navigationController = navigationController
        self.appCoordinator = appCoordinator
    }

    func start() {
        let settingsVC = PaywallViewController(viewModel: .init(service: SubscriptionService.shared))

        navigationController.pushViewController(settingsVC, animated: false)
        UIView.transition(
            with: navigationController.view,
            duration: 0.35,
            options: .transitionCrossDissolve,
            animations: nil
        )
    }
}
