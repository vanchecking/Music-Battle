import Foundation

enum AppError: Error {
    case network
    case musicAuthorizationDenied
    case musicUnavailable
    case decoding
    case unknown(Error)
    case invalidCredential
    case noUser
    case noTracks

    // MARK: - Subscriptions (Adapty)
    case adaptyNotActivated
    case paywallNotFound
    case productsNotFound
    case purchaseFailed
    case profileNotFound
    case accessLevelMissing
}

extension AppError: LocalizedError {

    /// User-facing error message (ready for localization)
    var errorDescription: String? {
        switch self {
        case .network:
            return NSLocalizedString("error.network", comment: "Network error message")
        case .musicAuthorizationDenied:
            return NSLocalizedString("error.music.denied", comment: "Apple Music access denied")
        case .musicUnavailable:
            return NSLocalizedString("error.music.unavailable", comment: "Music unavailable")
        case .decoding:
            return NSLocalizedString("error.decoding", comment: "Decoding error")
        case .invalidCredential:
            return NSLocalizedString("error.invalidCredential", comment: "Invalid Credential")
        case .adaptyNotActivated:
            return NSLocalizedString("error.adapty.notActivated", comment: "Adapty not activated")
        case .paywallNotFound:
            return NSLocalizedString("error.adapty.paywallNotFound", comment: "Paywall not found")
        case .productsNotFound:
            return NSLocalizedString("error.adapty.productsNotFound", comment: "Products not found")
        case .purchaseFailed:
            return NSLocalizedString("error.adapty.purchaseFailed", comment: "Purchase failed")
        case .profileNotFound:
            return NSLocalizedString("error.adapty.profileNotFound", comment: "Profile not found")
        case .accessLevelMissing:
            return NSLocalizedString("error.adapty.accessLevelMissing", comment: "Access level missing")
        case .unknown(let error):
            return "We working on it. Try again later."
        case .noUser:
            return NSLocalizedString("error.noUserId", comment: "User not found")
        case .noTracks:
            return NSLocalizedString("error.noTracks", comment: "No Tracks")
        }
    }

    /// Optional title for alerts (UI-ready)
    var title: String {
        switch self {
        case .noTracks:
            return NSLocalizedString("error.title.noTracks", comment: "")
        case .network:
            return NSLocalizedString("error.title.network", comment: "")
        case .musicAuthorizationDenied:
            return NSLocalizedString("error.title.music", comment: "")
        case .musicUnavailable:
            return NSLocalizedString("error.title.music", comment: "")
        case .decoding:
            return NSLocalizedString("error.title.decoding", comment: "")
        case .adaptyNotActivated,
             .paywallNotFound,
             .productsNotFound,
             .purchaseFailed,
             .profileNotFound,
             .accessLevelMissing:
            return NSLocalizedString("error.title.subscription", comment: "")
        case .unknown:
            return NSLocalizedString("error.title.unknown", comment: "")
        case .invalidCredential:
            return NSLocalizedString("error.title.invalidCredential", comment: "")
        case .noUser:
            return NSLocalizedString("error.title.noUserId", comment: "")
        }

    }
}
