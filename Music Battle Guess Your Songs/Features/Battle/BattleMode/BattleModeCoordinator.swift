//
//  LoginCoordinator.swift
//  Music Battle Guess Your Songs
//
//  Created by PowerMac on 01.03.2026.
//
import UIKit

final class BattleModeCoordinator {

    private let navigationController: UINavigationController
    private let appCoordinator: AppCoordinator

    init(navigationController: UINavigationController,
         appCoordinator: AppCoordinator) {
        self.navigationController = navigationController
        self.appCoordinator = appCoordinator
    }

    func start() {
        let vm = BattleModeViewModel(musicService: .shared)
        let battleVC = BattleModeViewController(viewModel: vm)

        navigationController.setViewControllers([battleVC], animated: false)
    }
}
