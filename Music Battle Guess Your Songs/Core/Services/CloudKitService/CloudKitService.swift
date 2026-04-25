import Foundation
import CloudKit
import Combine

final class CloudKitService {
    static let shared = CloudKitService()

    private let container: CKContainer
    private let database: CKDatabase
    @Published var currentUser: UserProfile?

    private init() {
        container = CKContainer.default()
        database = container.privateCloudDatabase
    }
}

// MARK: - Fetch
extension CloudKitService {

    func fetchUserProfile(userID: String) async throws -> UserProfile {

        let recordID = CKRecord.ID(recordName: userID)
        let record = try await database.record(for: recordID)
        let user = map(record)
        currentUser = user
        return user
    }

    func fetchOrCreateUserProfile(
        userID: String,
        email: String?,
        nickname: String
    ) async throws -> UserProfile {

        do {
            return try await fetchUserProfile(userID: userID)
        } catch let error as CKError where error.code == .unknownItem {
            return try await createUserProfile(
                userID: userID,
                email: email,
                nickname: nickname
            )
        }
    }

    func loadBattleHistory(userID: String) async throws -> [BattleHistory] {
        let predicate = NSPredicate(format: "userID == %@", userID)
        let query = CKQuery(recordType: "BattleHistory", predicate: predicate)

        let result = try await database.records(matching: query)

        return result.matchResults.compactMap { _, res in
            guard case .success(let record) = res else { return nil }

            guard
                let idString = record["id"] as? String,
                let id = UUID(uuidString: idString),
                let date = record["date"] as? Date,
                let playerScore = record["playerScore"] as? Int,
                let botScore = record["botScore"] as? Int,
                let tracksData = record["tracks"] as? Data
            else { return nil }

            let tracks = (try? JSONDecoder().decode([TrackMeta].self, from: tracksData)) ?? []

            let score = BattleScoreModel(
                playerScore: playerScore,
                botScore: botScore,
                tracks: tracks
            )

            return BattleHistory(id: id, date: date, score: score)
        }
    }
}

// MARK: - Create
extension CloudKitService {

    func createUserProfile(
        userID: String,
        email: String?,
        nickname: String
    ) async throws -> UserProfile {

        let recordID = CKRecord.ID(recordName: userID)
        let record = CKRecord(recordType: "UserProfile", recordID: recordID)

        record["userID"] = userID as CKRecordValue
        record["email"] = email as CKRecordValue?
        record["nickname"] = nickname as CKRecordValue

        record["totalWins"] = 0 as CKRecordValue
        record["totalBattles"] = 0 as CKRecordValue
        record["rating"] = 0.0 as CKRecordValue

        record["coins"] = 0 as CKRecordValue
        record["gems"] = 0 as CKRecordValue

        record["createdAt"] = Date() as CKRecordValue

        let saved = try await database.save(record)
        let user = map(saved)
        currentUser = user
        return user
    }
}

// MARK: - Partial Profile Update
extension CloudKitService {

    func updateBasicProfile(
        userID: String,
        nickname: String?,
        email: String?
    ) async throws {

        try await modifyRecord(userID: userID) { record in
            if let nickname { record["nickname"] = nickname as CKRecordValue }
            if let email { record["email"] = email as CKRecordValue }
        }

        if var currentUser, currentUser.userID == userID {
            if let nickname { currentUser.nickname = nickname }
            if let email { currentUser.email = email }
            self.currentUser = currentUser
        }
    }

    func updateStats(isWin: Bool, rating: Double? = nil) async throws {
        guard let userID = currentUser?.userID else { return }

        try await modifyRecord(userID: userID) { record in
            // Бои
            let battles = (record["totalBattles"] as? Int ?? 0) + 1
            record["totalBattles"] = battles as CKRecordValue

            // Победы
            if isWin {
                let wins = (record["totalWins"] as? Int ?? 0) + 1
                record["totalWins"] = wins as CKRecordValue
            }

            // Рейтинг (ИНКРЕМЕНТ)
            if let rating {
                let currentRating = record["rating"] as? Double ?? 0
                record["rating"] = (currentRating + rating) as CKRecordValue
            }
        }

        // Кэш
        if var currentUser, currentUser.userID == userID {
            currentUser.totalBattles += 1
            if isWin { currentUser.totalWins += 1 }
            if let rating { currentUser.rating += rating }
            self.currentUser = currentUser
        }
    }
}

// MARK: - Wallet (Atomic + Retry Safe)
extension CloudKitService {

    func updateWallet(
        userID: String,
        change: @escaping (inout Wallet) -> Void
    ) async throws -> Wallet {

        return try await retrying(userID: userID) { record in

            let coins = record["coins"] as? Int ?? 0
            let gems = record["gems"] as? Int ?? 0

            var wallet = Wallet(coins: coins, gems: gems)
            change(&wallet)

            record["coins"] = wallet.coins as CKRecordValue
            record["gems"] = wallet.gems as CKRecordValue

            return wallet
        }
    }
}

// MARK: - Battle History
extension CloudKitService {

    func addBattle(userID: String, history: BattleHistory) async throws {
        let record = CKRecord(recordType: "BattleHistory")

        record["userID"] = userID as CKRecordValue
        record["id"] = history.id.uuidString as CKRecordValue
        record["date"] = history.date as CKRecordValue
        record["playerScore"] = history.score.playerScore as CKRecordValue
        record["botScore"] = history.score.botScore as CKRecordValue

        let tracksData = try JSONEncoder().encode(history.score.tracks)
        record["tracks"] = tracksData as CKRecordValue

        try await database.save(record)
    }
}

// MARK: - Delete
extension CloudKitService {

    func deleteUserProfile(userID: String) async throws {
        let id = CKRecord.ID(recordName: userID)
        try await database.deleteRecord(withID: id)
    }
}

// MARK: - Core Modify Logic (Retry on Conflict)
private extension CloudKitService {

    func modifyRecord(
        userID: String,
        change: @escaping (CKRecord) -> Void
    ) async throws {

        _ = try await retrying(userID: userID) { record in
            change(record)
            return ()
        }
    }

    func retrying<T>(
        userID: String,
        change: @escaping (CKRecord) throws -> T
    ) async throws -> T {

        let recordID = CKRecord.ID(recordName: userID)

        while true {
            do {
                let record = try await database.record(for: recordID)
                let result = try change(record)

                try await database.save(record)

                return result

            } catch let error as CKError
                where error.code == .serverRecordChanged {
                continue
            }
        }
    }
}

// MARK: - Mapping
private extension CloudKitService {

    func map(_ record: CKRecord) -> UserProfile {

        let coins = record["coins"] as? Int ?? 0
        let gems = record["gems"] as? Int ?? 0

        return UserProfile(
            userID: record["userID"] as? String ?? "",
            email: record["email"] as? String,
            nickname: record["nickname"] as? String ?? "Player",
            totalWins: record["totalWins"] as? Int ?? 0,
            totalBattles: record["totalBattles"] as? Int ?? 0,
            rating: record["rating"] as? Double ?? 0,
            favoriteGenres: record["favoriteGenres"] as? [String] ?? [],
            favoriteSongs: record["favoriteSongs"] as? [String] ?? [],
            favoriteAlbums: record["favoriteAlbums"] as? [String] ?? [],
            favoriteArtists: record["favoriteArtists"] as? [String] ?? [],
            wallet: Wallet(coins: coins, gems: gems),
            createdAt: record["createdAt"] as? Date ?? Date()
        )
    }
}
