import FirebaseRemoteConfig

struct ArtistImagesResponse: Decodable {
    let artistImages: [String]

    enum CodingKeys: String, CodingKey {
        case artistImages = "artist_images"
    }
}

final class RemoteConfigService {
    static let shared = RemoteConfigService()

    private let remoteConfig: RemoteConfig

    private init() {
        remoteConfig = RemoteConfig.remoteConfig()

        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 1
        remoteConfig.configSettings = settings

        remoteConfig.setDefaults([
            "login_title": "Music Battle ⚔️" as NSObject,
            "login_subtitle": "Millions of songs. Real‑time battles." as NSObject,
            "login_integrations_text": "Powered by Apple Music" as NSObject,
            "login_show_integrations": true as NSObject,
            "login_show_artists_carousel": true as NSObject,
            "login_artist_images_json": """
            { "artist_images": [] }
            """ as NSObject,
            "trending_playlist_id": "pl.b7ae3e0a28e84c5c96c4284b6a6c70af" as NSObject,
            "tiktok_hits_playlist_id": "pl.3444172d6182455d9b9ca494b85a87fa" as NSObject,
            "hits_2010_playlist_id": "pl.e5afef10eb2544d0a38880fd8e2c9a27" as NSObject,
            "hits_2026_playlist_id": "pl.f4d106fed2bd41149aaacabb233eb5eb" as NSObject,
            "top_artist_1": "Kendrick Lamar" as NSObject,
            "top_artist_2": "Taylor Swift" as NSObject,
            "top_artist_3": "Imagine Dragons" as NSObject,
            "track_play_count": 7 as NSObject,
            "ad_id": "" as NSObject,
            "revenueCatApiKey": "" as NSObject,
            "adapty_key": "" as NSObject,
            "terms": "https://t.me/MusicBattleTerms" as NSObject,
            "privacy": "https://t.me/musicBattlePrivacy" as NSObject,
            "amplitude_unified": "" as NSObject
        ])
    }

    // We call MusicService.shared.preloadMusicKit() here inside the fetchAndActivate callback
    // to guarantee that Remote Config values have been fetched and activated.
    // This ensures that any data MusicService relies on from Remote Config is up-to-date.
    // Calling it outside the callback could result in using stale or default values.
    // MusicService.shared.preloadMusicKit()
    func fetch(completion: ((Bool) -> Void)? = nil) {
        remoteConfig.fetchAndActivate { status, error in
            let updated = (status == .successFetchedFromRemote || status == .successUsingPreFetchedData)
            completion?(updated && error == nil)
            Logger.log("firebase config: fetched 🔥")
            MusicService.shared.preloadMusicKit()
        }
    }

    // MARK: - Exposed values

    var loginTitle: String {
        remoteConfig["login_title"].stringValue
    }

    var loginSubtitle: String {
        remoteConfig["login_subtitle"].stringValue
    }

    var loginIntegrationsText: String {
        remoteConfig["login_integrations_text"].stringValue
    }

    var loginShowIntegrations: Bool {
        remoteConfig["login_show_integrations"].boolValue
    }

    var loginShowArtistsCarousel: Bool {
        remoteConfig["login_show_artists_carousel"].boolValue
    }
    var loginArtistImageURLs: [URL] {
        Logger.log("requested artist images from remote config 🎶")
        let jsonString = remoteConfig["login_artist_images_json"].stringValue
        guard let data = jsonString.data(using: .utf8) else {
            return []
        }

        do {
            let decoded = try JSONDecoder().decode(ArtistImagesResponse.self, from: data)
            return decoded.artistImages.compactMap { URL(string: $0) }
        } catch {
            print("RemoteConfig decode error:", error)
            return []
        }
    }

    var trendingPlaylistId: String {
        remoteConfig["trending_playlist_id"].stringValue
    }

    var tiktokHitsPlaylistId: String {
        remoteConfig["tiktok_hits_playlist_id"].stringValue
    }

    var hits2010PlaylistId: String {
        remoteConfig["hits_2010_playlist_id"].stringValue
    }

    var hits2026PlaylistId: String {
        remoteConfig["hits_2026_playlist_id"].stringValue
    }

    var topArtist1: String {
        remoteConfig["top_artist_1"].stringValue
    }

    var topArtist2: String {
        remoteConfig["top_artist_2"].stringValue
    }

    var topArtist3: String {
        remoteConfig["top_artist_3"].stringValue
    }

    var trackPlayCount: Int {
        remoteConfig["track_play_count"].numberValue.intValue
    }

    var addId: String {
        remoteConfig["ad_id"].stringValue
    }

    var adaptyKey: String {
        remoteConfig["adapty_key"].stringValue
    }
    
    var terms: String {
        remoteConfig["terms"].stringValue
    }
    
    var privacy: String {
        remoteConfig["privacy"].stringValue
    }
    
    var amplitudeUnifiedKey: String {
        remoteConfig["amplitude_unified"].stringValue
    }
}
