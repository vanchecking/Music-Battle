import UIKit

// This file defines mock data for artist images used in the app,
// combining local asset placeholders with optional remote URLs for loading images dynamically.

struct ArtistImage {
    // Represents an artist's image with an optional remote URL,
    // a local placeholder asset name, and a cached loaded UIImage.
    var url: URL?
    let assetPlaceholder: String
    var loadedImage: UIImage?
}

enum PlaceholderArtists {
    // Provides a static method to retrieve the top twelve artist images,
    // pairing local placeholder names with remote URLs if available.
    static func topTwelve(remoteURLs: [URL?]) -> [ArtistImage] {
        // List of local asset names used as placeholders for artist images.
        let placeholders = [
            "badbunny",
            "tailorSwift",
            "theWeeknd",
            "drake",
            "billieEilish",
            "kendrickLamar",
            "brunoMars",
            "arianaGrande",
            "arjitSingh",
            "justinBieber",
            "edSheeran",
            "rihanna"
        ]

        // Remote URLs fetched from a configuration service, intended to replace placeholders when available.

        // Map each placeholder to an ArtistImage, assigning the corresponding remote URL if it exists.
        return placeholders.enumerated().map { index, name in

            // Assign remote URL if available, otherwise nil.
            let url = index < remoteURLs.count ? remoteURLs[index] : nil
            return ArtistImage(
                url: url,
                assetPlaceholder: name,
                loadedImage: nil
            )
        }
    }
}
