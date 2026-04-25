//
//  RankingServiceTests.swift
//  Music Battle Guess Your Songs
//
//  Created by PowerMac on 21.03.2026.
//

import XCTest
@testable import Music_Battle_Guess_Your_Songs

@MainActor
final class RankingServiceTests: XCTestCase {

    // MARK: - defineRank

    func testDefineRank_zeroRating_returnsFirstLeague() {
        let rank = RankingService.defineRank(rating: 0)
        XCTAssertEqual(rank, RankingModel.League.allCases[0])
    }

    func testProgress_neverExceedsBounds() {
        for rating in -1000...RankingService.maxRating + 1000 {
            let progress = RankingService.provideProgressForLeague(rating: rating)
            XCTAssertGreaterThanOrEqual(progress, 0)
            XCTAssertLessThanOrEqual(progress, 1)
        }
    }

    func testNegativeRating_behaviour() {
        let rating = -100

        let rank = RankingService.defineRank(rating: rating)
        let next = RankingService.defineNextRank(rating: rating)
        let progress = RankingService.provideProgressForLeague(rating: rating)

        XCTAssertEqual(rank, RankingModel.League.allCases[0])
        XCTAssertEqual(next, RankingModel.League.allCases[1])
        XCTAssertGreaterThanOrEqual(progress, 0)
    }

    func testDefineRank_middleOfLeague() {
        let rating = RankingService.leagueStep + (RankingService.leagueStep / 2) // middle on next league
        let rank = RankingService.defineRank(rating: rating)
        XCTAssertEqual(rank, RankingModel.League.allCases[1])
    }

    func testDefineRank_exactBoundary() {
        let rating = RankingService.leagueStep
        let rank = RankingService.defineRank(rating: rating)
        XCTAssertEqual(rank, RankingModel.League.allCases[1])
    }

    func testDefineRank_maxRatingClamp() {
        let rating = RankingService.maxRating + 1000
        let rank = RankingService.defineRank(rating: rating)
        XCTAssertEqual(rank, RankingModel.League.allCases.last)
    }

    // MARK: - defineNextRank

    func testDefineNextRank_normalCase() {
        let rating = 200
        let next = RankingService.defineNextRank(rating: rating)
        XCTAssertEqual(next, RankingModel.League.allCases[1])
    }

    func testDefineNextRank_boundary() {
        let rating = RankingService.leagueStep
        let next = RankingService.defineNextRank(rating: rating)
        XCTAssertEqual(next, RankingModel.League.allCases[2])
    }

    func testDefineNextRank_lastLeague_returnsSame() {
        let rating = RankingService.maxRating + 100
        let next = RankingService.defineNextRank(rating: rating)
        XCTAssertEqual(next, RankingModel.League.allCases.last)
    }

    // MARK: - trimRankForCurrentLeague

    func testTrimRank_insideLeague() {
        let rating = RankingService.leagueStep + (RankingService.leagueStep / 2)
        let trimmed = RankingService.trimRankForCurrentLeague(rating: rating)
        XCTAssertEqual(trimmed, 500)
    }

    func testTrimRank_exactBoundary() {
        let rating = RankingService.leagueStep * 2
        let trimmed = RankingService.trimRankForCurrentLeague(rating: rating)
        XCTAssertEqual(trimmed, 0)
    }

    func testTrimRank_maxRating() {
        let rating = RankingService.maxRating
        let trimmed = RankingService.trimRankForCurrentLeague(rating: rating)
        XCTAssertEqual(trimmed, RankingService.leagueStep)
    }

    // MARK: - provideMaxProgressForLeague

    func testMaxProgress_alwaysEqualsLeagueStep() {
        let value = RankingService.provideMaxProgressForLeague(rating: 1234)
        XCTAssertEqual(value, RankingService.leagueStep)
    }

    // MARK: - provideProgressForLeague

    func testProgress_zero() {
        let progress = RankingService.provideProgressForLeague(rating: 0)
        XCTAssertEqual(progress, 0)
    }

    func testProgress_half() {
        let rating = RankingService.leagueStep + (RankingService.leagueStep / 2)
        let progress = RankingService.provideProgressForLeague(rating: rating)
        XCTAssertEqual(progress, 0.5)
    }

    func testProgress_fullAtBoundary() {
        let rating = RankingService.leagueStep
        let progress = RankingService.provideProgressForLeague(rating: rating)
        XCTAssertEqual(progress, 0)
    }

    func testProgress_maxRating_isOne() {
        let rating = RankingService.maxRating + 1
        let progress = RankingService.provideProgressForLeague(rating: rating)
        XCTAssertEqual(progress, 1)
    }
}
