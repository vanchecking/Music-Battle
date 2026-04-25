//
//  BattleProcessView.swift
//  Music Battle Guess Your Songs
//
//  Created by PowerMac on 15.03.2026.
//

import UIKit
import SnapKit

final class BattleProcessView: UIView {

    // MARK: - UI Elements

    let roundLabel: UILabel = {
        return makeLabel(
            text: "Round 1",
            font: .boldSystemFont(ofSize: 20),
            textAlignment: .center,
            textColor: .label,
            numberOfLines: 1
        )
    }()

    let playerScoreLabelContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }()

    let playerScoreLabel: UILabel = {
        let label = makeLabel(
            text: "You: 0",
            font: .boldSystemFont(ofSize: 16),
            textAlignment: .center,
            textColor: .label,
            numberOfLines: 1
        )
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.lineBreakMode = .byClipping
        return label
    }()

    let botScoreLabelContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }()

    let botScoreLabel: UILabel = {
        let label = makeLabel(
            text: "Opponent: 0",
            font: .boldSystemFont(ofSize: 16),
            textAlignment: .center,
            textColor: .label,
            numberOfLines: 1
        )
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.lineBreakMode = .byClipping
        return label
    }()

    let resultLabel: UILabel = {
        return makeLabel(
            text: "Results will be there",
            font: .systemFont(ofSize: 17),
            textAlignment: .center,
            textColor: .secondaryLabel,
            numberOfLines: 0
        )
    }()

    let dudeView = DudeAnimationView()
    let backgroundLayer = AppColors.mainGradient()
    let answerButtons = AnswerButtonsView()

    let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Helpers

    private static func makeLabel(
        text: String,
        font: UIFont,
        textAlignment: NSTextAlignment,
        textColor: UIColor,
        numberOfLines: Int
    ) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textAlignment = textAlignment
        label.textColor = textColor
        label.numberOfLines = numberOfLines
        return label
    }

    // MARK: - States

    func showLoadingState() {
        loadingIndicator.startAnimating()

        roundLabel.isHidden = true
        playerScoreLabel.isHidden = true
        botScoreLabel.isHidden = true
        dudeView.isHidden = true
        resultLabel.isHidden = true

        answerButtons.hide()
        playerScoreLabelContainer.isHidden = true
        botScoreLabelContainer.isHidden = true
    }

    func showReadyState() {
        loadingIndicator.stopAnimating()

        roundLabel.isHidden = false
        playerScoreLabel.isHidden = false
        botScoreLabel.isHidden = false
        dudeView.isHidden = false
        resultLabel.isHidden = true

        answerButtons.show()
        playerScoreLabelContainer.isHidden = false
        botScoreLabelContainer.isHidden = false
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundLayer.frame = bounds
    }

    private func setupBackground() {
        layer.insertSublayer(backgroundLayer, at: 0)
    }

    func setupUI() {

        setupBackground()

        addSubview(roundLabel)
        addSubview(playerScoreLabelContainer)
        playerScoreLabelContainer.addSubview(playerScoreLabel)

        addSubview(botScoreLabelContainer)
        botScoreLabelContainer.addSubview(botScoreLabel)

        addSubview(resultLabel)
        addSubview(dudeView)
        addSubview(loadingIndicator)

        roundLabel.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(16)
            $0.centerX.equalToSuperview()
        }

        playerScoreLabelContainer.snp.makeConstraints {
            $0.top.equalTo(roundLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(24)
            $0.width.equalTo(120)
            $0.height.equalTo(40)
        }

        playerScoreLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(4)
        }

        botScoreLabelContainer.snp.makeConstraints {
            $0.top.equalTo(roundLabel.snp.bottom).offset(12)
            $0.trailing.equalToSuperview().inset(24)
            $0.width.equalTo(120)
            $0.height.equalTo(40)
        }

        botScoreLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(4)
        }

        resultLabel.snp.makeConstraints {
            $0.top.equalTo(playerScoreLabel.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(24)
        }

        dudeView.snp.makeConstraints {
            $0.top.equalTo(resultLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(200)
        }

        answerButtons.addForSubview(self)
        setupAnswerButtonsConstraints()

        loadingIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }

    private func setupAnswerButtonsConstraints() {
        for (index, button) in answerButtons.buttons.enumerated() {
            button.snp.makeConstraints {
                if index == 0 {
                    $0.top.equalTo(dudeView.snp.bottom).offset(32)
                } else {
                    $0.top.equalTo(answerButtons.buttons[index - 1].snp.bottom).offset(16)
                }
                $0.leading.trailing.equalToSuperview().inset(32)
                $0.height.equalTo(48)
            }
        }
    }

    // MARK: - Updates

    func updateRoundLabel(index: Int, roundCount: Int) {
        roundLabel.text = "Round \(index + 1)/\(roundCount)"
    }

    func updatePlayerScore(score: Int) {
        let current = Int(playerScoreLabel.text?.components(separatedBy: " ").last ?? "0") ?? 0
        animateScore(from: current, to: score) { [weak self] value in
            self?.playerScoreLabel.text = "You: \(value)"
        }
    }

    func updateBotScore(score: Int) {
        let current = Int(botScoreLabel.text?.components(separatedBy: " ").last ?? "0") ?? 0
        animateScore(from: current, to: score) { [weak self] value in
            self?.botScoreLabel.text = "Opponent: \(value)"
        }
    }

    private func animateScore(from start: Int, to end: Int, update: @escaping (Int) -> Void) {
        let diff = end - start
        guard diff != 0 else { return }

        let steps = abs(diff)
        let step = diff > 0 ? 1 : -1
        var current = start
        var count = 0

        Timer.scheduledTimer(withTimeInterval: 0.5 / Double(steps), repeats: true) { timer in
            current += step
            update(current)

            count += 1
            if count >= steps {
                timer.invalidate()
            }
        }
    }

    func updateAnswerButtons(variants: [String]) {
        for (index, button) in answerButtons.buttons.enumerated() where index < variants.count {
            button.setTitle(variants[index], for: .normal)
        }
    }

    // MARK: - Colors

    func updatePlayerScoreColor(for state: AnswerState) {
        playerScoreLabel.textColor = state.color
    }

    func updateBotScoreColor(for state: AnswerState) {
        botScoreLabel.textColor = state.color
    }
}
