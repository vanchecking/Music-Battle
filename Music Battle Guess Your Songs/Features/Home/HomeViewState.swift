//
//  HomeViewState.swift
//  Music Battle Guess Your Songs
//

import Foundation

enum HomeViewState {

    case loading
    case content(Content)
    case error(String)

    struct Content {
        let nickname: String
        let rating: Double
        let wins: Int
        let battles: Int
        let coins: Int
        let gems: Int
    }
}
