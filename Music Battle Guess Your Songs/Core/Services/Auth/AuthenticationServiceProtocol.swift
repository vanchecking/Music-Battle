//
//  AuthenticationServiceProtocol.swift
//  Music Trivia Guess Your Songs
//
//  Created by PowerMac on 12.02.2026.
//
import Foundation
import AuthenticationServices

protocol AuthenticationServiceProtocol {
    func signInWithApple() async throws -> AppleUser
}
