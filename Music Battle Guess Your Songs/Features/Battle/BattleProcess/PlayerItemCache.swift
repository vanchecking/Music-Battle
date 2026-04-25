//
//  PlayerItemCache.swift
//  Music Battle Guess Your Songs
//
//  Created by PowerMac on 23.03.2026.
//
import AVFoundation
final class PlayerItemCache {

    static let shared = PlayerItemCache()

    private var cache: [URL: AVPlayerItem] = [:]
    private let maxSize = RemoteConfigService.shared.trackPlayCount * 2

    func item(for url: URL) -> AVPlayerItem {
        if let cached = cache[url] {
            Logger.log("Cache hit: \(url)")
            return cached
        }

        Logger.log("Cache miss: \(url)")
        let item = AVPlayerItem(url: url)
        item.preferredForwardBufferDuration = 30
        item.canUseNetworkResourcesForLiveStreamingWhilePaused = true

        insert(item, for: url)
        return item
    }

    private func insert(_ item: AVPlayerItem, for url: URL) {
        if cache.count >= maxSize {
            let firstKey = cache.keys.first!
            cache.removeValue(forKey: firstKey)
        }
        cache[url] = item
    }

    func clear() {
        cache.removeAll()
    }
}
