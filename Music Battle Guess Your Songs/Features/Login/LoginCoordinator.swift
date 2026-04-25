//
//  LoginCoordinator.swift
//  Music Battle Guess Your Songs
//
//  Created by PowerMac on 01.03.2026.
//
import UIKit

/// 🚦 Coordinates the login flow and handles navigation to the login screen.
final class LoginCoordinator {

    private let navigationController: UINavigationController
    private let appCoordinator: AppCoordinator
    private let authService: AppleAuthenticationService
    private let diskImageLoader: DiskImageLoader

    /// 🔧 Initializes the coordinator with required dependencies.
    /// - Parameters:
    ///   - navigationController: The navigation controller to manage view controllers.
    ///   - appCoordinator: The main app coordinator for navigation after login.
    ///   - authService: Service handling authentication.
    ///   - diskImageLoader: Loader for cached images.
    init(navigationController: UINavigationController,
         appCoordinator: AppCoordinator,
         authService: AppleAuthenticationService,
         diskImageLoader: DiskImageLoader) {
        self.navigationController = navigationController
        self.appCoordinator = appCoordinator
        self.authService = authService
        self.diskImageLoader = diskImageLoader
    }

    /// 🔑 Creates and configures the login view controller with its view model.
    /// - Returns: A configured `LoginViewController` instance.
    private func makeLoginModule() -> LoginViewController {
        let viewModel = LoginViewModel(
            authService: self.authService,
            diskImageLoader: self.diskImageLoader
        )

        let loginVC = LoginViewController(viewModel: viewModel)

        loginVC.viewModel.onLoginSuccess = { [weak self] in
            self?.appCoordinator.showHome()
        }

        return loginVC
    }

    /// 🔄 Shows the login screen with a smooth cross dissolve transition.
    func showLoginWithTransition() {
        let loginVC = makeLoginModule()

        navigationController.setViewControllers([loginVC], animated: false)

        UIView.transition(
            with: navigationController.view,
            duration: 0.35,
            options: .transitionCrossDissolve,
            animations: nil
        )
    }
}
