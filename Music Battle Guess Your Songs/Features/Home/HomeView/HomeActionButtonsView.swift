import UIKit
import SnapKit

final class HomeActionButtonsView: UIView {

    let startBattleButton = UIButton(type: .system)
    let battleHistoryButton = UIButton(type: .system)
    let premiumButton = UIButton(type: .system)
    let logoutButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        let buttons: [(UIButton, String, ButtonStyle)] = [
            (startBattleButton, "Start Battle ⚔️", .primary),
            (premiumButton, "Premium 💎", .primary),
            (battleHistoryButton, "Battle History 📜", .primary),
            (logoutButton, "Logout", .logout)
        ]

        buttons.forEach { button, title, style in
            if button == startBattleButton {
                button.applyStartBattleStyle(title: title)
            } else {
                button.applyHomeStyle(title: title, style: style)
            }
        }

        let stackView = UIStackView(arrangedSubviews: buttons.map { $0.0 })
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .fill

        addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview() // fill the parent view
        }

        // Optional: set button heights
        buttons.forEach { button, _, _ in
            button.snp.makeConstraints { make in
                make.height.equalTo(button == startBattleButton ? 70 : 50)
            }
        }
    }
}
