//
//  RankingModel.swift
//  Music Battle Guess Your Songs
//
//  Created by PowerMac on 20.03.2026.
//

import Foundation
import UIKit

final class RankingModel {
    static let shared = RankingModel()

    private init() {}

    enum League {
        case bronze, silver, gold, platinum, diamond, legend

        static var allCases: [League] {
            return [.bronze, .silver, .gold, .platinum, .diamond, .legend]
        }
    }

    func leagueEmoji(for league: League) -> String {
        let emojis: [League: String] = [
            .bronze: "🥉",
            .silver: "🥈",
            .gold: "🥇",
            .platinum: "🏆",
            .diamond: "💎",
            .legend: "👑"
        ]

        let emoji = emojis[league] ?? "🥉"
       return emoji
    }
}
