import UIKit

protocol ImageLoaderProtocol {
    func loadImage(from url: URL) async throws -> UIImage
}

final class DiskImageLoader: ImageLoaderProtocol {

    private let session: URLSession
    private var runningTasks: [URL: Task<UIImage, Error>] = [:]

    init() {
        // URLCache for HTTP
        let config = URLSessionConfiguration.default
        config.urlCache = URLCache.shared
        config.requestCachePolicy = .useProtocolCachePolicy
        self.session = URLSession(configuration: config)
    }

    func loadImage(from url: URL) async throws -> UIImage {

        Logger.log("➡️ Request image: \(url.absoluteString)")

        // 2️⃣ Deduplication
        if let task = runningTasks[url] {
            Logger.log("♻️ Using existing running task (deduplicated)")
            return try await task.value
        }

        Logger.log("🌍 Starting network download...")

        // 3️⃣ Network
        let task = Task { () throws -> UIImage in
            defer {
                runningTasks[url] = nil
                Logger.log("🧹 Task removed from runningTasks")
            }

            let (data, _) = try await session.data(from: url)

            Logger.log("⬇️ Download finished. Bytes: \(data.count)")

            guard let image = UIImage(data: data) else {
                Logger.log("❌ Failed to create UIImage from data")
                throw URLError(.badServerResponse)
            }
            return image
        }

        runningTasks[url] = task
        Logger.log("🚀 Task stored in runningTasks")

        return try await task.value
    }
}
