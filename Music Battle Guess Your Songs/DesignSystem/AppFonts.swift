import UIKit

enum AppFonts {

    static func title(_ size: CGFloat = 28) -> UIFont {
        .systemFont(ofSize: size, weight: .bold)
    }

    static func subtitle(_ size: CGFloat = 18) -> UIFont {
        .systemFont(ofSize: size, weight: .bold)
    }

    static func caption(_ size: CGFloat = 13) -> UIFont {
        .systemFont(ofSize: size, weight: .semibold)
    }

    static func primaryButton(_ size: CGFloat = 18) -> UIFont {
        .systemFont(ofSize: size, weight: .bold)
    }

    static func primaryStartBattleButton(_ size: CGFloat = 20) -> UIFont {
        .systemFont(ofSize: size, weight: .bold)
    }

    static func foundedArtistCell(_ size: CGFloat = 18) -> UIFont {
        .systemFont(ofSize: size, weight: .bold)
    }

    static func profile(_ size: CGFloat = 16) -> UIFont {
        .systemFont(ofSize: size, weight: .semibold)
    }

    static func wallet(_ size: CGFloat = 16) -> UIFont {
        .systemFont(ofSize: size, weight: .bold)
    }

    static func button(_ size: CGFloat = 16) -> UIFont {
        .systemFont(ofSize: size, weight: .semibold)
    }

    static func stats(_ size: CGFloat = 16) -> UIFont {
        .systemFont(ofSize: size, weight: .semibold)
    }

    static func body(_ size: CGFloat = 14) -> UIFont {
        .systemFont(ofSize: size, weight: .regular)
    }

    static func rating(_ size: CGFloat = 12) -> UIFont {
        .systemFont(ofSize: size, weight: .semibold)
    }

    static func badge(_ size: CGFloat = 16) -> UIFont {
        .systemFont(ofSize: size, weight: .bold)
    }
}
