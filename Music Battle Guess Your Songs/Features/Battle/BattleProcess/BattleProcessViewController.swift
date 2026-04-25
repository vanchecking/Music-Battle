//
//  BattleProcessViewController.swift
//  Music Battle Guess Your Songs
//
//  Created by PowerMac on 13.03.2026.
//

import UIKit
import SnapKit
import Combine
import MusicKit
import AVFoundation

final class BattleProcessViewController: UIViewController {

    // MARK: - Properties
    private let viewModel: BattleProcessViewModel
    private var avPlayer = AVPlayer()
    private let battleView = BattleProcessView()

    // MARK: - Combine subscriptions
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init
    init(viewModel: BattleProcessViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        AdManager.shared.loadInterstitial()
        allowPlayInSilentMode()

        view = battleView

        bindButton()
        bindViewModel()

        battleView.showLoadingState()
        viewModel.startFirstRound()
    }

    // Allow audio playback even in silent mode
    private func allowPlayInSilentMode() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
    }

    // Optional background gradient setup
    private func setupBackground() {
        let gradientLayer = AppColors.mainGradient()
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    // MARK: - ViewModel binding
    private func bindViewModel() {

        // Helper for subscribing to @Published values
        func subscribe<Value>(_ publisher: Published<Value>.Publisher, receive: @escaping (Value) -> Void) {
            publisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] value in
                    receive(value)
                    print(self ?? "")
                }
                .store(in: &cancellables)
        }

        // Current track
        subscribe(viewModel.state.$currentTrack) { [weak self] track in
            self?.playTrack(track)
        }

        // Answer variants
        subscribe(viewModel.state.$currentVariants) { [weak self] variants in
            self?.battleView.updateAnswerButtons(variants: variants)
        }

        // Player answer state
        subscribe(viewModel.state.$playerAnswerState) { [weak self] state in
            self?.battleView.updatePlayerScoreColor(for: state)
        }

        // Bot answer state
        subscribe(viewModel.state.$botAnswerState) { [weak self] state in
            self?.battleView.updateBotScoreColor(for: state)
        }

        // Player score
        subscribe(viewModel.state.$playerScore) { [weak self] score in
            self?.battleView.updatePlayerScore(score: score)
        }

        // Bot score
        subscribe(viewModel.state.$botScore) { [weak self] score in
            self?.battleView.updateBotScore(score: score)
        }

        // Round index updates
        subscribe(viewModel.state.$roundIndex) { [weak self] index in
            self?.battleView.updateRoundLabel(
                index: index,
                roundCount: self?.viewModel.tracksCount ?? 0
            )
            self?.callBotAnswer()
        }

        // Screen state (loading / ready / results)
        subscribe(viewModel.state.$viewState) { [weak self] state in
            guard let self else { return }

            switch state {
            case .loading:
                self.battleView.showLoadingState()

            case .ready:
                self.battleView.showReadyState()

            case .results:
                let score = self.viewModel.battleScore
                let isPremium = SubscriptionService.shared.isPremium

                if isPremium {
                    Logger.log("Premium user, skipping ad")
                    self.viewModel.onBattleResultCalled?(score, self.avPlayer)
                    AnalyticsService.shared.track(.adClicked(type: "skipped", placement: "premium"))
                } else {
                    Logger.log("Non-premium user, showing ad")
                    AnalyticsService.shared.track(.adClicked(type: "showed", placement: "results"))

                    AdManager.shared.showInterstitial(from: self) { [weak self] in
                        guard let self else { return }
                        self.viewModel.onBattleResultCalled?(score, self.avPlayer)
                    }
                }
            }
        }
    }

    // MARK: - Audio playback
    private func playTrack(_ track: Track?) {
        guard let track = track, let url = track.previewAssets?.first?.url else { return }

        let t0 = CFAbsoluteTimeGetCurrent()

        let item = PlayerItemCache.shared.item(for: url)

        NotificationCenter.default.removeObserver(avPlayer)
        avPlayer.replaceCurrentItem(with: item)
        avPlayer.play()

        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak avPlayer] _ in
            avPlayer?.seek(to: .zero)
            avPlayer?.play()
        }

        let t1 = CFAbsoluteTimeGetCurrent()
        print("Play setup time: \((t1 - t0) * 1000) ms")
    }

    // MARK: - Player input
    @objc private func answerButtonTapped(_ sender: UIButton) {
        showAnswerAndStartNextRound(sender)
    }

    // MARK: - Bot logic
    private func callBotAnswer() {
        let percentChange = viewModel.getPersentOfBarChange()

        let delay = Double.random(in: 1...2)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self else { return }

            let correct = self.viewModel.makeBotAnswer()

            if correct {
                self.battleView.dudeView.changeOppDudeSize(percent: percentChange)
                self.viewModel.addScore(isPlayer: false, isCorrect: true)
                self.viewModel.setAnswer(for: .bot, correct: true)
            } else {
                self.battleView.dudeView.changeOppDudeSize(percent: percentChange * -1)
                self.viewModel.addScore(isPlayer: false, isCorrect: false)
                self.viewModel.setAnswer(for: .bot, correct: false)
            }

            self.goToNextRound()
        }
    }

    // MARK: - Round progression
    private func goToNextRound() {
        guard viewModel.bothAnswered() else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }

            self.battleView.answerButtons.resetAppearance()
            self.battleView.answerButtons.buttons.forEach { $0.isUserInteractionEnabled = true }

            self.viewModel.startNextRound()
            self.viewModel.resetAnswers()
        }
    }

    // MARK: - Player answer handling
    private func showAnswerAndStartNextRound(_ sender: UIButton) {
        let percentChange = viewModel.getPersentOfBarChange()

        guard let index = battleView.answerButtons.buttons.firstIndex(of: sender) else { return }

        battleView.answerButtons.buttons.forEach { $0.isUserInteractionEnabled = false }

        let correctIndex = viewModel.state.currentRoundRightAnswerIndex

        if index == correctIndex {
            battleView.answerButtons.showCorrectAnswer(at: index)
            battleView.dudeView.changePlayerDudeSize(percent: percentChange)
            viewModel.addScore(isPlayer: true, isCorrect: true)
            viewModel.setAnswer(for: .player, correct: true)
        } else if let correctIndex {
            battleView.answerButtons.showWrongAnswer(at: index, correctIndex: correctIndex)
            battleView.dudeView.changePlayerDudeSize(percent: percentChange * -1)
            viewModel.addScore(isPlayer: true, isCorrect: false)
            viewModel.setAnswer(for: .player, correct: false)
        }

        goToNextRound()
    }

    // MARK: - UI binding
    private func bindButton() {
        battleView.answerButtons.buttons.forEach {
            $0.addTarget(self, action: #selector(answerButtonTapped(_:)), for: .touchUpInside)
        }
    }

    deinit {
        PlayerItemCache.shared.clear()
    }
}
