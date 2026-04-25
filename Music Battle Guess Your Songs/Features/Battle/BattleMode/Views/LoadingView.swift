import Foundation
import UIKit
import Lottie
import SnapKit

class BattleLoadingView: UIView {
    private let animationView = LottieAnimationView(name: "cosmo")
    private let gradientLayer = AppColors.mainGradient()
    private let loadingLabel = UILabel()
    private var loadingTexts = [
        "Collecting tracks 🎵",
        "Searching artists 🕵️‍♂️",
        "Requesting permissions 📝",
        "Counting beats 🥁",
        "Tuning guitars 🎸",
        "Mixing magic ✨",
        "Finding lyrics 🔍",
        "Hunting basslines 🎚️",
        "Loading vibes 😎",
        "Summoning playlists 🧙‍♂️",
        "Polishing notes 📝",
        "Shuffling cosmos 🌌"
    ]
    private var currentTextIndex = 0
    private var timer: Timer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
        setupUI()
        startAnimation()
        startTextAnimation()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
        setupUI()
        startAnimation()
        startTextAnimation()
    }

    // MARK: - Setup

    private func setupGradient() {
        layer.insertSublayer(gradientLayer, at: 0)
    }

    private func setupUI() {
        animationView.loopMode = .loop
        animationView.contentMode = .scaleAspectFit

        addSubview(animationView)

        animationView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-10)
            make.size.equalTo(350)
        }

        loadingLabel.font = AppFonts.title()
        loadingLabel.textColor = .white
        loadingLabel.textAlignment = .center
        loadingLabel.text = loadingTexts.first

        addSubview(loadingLabel)

        loadingLabel.snp.makeConstraints { make in
            make.top.equalTo(animationView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    // MARK: - Animation

    func startAnimation() {
        animationView.play()
    }

    private func startTextAnimation() {
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.currentTextIndex = (self.currentTextIndex + 1) % self.loadingTexts.count
            UIView.transition(with: loadingLabel,
                              duration: 0.3,
                              options: [.transitionCrossDissolve],
                              animations: {
                                  self.loadingLabel.text = self.loadingTexts[self.currentTextIndex]
                              },
                              completion: nil)
        }
    }

    deinit {
        timer?.invalidate()
        Logger.log("Deinit")
    }
}
