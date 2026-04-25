//
//  ImageLoader.swift
//  Music Trivia Guess Your Songs
//
//  Created by PowerMac on 17.02.2026.
//

import UIKit

protocol ImageServiceProtocol {
    func loadImage(from url: URL) async throws -> UIImage
}

final class ImageService: ImageServiceProtocol {

    private let loader: ImageLoaderProtocol

    init(loader: ImageLoaderProtocol) {
        self.loader = loader
    }

    func loadImage(from url: URL) async throws -> UIImage {
        try await loader.loadImage(from: url)
    }
}
