import Foundation
import MusicKit
import Combine

enum PlaylistType {
    case trending
    case tiktok
    case hits2010
    case hits2026

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

final class BattleModeViewModel: ObservableObject {
    
    private let musicService: MusicService
    
    @Published var tracksPlayCount = RemoteConfigService.shared.trackPlayCount
    @Published var artists: [FoundedArtist] = CashedArtistService.shared.provideTopArtists()

    init(musicService: MusicService) {
        self.musicService = musicService
    }

    // MARK: - Loaders

    func loadPlaylist(_ type: PlaylistType) async throws -> [Track] {
        do {
            return try await musicService.getTracks(fromPlaylist: type.playlistId,
                                                    limit: tracksPlayCount)
        } catch {
            ErrorHandler.shared.handle(error)
            return []
        }
    }
    
    func loadMix(artist: FoundedArtist) async throws -> [Track] {
        let mix = try await MusicService.shared.getMixedTracks(fromArtist: artist.id, total: self.tracksPlayCount)
        return mix
    }

    // MARK: - User Actions

    func didConfirmTrackSelection(text: String?) async {
        guard let selectedText = text, !selectedText.isEmpty else {
            print("⚠️ No track text was selected.")
            return
        }

        print("✅ User confirmed track selection: \(selectedText)")

        do {
            let fetchedArtists = try await musicService.fetchArtists(query: selectedText, limit: 2)

            let foundedArtists = fetchedArtists.map {
                FoundedArtist(id: $0.id.rawValue, name: $0.name)
            }

            artists = foundedArtists + CashedArtistService.shared.provideTopArtists()

        } catch {
            ErrorHandler.shared.handle(error)
        }
    }
    
    func saveSliderValue() {
        
    }
    
    func provideSliderValue() {
        
    }
}
