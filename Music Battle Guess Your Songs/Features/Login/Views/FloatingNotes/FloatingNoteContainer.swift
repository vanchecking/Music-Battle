import UIKit
import Lottie
import SnapKit

/// A container view that displays an animated floating notes Lottie animation.
/// This view handles the setup and playback of the animation.
final class FloatingNotesContainer: UIView {

    /// The Lottie animation view displaying the floating notes animation.
    private let animationView = LottieAnimationView(name: "floatingNotes")

    /// Initializes the container view with a frame.
    /// - Parameter frame: The frame rectangle for the view.
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        startAnimation()
    }

    /// Initializes the container view from a decoder.
    /// - Parameter coder: The decoder to initialize from.
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        startAnimation()
    }

    // MARK: - Setup

    /// Sets up the user interface elements, including adding the animation view
    /// and configuring its layout and appearance.
    private func setupUI() {
        animationView.loopMode = .loop
        animationView.contentMode = .scaleAspectFit

        addSubview(animationView)

        animationView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-10)
            make.size.equalTo(150)
        }
    }

    // MARK: - Animation

    /// Starts playing the floating notes animation.
    func startAnimation() {
        animationView.play()
    }

    /// Called when the instance is being deallocated.
    deinit {
        Logger.log("Deinit")
    }
}
