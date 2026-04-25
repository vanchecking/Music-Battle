//
//  HomeCoordinator.swift
//  Music Battle Guess Your Songs
//
//  Created by PowerMac on 01.03.2026.
//
import UIKit

final class HomeCoordinator: Coordinator {

    internal let navigationController: UINavigationController
    private let appCoordinator: AppCoordinator

    init(navigationController: UINavigationController,
         appCoordinator: AppCoordinator) {
        self.navigationController = navigationController
        self.appCoordinator = appCoordinator
    }

    func start() {
        let viewModel = HomeViewModel()
        let vc = HomeViewController(viewModel: viewModel)
        vc.viewModel.onLogoutSuccess = { [weak self] in
            self?.appCoordinator.showLoginWithTransition()
        }

        vc.viewModel.onBattleModeTapped = { [weak self] in
            self?.pushBattleMode()
        }

        vc.viewModel.onBattleHistoryTapped = { [weak self] in
            self?.appCoordinator.showBattleHistory()
        }

        vc.viewModel.onSettingsTapped = { [weak self] in
            self?.appCoordinator.showSettings()
        }

        navigationController.setViewControllers([vc], animated: false)
        UIView.transition(
            with: navigationController.view,
            duration: 0.35,
            options: .transitionCrossDissolve,
            animations: nil
        )
    }
    private func pushBattleMode() {
        let vm = BattleModeViewModel(musicService: .shared)
        let battleVC = BattleModeViewController(viewModel: vm)
        battleVC.onBattleProcessTapped = { [weak self] tracks in
            self?.appCoordinator.showBattleProcess(tracks: tracks)
        }
        navigationController.pushViewController(battleVC, animated: true)
    }
}
