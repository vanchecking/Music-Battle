//
//  SplashCoordinatorDelegate.swift
//  Music Battle Guess Your Songs
//
//  Created by PowerMac on 01.03.2026.
//
import UIKit

protocol SplashCoordinatorDelegate: AnyObject {
    func splashDidFinish()
}

final class SplashCoordinator: SplashCoordinatorDelegate {
    /// Notifies delegate that splash screen finished, so AppCoordinator can proceed
    func splashDidFinish() {
        delegate?.splashDidFinish()
    }

    private let navigationController: UINavigationController
    weak var delegate: SplashCoordinatorDelegate?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let splashVC = SplashViewController()
        splashVC.coordinator = self
        navigationController.setViewControllers([splashVC], animated: false)
    }
}
