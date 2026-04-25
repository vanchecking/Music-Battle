import Foundation
import MusicKit
import Combine

// MARK: - Playlist Types
enum PlaylistType {
    case trending
    case tiktok
    case hits2010
    case hits2026

    // Remote-config driven playlist IDs
    var playlistId: String {
        switch self {
        case .trending:
            return RemoteConfigService.shared.trendingPlaylistId
        case .tiktok:
            return RemoteConfigService.shared.tiktokHitsPlaylistId
        case .hits2010:
            return RemoteConfigService.shared.hits2010PlaylistId
        case .hits2026:
            return RemoteConfigService.shared.hits2026PlaylistId
        }
    }
}

// MARK: - Battle Mode ViewModel
final class BattleModeViewModel: ObservableObject {

    private let musicService: MusicService

    // Number of tracks to load per session (from remote config)
    @Published var tracksPlayCount = RemoteConfigService.shared.trackPlayCount

    // Cached / fetched artists for UI
    @Published var artists: [FoundedArtist] = CashedArtistService.shared.provideTopArtists()

    init(musicService: MusicService) {
        self.musicService = musicService
    }

    // MARK: - Data Loading

    // Load tracks from a playlist
    func loadPlaylist(_ type: PlaylistType) async throws -> [Track] {
        do {
            return try await musicService.getTracks(
                fromPlaylist: type.playlistId,
                limit: tracksPlayCount
            )
        } catch {
            ErrorHandler.shared.handle(error)
            return []
        }
    }

    // Load a mixed track set based on artist
    func loadMix(artist: FoundedArtist) async throws -> [Track] {
        let mix = try await MusicService.shared.getMixedTracks(
            fromArtist: artist.id,
            total: tracksPlayCount
        )
        return mix
    }

    // MARK: - User Actions

    // Called when user confirms selected track text
    func didConfirmTrackSelection(text: String?) async {
        guard let selectedText = text, !selectedText.isEmpty else {
            print("⚠️ No track text was selected.")
            return
        }

        print("✅ User confirmed track selection: \(selectedText)")

        do {
            // Fetch artists matching query
            let fetchedArtists = try await musicService.fetchArtists(
                query: selectedText,
                limit: 2
            )

            // Map API models into local model
            let foundedArtists = fetchedArtists.map {
                FoundedArtist(id: $0.id.rawValue, name: $0.name)
            }

            // Merge with cached popular artists
            artists = foundedArtists + CashedArtistService.shared.provideTopArtists()

        } catch {
            ErrorHandler.shared.handle(error)
        }
    }
}
