import UIKit
import SnapKit
import AuthenticationServices

/// LoginView: displays login screen with title, subtitle, Apple sign-in, carousel, and notes.
/// View is “dumb”: it only renders data and forwards events via closures.
final class LoginView: UIView {

    // MARK: - Layers & Containers

    /// Background gradient layer. Added once; resized in layoutSubviews.
    private let gradientLayer = AppColors.mainGradient()

    /// Floating notes container (decorative/visual). Centered at top.
    private let notesContainer = FloatingNotesContainer()

    /// Carousel of top artists. Alpha/visibility animated externally.
    private let topArtistsCarouselView = TopArtistsCarouselView()

    /// Callback for Apple sign-in button taps.
    var onAppleTap: (() -> Void)?

    // MARK: - Labels

    /// Main title, centered. Text updated externally.
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Music Battle ⚔️"
        label.font = AppFonts.title()
        label.textColor = AppColors.white
        label.textAlignment = .center
        return label
    }()

    /// Subtitle, centered. Text updated externally.
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Millions of songs. Real‑time battles."
        label.font = AppFonts.subtitle()
        label.textColor = AppColors.white
        label.textAlignment = .center
        return label
    }()

    /// Integrations note (Apple Music). Visibility controlled externally.
    private let integrationsLabel: UILabel = {
        let label = UILabel()
        label.text = "Powered by Apple Music"
        label.font = AppFonts.caption()
        label.textColor = AppColors.white.withAlphaComponent(0.8)
        label.textAlignment = .center
        return label
    }()

    // MARK: - Buttons

    /// Apple sign-in button. Tap forwarded via `onAppleTap`.
    private let appleSignInButton: ASAuthorizationAppleIDButton = {
        let button = ASAuthorizationAppleIDButton(
            authorizationButtonType: .default,
            authorizationButtonStyle: .white
        )
        button.cornerRadius = 14
        return button
    }()

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupLayout()
        addTarget()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    /// Resize gradient to match bounds. Only updates if changed.
    override func layoutSubviews() {
        super.layoutSubviews()
        if gradientLayer.frame != bounds {
            gradientLayer.frame = bounds
        }
    }

    // MARK: - Setup

    /// Adds subviews and gradient layer. View hierarchy is static.
    private func setupView() {
        if gradientLayer.superlayer == nil {
            layer.insertSublayer(gradientLayer, at: 0)
        }
        addSubview(notesContainer)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(appleSignInButton)
        addSubview(topArtistsCarouselView)
        addSubview(integrationsLabel)
    }

    /// SnapKit constraints for all subviews. Static layout.
    private func setupLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(notesContainer.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        appleSignInButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-32)
            $0.height.equalTo(52)
        }
        notesContainer.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(80)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(72)
        }
        integrationsLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalTo(appleSignInButton.snp.top).offset(-12)
        }
        topArtistsCarouselView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(integrationsLabel.snp.top).offset(-16)
            $0.height.equalTo(240)
        }
    }

    /// Adds tap target for Apple button → calls `onAppleTap`.
    private func addTarget() {
        appleSignInButton.addTarget(self,
                                    action: #selector(didTapAppleButton),
                                    for: .touchUpInside)
    }

    @objc private func didTapAppleButton() {
        onAppleTap?()
    }

    // MARK: - Public API

    /// Updates text content and visibility flags for labels & carousel.
    /// - Note: View itself does not decide visibility; flags must come from controller/VM.
    func updateTexts(
        title: String,
        subtitle: String,
        integrationsText: String,
        showIntegrations: Bool,
        showArtistsCarousel: Bool
    ) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        integrationsLabel.text = integrationsText
        integrationsLabel.isHidden = !showIntegrations
        topArtistsCarouselView.isHidden = !showArtistsCarousel
    }

    /// Animates carousel appearance from alpha 0 → 1. Safe for repeated calls.
    func showAnimated(_ artists: [ArtistImage]) {
        topArtistsCarouselView.layer.removeAllAnimations()
        topArtistsCarouselView.alpha = 0
        topArtistsCarouselView.configure(with: artists)

        UIView.animate(withDuration: 0.7,
                       delay: 0,
                       options: [.curveEaseInOut]) { [weak self] in
            self?.topArtistsCarouselView.alpha = 1
        }
    }
}
