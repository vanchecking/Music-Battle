//
//  AuthStorage.swift
//  Music Battle Guess Your Songs
//
//  Created by PowerMac on 01.03.2026.
//

final class AuthStorage {

    static let shared = AuthStorage()

    private let keychain = KeychainService.shared
    private let userKey = "apple_user_id"
    var onLogin: ((_ id: String) -> Void)?

    private init() {}

    var appleUserID: String? {
        keychain.read(for: userKey)
    }

    func saveUserID(_ id: String) {
        Logger.log("saved user id 🪪")
        keychain.save(id, for: userKey)
        self.onLogin?(id)
    }

    func logoutUser() {
        keychain.delete(for: userKey)
    }

    var isLoggedIn: Bool {
        appleUserID != nil
    }
}
