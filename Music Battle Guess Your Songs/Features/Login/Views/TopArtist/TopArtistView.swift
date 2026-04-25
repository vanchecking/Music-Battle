import UIKit
import SnapKit

/// 🎨 A view displaying a top artist's circular image.
/// ⚪ The image is clipped to a circle with a subtle background.
final class TopArtistView: UIView {
    // MARK: - UI
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .secondarySystemBackground
        imageView.alpha = 0.8
        return imageView
    }()
    // MARK: - Init
    /// Initializes the view with a frame.
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    /// Initializes the view from a coder.
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    // MARK: - Setup
    /// Sets up the view hierarchy and constraints.
    private func setupView() {
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    /// Updates the corner radius to make the image circular.
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.layer.cornerRadius = bounds.width / 2
    }

    /// Configures the view with an image or placeholder.
    /// - Parameters:
    ///   - image: The main image to display.
    ///   - placeholder: A fallback image if main image is nil.
    func configure(
        image: UIImage?,
        placeholder: UIImage? = nil
    ) {
        imageView.image = image ?? placeholder
    }
}
