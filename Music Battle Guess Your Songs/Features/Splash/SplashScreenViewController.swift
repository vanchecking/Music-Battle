import UIKit
import Lottie
import SnapKit

final class SplashViewController: UIViewController {

    weak var coordinator: SplashCoordinator?

    private let animationView = LottieAnimationView(name: "chilli")
    private let gradientLayer = AppColors.mainGradient()
    private let splashDuration = 2.0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradient()
        setupUI()
        startAnimation()
        proceedAfterDelay()
    }

    // MARK: - Setup

    private func setupGradient() {
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func setupUI() {
        animationView.loopMode = .loop
        animationView.contentMode = .scaleAspectFit

        view.addSubview(animationView)

        animationView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(350)
        }
    }

    // IMPORTANT — ensures the gradient fills the entire screen
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    // MARK: - Animation

    private func startAnimation() {
        animationView.play()
    }

    private func proceedAfterDelay() {
        Task { @MainActor in
            // Sleep for the splash duration in nanoseconds
            try? await Task.sleep(nanoseconds: UInt64(splashDuration * 1_000_000_000))
            transitionToLogin()
        }
    }

    private func transitionToLogin() {
        animationView.stop()
        coordinator?.splashDidFinish()
    }
    deinit {
        Logger.log("Deinit")
    }
}
