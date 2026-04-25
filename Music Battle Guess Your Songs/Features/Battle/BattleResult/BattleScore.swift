//
//  BattleScore.swift
//  Music Battle Guess Your Songs
//
//  Created by PowerMac on 15.03.2026.
//

import MusicKit

struct BattleScore {
    let playerScore: Int
    let botScore: Int
    let tracks: [Track]

    func ratingBonus() -> Int {
        return tracks.count * 10
    }

    var isWin: Bool {
        playerScore > botScore
    }

    var isDraw: Bool {
        playerScore == botScore
    }

    var roundsCount: Int {
        tracks.count
    }

    var allPlayerRightAnswers: Bool {
        playerScore / 10 == tracks.count
    }

    func ratingChange() -> Int {
        return playerScore - botScore + (allPlayerRightAnswers ? ratingBonus() : 0)
    }
}
