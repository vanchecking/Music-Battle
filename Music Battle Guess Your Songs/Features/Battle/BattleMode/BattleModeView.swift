import UIKit
import SnapKit
import Lottie

final class BattleModeView: UIView {

    // MARK: - Callback
    // Called when user taps "Done" on keyboard
    var onDone: ((String) -> Void)?

    // MARK: - Background
    private let gradientLayer = AppColors.mainGradient()

    // MARK: - UI Components
    let foundArtistsView = FoundedArtistsView()

    let trendingButton = UIButton(type: .system)
    let tiktokHitsButton = UIButton(type: .system)
    let hits2010Button = UIButton(type: .system)
    let hits2020Button = UIButton(type: .system)

    let loadingView: BattleLoadingView = {
        let view = BattleLoadingView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.alpha = 0
        return view
    }()

    // Tracks count label
    let tracksCountLabel: UILabel = {
        let label = UILabel()
        label.text = "Tracks Count: 7"
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 2
        return label
    }()

    // Slider for selecting number of tracks
    let tracksCountSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 7
        slider.maximumValue = 20
        slider.value = 7
        return slider
    }()

    // TextField for artist search input
    let trackSelectionTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "Find Artists"

        field.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        field.layer.cornerRadius = 16
        field.layer.masksToBounds = false

        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor

        field.layer.shadowColor = UIColor.black.cgColor
        field.layer.shadowOpacity = 0.2
        field.layer.shadowOffset = CGSize(width: 0, height: 4)
        field.layer.shadowRadius = 8

        field.textColor = .white

        field.attributedPlaceholder = NSAttributedString(
            string: "Find Artists",
            attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.7)]
        )

        // Left icon (search)
        let iconImageView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        iconImageView.tintColor = .white
        iconImageView.contentMode = .scaleAspectFit

        let iconContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: 24))
        iconImageView.center = iconContainerView.center
        iconContainerView.addSubview(iconImageView)

        field.leftView = iconContainerView
        field.leftViewMode = .always

        // Right padding
        field.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 0))
        field.rightViewMode = .always

        return field
    }()

    // Blur behind search field
    private let searchGlassView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .systemUltraThinMaterialLight)
        let view = UIVisualEffectView(effect: blur)
        view.clipsToBounds = true
        view.layer.cornerRadius = 16
        view.alpha = 0.95
        view.isUserInteractionEnabled = false
        return view
    }()

    // MARK: - Constraints (keyboard handling)
    private var buttonStackBottomConstraint: Constraint!
    private var foundArtistsViewBottomConstraint: Constraint!

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        registerForKeyboardNotifications()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    // MARK: - UI Setup
    private func setupUI() {

        layer.insertSublayer(gradientLayer, at: 0)

        // Loading overlay
        addSubview(loadingView)
        loadingView.snp.makeConstraints { $0.edges.equalToSuperview() }

        addSubview(tracksCountLabel)
        addSubview(tracksCountSlider)

        // Configure buttons
        trendingButton.applyHomeStyle(title: "🔥 Hot Tracks", style: .primary)
        tiktokHitsButton.applyHomeStyle(title: "🎧 Tik Tok Hits", style: .primary)
        hits2010Button.applyHomeStyle(title: "📀 Hits 2010–2019", style: .primary)
        hits2020Button.applyHomeStyle(title: "🚀 Hits 2020–2025", style: .primary)

        addSubview(tiktokHitsButton)
        addSubview(trendingButton)
        addSubview(hits2010Button)
        addSubview(hits2020Button)

        addSubview(searchGlassView)
        addSubview(trackSelectionTextField)

        // Artists list
        addSubview(foundArtistsView)

        // MARK: - Top controls
        tracksCountLabel.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(16)
            $0.leading.equalToSuperview().inset(24)
        }

        tracksCountSlider.snp.makeConstraints {
            $0.top.equalTo(tracksCountLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(24)
        }

        // MARK: - Artists list positioning
        foundArtistsView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalTo(tracksCountSlider.snp.bottom).offset(16)
            foundArtistsViewBottomConstraint =
                $0.bottom.equalTo(trackSelectionTextField.snp.top).offset(-16).constraint
        }

        // MARK: - Bottom buttons
        let buttonStack = UIStackView(arrangedSubviews: [
            trendingButton,
            tiktokHitsButton,
            hits2010Button,
            hits2020Button
        ])

        buttonStack.axis = .vertical
        buttonStack.spacing = 16
        buttonStack.distribution = .fillEqually
        addSubview(buttonStack)

        buttonStack.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(24)
            buttonStackBottomConstraint = $0.bottom.equalTo(safeAreaLayoutGuide).inset(16).constraint
            $0.height.equalTo(220)
        }

        // MARK: - Search field
        searchGlassView.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(24)
            $0.bottom.equalTo(buttonStack.snp.top).offset(-16)
            $0.height.equalTo(44)
        }

        trackSelectionTextField.snp.makeConstraints {
            $0.edges.equalTo(searchGlassView)
        }

        // MARK: - Keyboard toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let flex = UIBarButtonItem(systemItem: .flexibleSpace)
        let done = UIBarButtonItem(title: "Done",
                                   style: .done,
                                   target: self,
                                   action: #selector(doneButtonTapped))

        toolbar.items = [flex, done]
        trackSelectionTextField.inputAccessoryView = toolbar
    }

    // MARK: - Done action
    @objc private func doneButtonTapped() {
        trackSelectionTextField.resignFirstResponder()
        onDone?(trackSelectionTextField.text ?? "")
    }

    // MARK: - Public API
    func updateArtists(_ newArtists: [FoundedArtist]) {
        foundArtistsView.updateArtists(newArtists)
    }

    // MARK: - Keyboard handling
    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    @objc private func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber,
              let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let options = UIView.AnimationOptions(rawValue: curve.uintValue << 16)
        let keyboardHeight = frame.cgRectValue.height - safeAreaInsets.bottom

        buttonStackBottomConstraint.update(offset: -keyboardHeight - 220 - 16)
        foundArtistsViewBottomConstraint.update(offset: -16)

        UIView.animate(withDuration: duration, delay: 0, options: options) {
            self.setControlsAlpha(0)
            self.layoutIfNeeded()
        }
    }

    @objc private func keyboardWillHide(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber else { return }

        let options = UIView.AnimationOptions(rawValue: curve.uintValue << 16)

        buttonStackBottomConstraint.update(offset: -16)
        foundArtistsViewBottomConstraint.update(offset: -16)

        UIView.animate(withDuration: duration, delay: 0, options: options) {
            self.setControlsAlpha(1)
            self.layoutIfNeeded()
        }
    }

    // MARK: - Helper
    private func setControlsAlpha(_ value: CGFloat) {
        trendingButton.alpha = value
        tiktokHitsButton.alpha = value
        hits2010Button.alpha = value
        hits2020Button.alpha = value
        tracksCountSlider.alpha = value
        tracksCountLabel.alpha = value
    }

    // MARK: - Cleanup
    deinit {
        Logger.log("🧼")
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Loading state
    func hideAllExceptLoading() {
        trendingButton.isHidden = true
        tiktokHitsButton.isHidden = true
        hits2010Button.isHidden = true
        hits2020Button.isHidden = true
        foundArtistsView.isHidden = true
        trackSelectionTextField.isHidden = true
        searchGlassView.isHidden = true
        tracksCountSlider.isHidden = true
        tracksCountLabel.isHidden = true

        loadingView.isHidden = false
    }
}
