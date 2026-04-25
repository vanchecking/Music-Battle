//
//  GreetingsProvider.swift
//  Music Battle Guess Your Songs
//
//  Created by PowerMac on 20.03.2026.
//

import Foundation

final class GreetingsProvider {
    static func greetingText() -> String {
        let hour = Calendar.current.component(.hour, from: Date())

        switch hour {
        case 5..<12:
            return "Good morning ☀️"
        case 12..<18:
            return "Good afternoon 🌤"
        case 18..<23:
            return "Good evening 🎃"
        default:
            return "Good night 🌚"
        }
    }
}
