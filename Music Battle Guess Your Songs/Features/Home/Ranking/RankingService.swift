//
//  RankingService.swift
//  Music Battle Guess Your Songs
//
//  Created by PowerMac on 20.03.2026.
//

import Foundation

final class RankingService {
    static let leagueStep: Int = 1000
    static let maxRating: Int = RankingModel.League.allCases.count * leagueStep

    static func defineRank(rating: Int) -> RankingModel.League {
        let rating = rating < 0 ? 0 : rating

        let limitedRating = min(rating, maxRating)
        let index = min(limitedRating / leagueStep, RankingModel.League.allCases.count - 1)
        return RankingModel.League.allCases[index]
    }
    static func defineNextRank(rating: Int) -> RankingModel.League {
        let rating = rating < 0 ? 0 : rating
        let currentIndex = min(rating / leagueStep, RankingModel.League.allCases.count - 1)
        if currentIndex == RankingModel.League.allCases.count - 1 {
            return RankingModel.League.allCases[currentIndex]
        } else {
            return RankingModel.League.allCases[currentIndex + 1]
        }
    }
    static func trimRankForCurrentLeague(rating: Int) -> Int {
        let rating = rating < 0 ? 0 : rating
        if rating >= maxRating {
            return leagueStep
        }
        return rating % leagueStep
    }

    static func provideMaxProgressForLeague(rating: Int) -> Int {
        return leagueStep
    }

    static func provideProgressForLeague(rating: Int) -> Float {
        let rating = rating < 0 ? 0 : rating
        if rating >= maxRating {
            return 1
        }
        let trimmed = trimRankForCurrentLeague(rating: rating)
        return Float(trimmed) / Float(leagueStep)
    }
}
