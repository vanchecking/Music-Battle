import Foundation

struct Wallet: Codable {
    private(set) var coins: Int
    private(set) var gems: Int

    init(coins: Int = 0, gems: Int = 0) {
        self.coins = max(0, coins)
        self.gems = max(0, gems)
    }

    mutating func addCoins(_ amount: Int) {
        guard amount > 0 else { return }
        coins += amount
    }

    mutating func spendCoins(_ amount: Int) -> Bool {
        guard amount > 0, coins >= amount else { return false }
        coins -= amount
        return true
    }

    mutating func addGems(_ amount: Int) {
        guard amount > 0 else { return }
        gems += amount
    }

    mutating func spendGems(_ amount: Int) -> Bool {
        guard amount > 0, gems >= amount else { return false }
        gems -= amount
        return true
    }
}

struct UserProfile: Codable {
    let userID: String
    var email: String?
    var nickname: String

    var totalWins: Int
    var totalBattles: Int
    var rating: Double

    var favoriteGenres: [String]
    var favoriteSongs: [String]
    var favoriteAlbums: [String]
    var favoriteArtists: [String]

    var wallet: Wallet

    let createdAt: Date
}

struct TrackMeta: Codable {
    let url: String
    let artistName: String
    let trackName: String
}

struct BattleHistory: Codable {
    let id: UUID
    let date: Date
    var score: BattleScoreModel
}

struct BattleScoreModel: Codable {
    let playerScore: Int
    let botScore: Int
    let tracks: [TrackMeta]

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
