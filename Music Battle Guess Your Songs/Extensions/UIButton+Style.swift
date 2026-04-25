import UIKit

enum ButtonStyle {
    case primary
    case logout
}

extension UIButton {

    func applyStartBattleStyle(title: String) {
        var config = UIButton.Configuration.borderedProminent()
        config.baseBackgroundColor = AppColors.accentPinkButton
        config.baseForegroundColor = AppColors.white
        config.cornerStyle = .medium
        config.title = title
        config.attributedTitle = AttributedString(
            title,
            attributes: AttributeContainer([
                .font: AppFonts.primaryStartBattleButton()
            ])
        )
        self.configuration = config
    }

    func applyHomeStyle(title: String, style: ButtonStyle) {
        var config: UIButton.Configuration

        switch style {
        case .primary:
            config = UIButton.Configuration.borderedProminent()
            config.baseBackgroundColor = AppColors.homePrimaryTint
            config.baseForegroundColor = AppColors.homePrimary

        case .logout:
            config = UIButton.Configuration.plain()
            config.baseForegroundColor = AppColors.homeLogout
        }

        config.title = title
        config.cornerStyle = .medium

        if style == .primary {
            config.attributedTitle = AttributedString(
                title,
                attributes: AttributeContainer([
                    .font: AppFonts.primaryButton()
                ])
            )
        }

        self.configuration = config
    }
}
