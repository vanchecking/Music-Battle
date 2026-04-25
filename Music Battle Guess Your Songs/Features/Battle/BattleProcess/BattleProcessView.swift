// MARK: - Answer State Enum & Color Extension
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
        let label = makeLabel(text: "Round 1", font: UIFont.boldSystemFont(ofSize: 20), textAlignment: .center, textColor: .label, numberOfLines: 1)
        return label
    }()

    let playerScoreLabelContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }()

    let playerScoreLabel: UILabel = {
        let label = makeLabel(text: "You: 0", font: UIFont.boldSystemFont(ofSize: 16), textAlignment: .center, textColor: .label, numberOfLines: 1)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.lineBreakMode = .byClipping
        label.textAlignment = .center
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
        let label = makeLabel(text: "Opponent: 0", font: UIFont.boldSystemFont(ofSize: 16), textAlignment: .center, textColor: .label, numberOfLines: 1)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.lineBreakMode = .byClipping
        label.textAlignment = .center
        return label
    }()

    let resultLabel: UILabel = {
        let label = makeLabel(text: "Results will be there", font: UIFont.systemFont(ofSize: 17), textAlignment: .center, textColor: .secondaryLabel, numberOfLines: 0)
        return label
    }()

    let dudeView = DudeAnimationView()

    let backgroundLayer = AppColors.mainGradient()

    let answerButtons = AnswerButtonsView()

    let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private Helpers

    private static func makeLabel(text: String, font: UIFont, textAlignment: NSTextAlignment, textColor: UIColor, numberOfLines: Int) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textAlignment = textAlignment
        label.textColor = textColor
        label.numberOfLines = numberOfLines
        return label
    }

    func showLoadingState() {
        loadingIndicator.startAnimating()
        roundLabel.isHidden = true
        playerScoreLabel.isHidden = true
        botScoreLabel.isHidden = true
        dudeView.isHidden = true
        answerButtons.hide()
        resultLabel.isHidden = true
        botScoreLabelContainer.isHidden = true
        playerScoreLabelContainer.isHidden = true
    }

    func showReadyState() {
        loadingIndicator.stopAnimating()
        roundLabel.isHidden = false
        playerScoreLabel.isHidden = false
        botScoreLabel.isHidden = false
        dudeView.isHidden = false
        answerButtons.show()
        resultLabel.isHidden = true
        botScoreLabelContainer.isHidden = false
        playerScoreLabelContainer.isHidden = false
    }

    private func setupBackground() {
        layer.insertSublayer(backgroundLayer, at: 0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundLayer.frame = bounds
    }

    // MARK: - Setup UI
    func setupUI() {

        // Добавляем лейблы
        self.setupBackground()
        self.addSubview(roundLabel)
        self.addSubview(playerScoreLabelContainer)
        playerScoreLabelContainer.addSubview(playerScoreLabel)
        self.addSubview(botScoreLabelContainer)
        botScoreLabelContainer.addSubview(botScoreLabel)
        self.addSubview(resultLabel)
        // self.addSubview(trackLabel)
        self.addSubview(dudeView)
        self.addSubview(loadingIndicator)

        roundLabel.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide).offset(16)
            make.centerX.equalToSuperview()
        }
        playerScoreLabelContainer.snp.makeConstraints { make in
            make.top.equalTo(roundLabel.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(24)
            make.width.equalTo(120)
            make.height.equalTo(40)
        }
        playerScoreLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(4)
        }
        botScoreLabelContainer.snp.makeConstraints { make in
            make.top.equalTo(roundLabel.snp.bottom).offset(12)
            make.trailing.equalToSuperview().inset(24)
            make.width.equalTo(120)
            make.height.equalTo(40)
        }
        botScoreLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(4)
        }
        resultLabel.snp.makeConstraints { make in
            make.top.equalTo(playerScoreLabel.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        dudeView.snp.makeConstraints { make in
            make.top.equalTo(resultLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(200) // adjust height as needed
        }

        // Кнопки ответов
        answerButtons.addForSubview(self)
        setupAnswerButtonsConstraints()

        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    private func setupAnswerButtonsConstraints() {
        for (index, button) in answerButtons.buttons.enumerated() {
            button.snp.makeConstraints { make in
                if index == 0 {
                    make.top.equalTo(dudeView.snp.bottom).offset(32)
                } else {
                    make.top.equalTo(answerButtons.buttons[index-1].snp.bottom).offset(16)
                }
                make.leading.trailing.equalToSuperview().inset(32)
                make.height.equalTo(48)
            }
        }
    }

    // MARK: - UI Update Helpers
    func updateTrackLabel(text: String?) {
        // trackLabel.text = text ?? "No Track"
    }
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
        let stepValue = diff > 0 ? 1 : -1
        var current = start
        var count = 0

        Timer.scheduledTimer(withTimeInterval: 0.5 / Double(steps), repeats: true) { timer in
            current += stepValue
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

    // MARK: - Score Label Color Updates
    func updatePlayerScoreColor(for state: AnswerState) {
        playerScoreLabel.textColor = state.color
    }

    func updateBotScoreColor(for state: AnswerState) {
        botScoreLabel.textColor = state.color
    }
}
