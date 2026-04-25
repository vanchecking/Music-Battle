//
//  StatsSectionView.swift
//  Music Battle Guess Your Songs
//
//  Created by PowerMac on 07.03.2026.
//

import UIKit
import SnapKit

final class StatsSectionView: UIView {

    private let cardView = CardView()

    private let titleLabel = UILabel()
    private let winsLabel = UILabel()
    private let battlesLabel = UILabel()
    private let winRatePercentLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(wins: Int, battles: Int) {
        winsLabel.text = "\(wins)"
        battlesLabel.text = "\(battles)"

        let winRate: Double = battles > 0 ? (Double(wins) / Double(battles)) * 100 : 0
        winRatePercentLabel.text = String(format: "%.0f%%", winRate)
    }

    private func setupUI() {
        addSubview(cardView)

        titleLabel.text = "💠 Stats 💠"
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        titleLabel.textAlignment = .center
        cardView.addSubview(titleLabel)

        winsLabel.font = AppFonts.stats()
        winsLabel.textAlignment = .right

        battlesLabel.font = AppFonts.stats()
        battlesLabel.textAlignment = .right

        winRatePercentLabel.font = AppFonts.stats()
        winRatePercentLabel.textAlignment = .right

        let leftStack = UIStackView()
        let rightStack = UIStackView()

        leftStack.axis = .vertical
        leftStack.spacing = 8

        rightStack.axis = .vertical
        rightStack.spacing = 8
        rightStack.alignment = .trailing

        leftStack.addArrangedSubview(UILabel(text: "🏆 Wins"))
        leftStack.addArrangedSubview(UILabel(text: "⚔️ Battles"))
        leftStack.addArrangedSubview(UILabel(text: "🎯 Rate"))

        rightStack.addArrangedSubview(winsLabel)
        rightStack.addArrangedSubview(battlesLabel)
        rightStack.addArrangedSubview(winRatePercentLabel)

        let containerStack = UIStackView()
        containerStack.axis = .horizontal
        containerStack.distribution = .fillEqually
        containerStack.addArrangedSubview(leftStack)
        containerStack.addArrangedSubview(rightStack)

        cardView.addSubview(containerStack)

        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.greaterThanOrEqualTo(100)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.centerX.equalToSuperview()
        }

        containerStack.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.lessThanOrEqualToSuperview().inset(16)
        }
    }
}

private extension UILabel {
    convenience init(text: String) {
        self.init()
        self.text = text
        self.font = AppFonts.stats()
        self.textAlignment = .left
    }
}
