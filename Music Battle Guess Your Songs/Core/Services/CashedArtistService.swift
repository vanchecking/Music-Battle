//
//  CashedArtistService.swift
//  Music Battle Guess Your Songs
//
//  Created by PowerMac on 11.03.2026.
//

import Foundation

struct FoundedArtist: Codable, Hashable {
    let id: String
    let name: String
}

final class CashedArtistService {
    static let shared = CashedArtistService()
    let artistCashLimit = 3
    private let userDefaultsKey = "cachedArtists"
    private var cachedArtists: [FoundedArtist] = []

    private init() {
        self.cachedArtists = self.fetchArtistsFromStorage()
    }

    func allArtists() -> [FoundedArtist] {
        return cachedArtists
    }

    func addArtist(_ artist: FoundedArtist) {
        if let existingIndex = cachedArtists.firstIndex(of: artist) {
            cachedArtists.remove(at: existingIndex)
        }
        cachedArtists.insert(artist, at: 0)
        if cachedArtists.count > artistCashLimit {
            cachedArtists = Array(cachedArtists.prefix(artistCashLimit))
        }
        saveArtistsToStorage()
    }

    func provideTopArtists() -> [FoundedArtist] {
        let cached = allArtists()
        if !cached.isEmpty {
            return cached
        } else {
            return MusicService.shared.topArtists.map { artist in
                FoundedArtist(id: artist.id, name: artist.name)
            }
        }
    }

    // MARK: - Private
    private func fetchArtistsFromStorage() -> [FoundedArtist] {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else {
            return []
        }
        do {
            let artists = try JSONDecoder().decode([FoundedArtist].self, from: data)
            return artists
        } catch {
            print("Failed to decode cached artists: \(error)")
            return []
        }
    }

    private func saveArtistsToStorage() {
        do {
            let data = try JSONEncoder().encode(cachedArtists)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
            Logger.log("artist cache saved \(cachedArtists.count)")
        } catch {
            print("Failed to encode cached artists: \(error)")
        }
    }
}
