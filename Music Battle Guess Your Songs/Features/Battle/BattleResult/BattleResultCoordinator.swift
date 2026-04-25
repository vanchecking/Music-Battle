//
//  LoginCoordinator.swift
//  Music Battle Guess Your Songs
//
//  Created by PowerMac on 01.03.2026.
//
import UIKit
import MusicKit
import AVFoundation

final class BattleResultCoordinator {

    private let navigationController: UINavigationController
    private let appCoordinator: AppCoordinator
    private let battleScore: BattleScore
    private let player: AVPlayer

    init(navigationController: UINavigationController,
         appCoordinator: AppCoordinator, battleScore: BattleScore, player: AVPlayer) {
        self.navigationController = navigationController
        self.appCoordinator = appCoordinator
        self.battleScore = battleScore
        self.player = player
    }

    func start() {
        let battleResultVC = BattleResultViewController(score: battleScore, player: player)
        battleResultVC.onHomeTapped = { [weak self] in
            self?.appCoordinator.showHome()
        }

        navigationController.setViewControllers([battleResultVC], animated: false)
    }
}
