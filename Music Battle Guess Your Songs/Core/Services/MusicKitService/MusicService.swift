import Foundation
import MusicKit
import AVFoundation

final class MusicService {
    static let shared = MusicService()
    var topArtists = [FoundedArtist]()

    private init() {}

    // MARK: - Authorization

    func requestAuthorization() async throws {
        let status = await MusicAuthorization.request()

        guard status == .authorized else {
            throw AppError.musicAuthorizationDenied
        }
    }

    func start() {
        Logger.log("MusicService started 🔥")
    }

    // MARK: - Music Data Fetching

    func fetchArtists(query: String, limit count: Int = 2) async throws -> [Artist] {
        var searchRequest = MusicCatalogSearchRequest(term: query, types: [Artist.self])
        searchRequest.limit = count
        let response = try await searchRequest.response()
        let artists = Array(response.artists)
        print("fetchArtists: Queried '\(query)', found \(artists.count) artists")
        return artists
    }

    func preloadMusicKit() {
        Task {
            do {
                // Получаем топ-артистов из RemoteConfig
                let queries = [
                    RemoteConfigService.shared.topArtist1,
                    RemoteConfigService.shared.topArtist2,
                    RemoteConfigService.shared.topArtist3
                ]
                var artists: [Artist] = []
                for query in queries where !query.isEmpty {
                    let found = try await self.fetchArtists(query: query, limit: 1)
                    if let artist = found.first {
                        artists.append(artist)
                    }
                }
                self.topArtists = artists.map { FoundedArtist(id: $0.id.rawValue, name: $0.name) }
                Logger.log("top artists count \(self.topArtists.count)")
            } catch {
                print("fetch top artists error: \(error)")
            }
        }
    }

    // MARK: - Artist Tracks Mix

    func getMixedTracks(fromArtist artistID: String, total count: Int = 10) async throws -> [Track] {

        Logger.log("🎧 getMixedTracks start artistID: \(artistID)")

        let request = MusicCatalogResourceRequest<Artist>(
            matching: \.id,
            equalTo: MusicItemID(rawValue: artistID)
        )

        let response = try await request.response()
        Logger.log("📡 artist response items: \(response.items.count)")

        guard let artist = response.items.first else { return [] }

        let detailedArtist = try await artist.with([.albums])
        Logger.log("📡 loaded artist albums")

        guard let albums = detailedArtist.albums else { return [] }

        Logger.log("💿 albums total: \(albums.count)")

        var collectedTracks: [Track] = []
        let shuffledAlbums = albums.shuffled()

        for album in shuffledAlbums {

            Logger.log("➡️ request tracks album: \(album.title)")

            let albumWithTracks = try await album.with([.tracks])

            if let tracks = albumWithTracks.tracks {

                Logger.log("   ✅ received tracks: \(tracks.count)")

                collectedTracks.append(contentsOf: tracks)

                Logger.log("   📊 collected total: \(collectedTracks.count)")
            }

            if collectedTracks.count >= 30 {
                Logger.log("🛑 stop loading albums (>=30 tracks)")
                break
            }
        }

        Logger.log("🔀 shuffle collected: \(collectedTracks.count)")

        let result = Array(collectedTracks.shuffled().prefix(count))

        Logger.log("🎯 final result: \(result.count) tracks")

        return result
    }

    func getTracks(fromPlaylist playlistIdentifier: String, limit count: Int = 15) async throws -> [Track] {
        let playlistID = MusicItemID(rawValue: playlistIdentifier)
        let request = MusicCatalogResourceRequest<Playlist>(matching: \.id, equalTo: playlistID)
        let response = try await request.response()
        guard let playlist = response.items.first else { return [] }

        // Используем with([.tracks]) для надежного получения треков
        let tracks = try await playlist.with([.tracks]).tracks ?? []
        let allTracks = Array(tracks)

        // shuffle the full playlist and take random tracks
        let randomSelection = allTracks.shuffled().prefix(count)
        let result = Array(randomSelection)

        print("getTracks(fromPlaylist): Playlist ID '\(playlistIdentifier)', total tracks \(allTracks.count), returning random \(result.count)")

        for track in result {
            print("playlist track: \(track.title)")
        }

        return result
    }
}
