//
//  LoginCoordinator.swift
//  Music Battle Guess Your Songs
//
//  Created by PowerMac on 01.03.2026.
//
import UIKit
import MusicKit

final class BattleProcessCoordinator {

    private let navigationController: UINavigationController
    private let appCoordinator: AppCoordinator
    private let tracks: [Track]

    init(navigationController: UINavigationController,
         appCoordinator: AppCoordinator, tracks: [Track]) {
        self.navigationController = navigationController
        self.appCoordinator = appCoordinator
        self.tracks = tracks
    }

    func start() {
        let vm = BattleProcessViewModel(tracks: tracks)
        vm.onBattleResultCalled = { [weak self] score, player in
            self?.appCoordinator.showBattleResult(score: score, player: player)
        }
        let battleVC = BattleProcessViewController(viewModel: vm)

        navigationController.setViewControllers([battleVC], animated: false)
    }
}
