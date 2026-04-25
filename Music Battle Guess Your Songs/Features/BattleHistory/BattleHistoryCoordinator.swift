//
//  LoginCoordinator.swift
//  Music Battle Guess Your Songs
//
//  Created by PowerMac on 01.03.2026.
//
import UIKit

final class BattleHistoryCoordinator {

    private let navigationController: UINavigationController
    private let appCoordinator: AppCoordinator

    init(navigationController: UINavigationController,
         appCoordinator: AppCoordinator) {
        self.navigationController = navigationController
        self.appCoordinator = appCoordinator
    }

    func start() {

        let battleHistoryVC = BattleHistoryViewController()

        navigationController.pushViewController(battleHistoryVC, animated: false)
        UIView.transition(
            with: navigationController.view,
            duration: 0.35,
            options: .transitionCrossDissolve,
            animations: nil
        )
    }
}
