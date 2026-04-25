//
//  CardView.swift
//  Music Battle Guess Your Songs
//
//  Created by PowerMac on 07.03.2026.
//

import UIKit
import SnapKit

final class CardView: UIView {

    private let blurView = UIVisualEffectView(
        effect: UIBlurEffect(style: .systemThinMaterial)
    )

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    private func setup() {
        layer.cornerRadius = 16
        layer.masksToBounds = true

        addSubview(blurView)

        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        layer.borderWidth = 1
        layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
    }
}
