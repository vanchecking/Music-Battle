//
//  AnswerButtonsView.swift
//  Music Battle Guess Your Songs
//
//  Created by PowerMac on 15.03.2026.
//

import UIKit

final class AnswerButtonsView: UIView {
    let buttons: [UIButton] = (0..<4).map { _ in
        let button = UIButton(type: .system)
        button.setTitle("", for: .normal)
        button.backgroundColor = AppColors.answerButtonBackground
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.5
        return button
    }

    func hide() {
        buttons.forEach { $0.isHidden = true }
    }

    func show() {
        buttons.forEach { $0.isHidden = false }
    }

    func addForSubview(_ view: UIView) {
        buttons.forEach {
            view.addSubview($0)
        }
    }

    func showWrongAnswer(at index: Int, correctIndex: Int) {
        guard buttons.indices.contains(index) else { return }

        let wrongButton = buttons[index]

        wrongButton.layer.borderWidth = 2
        wrongButton.layer.borderColor = UIColor.systemRed.cgColor

        UIView.animate(withDuration: 0.25) {
            wrongButton.backgroundColor = UIColor.systemRed.withAlphaComponent(0.2)
        }

        if buttons.indices.contains(correctIndex) {
            let correctButton = buttons[correctIndex]
            correctButton.layer.borderWidth = 2
            correctButton.layer.borderColor = UIColor.systemGreen.cgColor

            UIView.animate(withDuration: 0.25) {
                correctButton.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.2)
            }
        }
    }

    func showCorrectAnswer(at index: Int) {
        guard buttons.indices.contains(index) else { return }

        let button = buttons[index]

        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.systemGreen.cgColor

        UIView.animate(withDuration: 0.25, animations: {
            button.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.2)
            button.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }, completion: { _ in
            UIView.animate(withDuration: 0.15, animations: {
                button.transform = .identity
            })
        })
    }

    func resetAppearance() {
        buttons.forEach { button in
            button.layer.borderWidth = 0
            button.layer.borderColor = UIColor.clear.cgColor
            button.backgroundColor = AppColors.answerButtonBackground
            button.transform = .identity
        }
    }
}
