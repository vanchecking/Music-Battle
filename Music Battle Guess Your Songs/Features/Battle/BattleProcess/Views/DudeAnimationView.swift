import UIKit
import SnapKit
import Lottie

final class DudeAnimationView: UIView {

    private var playerProgressBar: UIProgressView!
    private var oppProgressBar: UIProgressView!
    private let initialProgress: Float = 0.5
    private let cosmoView = LottieAnimationView(name: "cosmo")

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        startAnimations()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        startAnimations()
    }

    private func setupViews() {
        // Cosmo animation (main)
        cosmoView.loopMode = .loop
        cosmoView.contentMode = .scaleAspectFit
        addSubview(cosmoView)
        cosmoView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(180)
        }
//        cosmoView.layer.borderColor = UIColor.red.cgColor
//        cosmoView.layer.borderWidth = 2

        // Player Progress Bar (vertical)
        playerProgressBar = UIProgressView(progressViewStyle: .default)
        playerProgressBar.progress = initialProgress
        playerProgressBar.transform = CGAffineTransform(rotationAngle: -.pi / 2)
        playerProgressBar.progressTintColor = AppColors.playerProgressTint
        addSubview(playerProgressBar)
        playerProgressBar.snp.makeConstraints { make in
            make.centerX.equalToSuperview().offset(-95)
            make.bottom.equalTo(cosmoView.snp.bottom).offset(-60)
            make.width.equalTo(120)
            make.height.equalTo(30)
        }
//        playerProgressBar.layer.borderColor = UIColor.red.cgColor
//        playerProgressBar.layer.borderWidth = 2

        // Opponent Progress Bar (vertical)
        oppProgressBar = UIProgressView(progressViewStyle: .default)
        oppProgressBar.progress = initialProgress
        oppProgressBar.transform = CGAffineTransform(rotationAngle: -.pi / 2)
        oppProgressBar.progressTintColor = AppColors.oppProgressTint
        addSubview(oppProgressBar)
        oppProgressBar.snp.makeConstraints { make in
            make.centerX.equalToSuperview().offset(95)
            make.bottom.equalTo(cosmoView.snp.bottom).offset(-60)
            make.width.equalTo(120)
            make.height.equalTo(30)
        }

//        oppProgressBar.layer.borderColor = UIColor.red.cgColor
//        oppProgressBar.layer.borderWidth = 2
    }

    private func startAnimations() {
        cosmoView.play()
    }

    // MARK: - Methods to change progress ±20%

    func changePlayerDudeSize(percent: CGFloat) {
        let newProgress = min(max(playerProgressBar.progress + Float(percent), 0), 1)

        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
            self.playerProgressBar.setProgress(newProgress, animated: true)
        }, completion: nil)
    }

    func changeOppDudeSize(percent: CGFloat) {
        let newProgress = min(max(oppProgressBar.progress + Float(percent), 0), 1)

        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
            self.oppProgressBar.setProgress(newProgress, animated: true)
        }, completion: nil)
    }
}
