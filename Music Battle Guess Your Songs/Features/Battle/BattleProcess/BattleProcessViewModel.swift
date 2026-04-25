//
//  BattleProcessViewModel.swift
//  Music Battle Guess Your Songs
//
//  Created by PowerMac on 13.03.2026.
//

import Foundation
import MusicKit
import Combine
import UIKit
import AVFoundation

final class BattleState: ObservableObject {
    @Published var currentTrack: Track?
    @Published var nextTrack: Track?
    @Published var currentVariants: [String] = []
    @Published var nextVariants: [String] = []
    @Published var currentTrackData: URL?
    @Published var playerScore: Int = 0
    @Published var botScore: Int = 0
    @Published var roundIndex: Int = 0
    @Published var roundCount: Int = 0
    @Published var viewState: BattleProcessViewModel.ViewState = .loading
    @Published var currentRoundRightAnswerIndex: Int?
    @Published var playerAnswerState: AnswerState = .notAnswered
    @Published var botAnswerState: AnswerState = .notAnswered
}

enum AnswerState {
    case notAnswered
    case right
    case wrong

    var color: UIColor {
        switch self {
        case .notAnswered:
            return UIColor(white: 0.95, alpha: 1) // почти белый, читается на розовом
        case .right:
            return UIColor(red: 0.0, green: 0.8, blue: 0.4, alpha: 1) // яркий зеленый с контрастом
        case .wrong:
            return UIColor(red: 0.9, green: 0.2, blue: 0.3, alpha: 1) // насыщенный красный
        }
    }
}

final class BattleProcessViewModel {
    enum ViewState {
        case loading, ready, results
    }
    enum Participant {
        case player
        case bot
    }

    func getPersentOfBarChange() -> Double {
        return 0.5 / Double(tracks.count)
    }

    let tracks: [Track]
    var battleScore: BattleScore
    var onBattleResultCalled: ((_ score: BattleScore, _ player: AVPlayer) -> Void)?
    let state = BattleState()
    private var botAnwered: Bool = false
    private var playerAnwered: Bool = false

    func setAnswer(for participant: Participant, correct: Bool) {
        let value: AnswerState = correct ? .right : .wrong

        switch participant {
        case .player:
            state.playerAnswerState = value
        case .bot:
            state.botAnswerState = value
        }
    }

    func makeBotAnswer() -> Bool {
        let playerScore = state.playerScore
        let botScore = state.botScore
        let scoreDiff = playerScore - botScore
        let isLastRound = state.roundIndex == tracks.count - 1

        Logger.log("makeBotAnswer called — player: \(playerScore), bot: \(botScore), diff: \(scoreDiff), lastRound: \(isLastRound)")

        // Последний раунд — бот точно ошибается
        if isLastRound {
            Logger.log("Last round: bot answers incorrectly")
            return false
        }

        // Если игрок сильно впереди (>5 очков), бот отвечает неправильно
        if scoreDiff < -5 {
            Logger.log("Player is far ahead: bot answers incorrectly")
            return false
        }

        if scoreDiff > 20 {
            return true
        }

        // Базовая вероятность 45%, увеличивается если бот отстаёт
        let baseChance: Double = 0.45
        let modifier = min(Double(max(scoreDiff, 0)) * 0.05, 0.1) // максимум +10%
        let chanceToBeCorrect = min(baseChance + modifier, 0.95)

        let willBeCorrect = Double.random(in: 0...1) <= chanceToBeCorrect
        Logger.log("Bot chance: \(chanceToBeCorrect), willBeCorrect: \(willBeCorrect)")
        return willBeCorrect
    }

    func resetAnswers() {
        state.playerAnswerState = .notAnswered
        state.botAnswerState = .notAnswered
    }

    func bothAnswered() -> Bool {
        state.playerAnswerState != .notAnswered &&
        state.botAnswerState != .notAnswered
    }

    var tracksCount: Int { tracks.count }

    init(tracks: [Track]) {
        self.tracks = tracks
        self.battleScore = .init(playerScore: 0, botScore: 0, tracks: tracks)
        state.roundCount = tracks.count
        print("tracks loaded: \(tracks.count)")
    }

    func startFirstRound() {
        Task {
            await loadFirstTrack()
            await preloadNextTrack()
        }
    }

    func startNextRound() {
        Task {
            // Если нет следующего трека — показываем результаты
            let nextIndex = state.roundIndex + 1
            guard nextIndex < tracks.count else {
                self.battleScore = BattleScore(playerScore: state.playerScore, botScore: state.botScore, tracks: tracks)
                state.viewState = .results
                return
            }

            // Если следующий трек ещё не загружен — ставим loading и ждём preload
            if state.nextTrack == nil {
                state.viewState = .loading
                // После preload пробуем снова перейти на следующий раунд
                startNextRound() // рекурсивный вызов
                return
            }

            // Трек загружен — обновляем данные текущего раунда
            state.roundIndex += 1
            state.currentTrack = state.nextTrack
            state.currentVariants = state.nextVariants
            setAnswerIndex()

            state.viewState = .ready

            // Предзагружаем следующий трек асинхронно
            Task {
                await preloadNextTrack()
            }
        }
    }

    private func setAnswerIndex() {
        state.currentRoundRightAnswerIndex = state.currentVariants.firstIndex(of: state.currentTrack?.title ?? "") ?? 0
    }

    func addScore(isPlayer: Bool, isCorrect: Bool) {
        let delta = isCorrect ? 10 : -3

        if isPlayer {
            state.playerScore = max(0, state.playerScore + delta)
        } else {
            state.botScore = max(0, state.botScore + delta)
        }
    }

    private func clearPreloadedPreviously() {
        state.nextTrack = nil
        state.nextVariants = []
    }

    private func loadFirstTrack() async {
        guard let firstTrack = tracks.first else { return }

        let variants = generateVariants(for: firstTrack)

        // Только после полной подготовки меняем состояние
        state.currentTrack = firstTrack
        state.currentVariants = variants
        setAnswerIndex()
        state.viewState = .ready
    }

    private func preloadNextTrack() async {
        clearPreloadedPreviously()
        let nextIndex = state.roundIndex + 1
        guard nextIndex < tracks.count else {
            Logger.log("No next track to preload")
            return
        }
        let nextTrack = tracks[nextIndex]
        guard let trackUrl = nextTrack.previewAssets?.first?.url else {
            Logger.log("Next track has no URL: \(nextTrack.title)")
            return
        }

        state.nextTrack = nextTrack
        state.nextVariants = generateVariants(for: nextTrack)

        _ = PlayerItemCache.shared.item(for: trackUrl)
        Logger.log("Preloaded next track: \(nextTrack.title) with variants: \(state.nextVariants)")
    }

    private func generateVariants(for track: Track) -> [String] {
        var variants = [track.title]
        let otherTracks = tracks.filter { $0.id != track.id }
        let randomTracks = otherTracks.shuffled().prefix(3)
        variants.append(contentsOf: randomTracks.map { $0.title })
        variants.shuffle()
        return variants
    }

}
