//
//  AppleAuthenticationService.swift
//  Music Trivia Guess Your Songs
//
//  Created by PowerMac on 12.02.2026.
//

import Foundation
import AuthenticationServices
import UIKit

struct AppleUser {
    let userId: String
    let email: String?
    let fullName: String?
}

final class AppleAuthenticationService: NSObject, AuthenticationServiceProtocol {
    private var completion: ((Result<AppleUser, Error>) -> Void)?

    // takes user credentials
    func signInWithApple() async throws -> AppleUser {
        return try await withCheckedThrowingContinuation { continuation in
            self.completion = { result in
                switch result {
                case .success(let user):
                    continuation.resume(returning: user)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }

            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]

            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self

            controller.performRequests()
        }
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension AppleAuthenticationService: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userId = credential.user
            let email = credential.email
            let fullName = credential.fullName?.formatted()
            let user = AppleUser(userId: userId, email: email, fullName: fullName)
            completion?(.success(user))
        } else {
            completion?(.failure(AppError.invalidCredential))
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        completion?(.failure(error))
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension AppleAuthenticationService: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        let keyWindow = UIApplication.shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
        return keyWindow ?? UIWindow()
    }
}
