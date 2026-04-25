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

    // MARK: - Combine
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

    private func allowPlayInSilentMode() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
    }

    private func setupBackground() {
        let gradientLayer = AppColors.mainGradient()
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    // MARK: - Bind ViewModel
    private func bindViewModel() {

        // Вспомогательный метод для подписки на Published свойства
        func subscribe<Value>(_ publisher: Published<Value>.Publisher, receive: @escaping (Value) -> Void) {
            publisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] value in
                    receive(value)
                    print(self ?? "")
                }
                .store(in: &cancellables)
        }

        // Подписка на текущий трек
        subscribe(viewModel.state.$currentTrack) { [weak self] track in
            self?.battleView.updateTrackLabel(text: track?.title)
            self?.playTrack(track)
        }

        // Подписка на варианты ответов
        subscribe(viewModel.state.$currentVariants) { [weak self] variants in
            self?.battleView.updateAnswerButtons(variants: variants)
        }

        subscribe(viewModel.state.$playerAnswerState) { [weak self] state in
            self?.battleView.updatePlayerScoreColor(for: state)
        }

        subscribe(viewModel.state.$botAnswerState) { [weak self] state in
            self?.battleView.updateBotScoreColor(for: state)
        }

        // Подписка на счет игрока
        subscribe(viewModel.state.$playerScore) { [weak self] score in
            self?.battleView.updatePlayerScore(score: score)
        }

        // Подписка на счет бота
        subscribe(viewModel.state.$botScore) { [weak self] score in
            self?.battleView.updateBotScore(score: score)
        }

        // Подписка на индекс раунда
        subscribe(viewModel.state.$roundIndex) { [weak self] index in
            self?.battleView.updateRoundLabel(index: index,
                                              roundCount: self?.viewModel.tracksCount ?? 0)
            self?.callBotAnswer()

        }

        // Подписка на состояние экрана
        subscribe(viewModel.state.$viewState) { [weak self] state in
            switch state {
            case .loading:
                self?.battleView.showLoadingState()
            case .ready:
                self?.battleView.showReadyState()
            case .results:
                guard let self else { return }
                let score = self.viewModel.battleScore
                let isPremium = SubscriptionService.shared.isPremium
                if isPremium {
                    Logger.log("Premium user, skipping ad 💰")
                    self.viewModel.onBattleResultCalled?(score, self.avPlayer)
                    AnalyticsService.shared.track(.adClicked(type: "skipped", placement: "premium"))
                } else {
                    Logger.log("Non premium user, showing ad 📢")
                    Logger.log("Non premium user, showing ad 📢")
                    AnalyticsService.shared.track(.adClicked(type: "showed ad", placement: "premium"))

                    AdManager.shared.showInterstitial(from: self) { [weak self] in
                        guard let self else { return }
                        self.viewModel.onBattleResultCalled?(score, self.avPlayer)
                    }
                }
               
            }
        }
    }

    private func playTrack(_ track: Track?) {
        guard let track = track, let url = track.previewAssets?.first?.url else { return }

        let t0 = CFAbsoluteTimeGetCurrent()

        let t1 = CFAbsoluteTimeGetCurrent()
        print("loaded asset: \((t1 - t0) * 1000) ms")

        let item = PlayerItemCache.shared.item(for: url)
        let t2 = CFAbsoluteTimeGetCurrent()
        print("converted to item: \((t2 - t1) * 1000) ms")

        NotificationCenter.default.removeObserver(avPlayer)
        avPlayer.replaceCurrentItem(with: item)
        let t3 = CFAbsoluteTimeGetCurrent()
        print("replace item: \((t3 - t2) * 1000) ms")

        avPlayer.play()
        let t4 = CFAbsoluteTimeGetCurrent()
        print("play called: \((t4 - t3) * 1000) ms")

        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak avPlayer] _ in
            avPlayer?.seek(to: .zero)
            avPlayer?.play()
        }

        let t5 = CFAbsoluteTimeGetCurrent()
        print("observer added: \((t5 - t4) * 1000) ms")
        print("TOTAL: \((t5 - t0) * 1000) ms")
    }

    @objc private func answerButtonTapped(_ sender: UIButton) {
        showAnswerAndStartNextRound(sender)
    }

    private func callBotAnswer() {
        let percentChange = self.viewModel.getPersentOfBarChange()

        let delay = Double.random(in: 1...2)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            let correctAnswer = self?.viewModel.makeBotAnswer() ?? false
            if correctAnswer {

                self?.battleView.dudeView.changeOppDudeSize(percent: percentChange)
                self?.viewModel.addScore(isPlayer: false, isCorrect: true)
                self?.viewModel.setAnswer(for: .bot, correct: true)

            } else {
                self?.battleView.dudeView.changeOppDudeSize(percent: percentChange * -1)
                self?.viewModel.addScore(isPlayer: false, isCorrect: false)
                self?.viewModel.setAnswer(for: .bot, correct: false)
            }
            self?.goToNextRound()
        }
    }

    private func goToNextRound() {
        if self.viewModel.bothAnswered() {
            // небольшая пауза перед следующим раундом
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.battleView.answerButtons.resetAppearance()
                self?.battleView.answerButtons.buttons.forEach { $0.isUserInteractionEnabled = true }

                self?.viewModel.startNextRound()
                self?.viewModel.resetAnswers()
            }
        }
    }

    private func showAnswerAndStartNextRound(_ sender: UIButton) {
        let percentChange = self.viewModel.getPersentOfBarChange()

        guard let index = battleView.answerButtons.buttons.firstIndex(of: sender) else { return }

        // блокируем кнопки чтобы не было повторных нажатий
        battleView.answerButtons.buttons.forEach { $0.isUserInteractionEnabled = false }

        // Получаем индекс правильного ответа из модели
        let correctIndex = viewModel.state.currentRoundRightAnswerIndex

        if index == correctIndex {
            battleView.answerButtons.showCorrectAnswer(at: index)
            battleView.dudeView.changePlayerDudeSize(percent: percentChange)
            self.viewModel.addScore(isPlayer: true, isCorrect: true)
            self.viewModel.setAnswer(for: .player, correct: true)
            AnalyticsService.shared.track(.songGuessed(correct: true, round: viewModel.state.roundIndex))
        } else if let correctIndex = correctIndex {
            battleView.answerButtons.showWrongAnswer(at: index, correctIndex: correctIndex)
            battleView.dudeView.changePlayerDudeSize(percent: percentChange * -1)
            self.viewModel.addScore(isPlayer: true, isCorrect: false)
            self.viewModel.setAnswer(for: .player, correct: false)
            AnalyticsService.shared.track(.songGuessed(correct: false, round: viewModel.state.roundIndex))

        }
        self.goToNextRound()
    }

    private func bindButton() {
        battleView.answerButtons.buttons.forEach { $0.addTarget(self, action: #selector(answerButtonTapped(_:)), for: .touchUpInside) }

    }

    deinit {
        PlayerItemCache.shared.clear()
    }
}
