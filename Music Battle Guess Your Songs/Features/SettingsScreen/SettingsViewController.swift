//
//  BattleHistoryViewController.swift
//  Music Battle Guess Your Songs
//
//  Created by PowerMac on 22.03.2026.
//

import Foundation
import UIKit

final class SettingsViewController: UIViewController {

    private let gradientLayer = AppColors.mainGradient()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradient()
    }

    private func setupGradient() {
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }
}
