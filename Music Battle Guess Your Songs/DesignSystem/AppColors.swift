import UIKit

enum AppColors {

    // MARK: - Base

    static let background = UIColor.black
    static let white = UIColor.white

    // MARK: - Brand

    static let accentPink = UIColor(
        red: 0.90,
        green: 0.20,
        blue: 0.70,
        alpha: 1
    )

    static let answerButtonBackground = UIColor.white.withAlphaComponent(0.2)

    static let foundedArtistCellPink = UIColor(red: 0.6, green: 0.4, blue: 0.8, alpha: 0.5) // soft purple, semi-transparent

    static let accentBlue = UIColor(
        red: 0.30,
        green: 0.20,
        blue: 0.80,
        alpha: 1
    )
    
    static let accentGold = UIColor(red: 0.90, green: 0.70, blue: 0.30, alpha: 1)
    
    static let accentPinkButton = UIColor(
        red: 0.90,
        green: 0.20,
        blue: 0.70,
        alpha: 1
    )

    static let playerProgressTint: UIColor = .green.withAlphaComponent(0.8)
    static let oppProgressTint = UIColor(
        red: 0.90,
        green: 0.20,
        blue: 0.70,
        alpha: 1
    )

    // MARK: - UI

    static let buttonBackground = UIColor.white.withAlphaComponent(0.15)

    // MARK: - Gradients

    static func mainGradient() -> CAGradientLayer {
        let layer = CAGradientLayer()
        layer.colors = [
            accentPink.cgColor,
            accentBlue.cgColor,
            background.cgColor
        ]
        layer.locations = [0.0, 0.5, 1.0]
        layer.startPoint = CGPoint(x: 0.5, y: 0.0)
        layer.endPoint = CGPoint(x: 0.5, y: 1.0)
        return layer
    }

    // MARK: - Home Buttons

    static let homePrimary = UIColor.white

    static let homePrimaryTint = UIColor(
        red: 108/255,
        green: 92/255,
        blue: 231/255,
        alpha: 1
    )

    static let homeLogout = UIColor.systemRed
    static let homeLogoutTint = UIColor.systemRed.withAlphaComponent(0.25)
}
