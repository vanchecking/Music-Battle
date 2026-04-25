import UIKit
import SnapKit
import Lottie

final class BattleModeView: UIView {
    // Closure called when Done button is tapped on keyboard
    var onDone: ((String) -> Void)?

    // MARK: - UI

    private let gradientLayer = AppColors.mainGradient()
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

    let tracksCountLabel: UILabel = {
        let label = UILabel()
        label.text = "Tracks Count: 7"
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 2
        return label
    }()

    let tracksCountSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 7
        slider.maximumValue = 20
        slider.value = 7
        return slider
    }()

    let trackSelectionTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "Find Artists"

        // Фон (слегка плотный, но не глухой)
        field.backgroundColor = UIColor.white.withAlphaComponent(0.15)

        // Скругление
        field.layer.cornerRadius = 16
        field.layer.masksToBounds = false

        // Граница (дает четкость)
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor

        // Тень (чуть выразительнее)
        field.layer.shadowColor = UIColor.black.cgColor
        field.layer.shadowOpacity = 0.2
        field.layer.shadowOffset = CGSize(width: 0, height: 4)
        field.layer.shadowRadius = 8

        // Цвет текста
        field.textColor = .white

        // Placeholder поярче
        field.attributedPlaceholder = NSAttributedString(
            string: "Find Artists",
            attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.7)]
        )

        // Иконка
        let iconImageView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        iconImageView.tintColor = .white
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.frame = CGRect(x: 0, y: 0, width: 24, height: 24)

        let iconContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: 24))
        iconImageView.center = CGPoint(x: iconContainerView.frame.width / 2, y: iconContainerView.frame.height / 2)
        iconContainerView.addSubview(iconImageView)

        field.leftView = iconContainerView
        field.leftViewMode = .always

        // Правый отступ
        let rightPadding = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 0))
        field.rightView = rightPadding
        field.rightViewMode = .always

        return field
    }()

    private let searchGlassView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .systemUltraThinMaterialLight)
        let view = UIVisualEffectView(effect: blur)
        view.clipsToBounds = true
        view.layer.cornerRadius = 16
        view.isUserInteractionEnabled = false // Let touches pass to textField
        view.alpha = 0.95 // Stronger semi-transparent
        return view
    }()

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

    private func setupUI() {
        layer.insertSublayer(gradientLayer, at: 0)

        addSubview(loadingView)
        loadingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        addSubview(tracksCountLabel)
        addSubview(tracksCountSlider)

        // Configure buttons
        trendingButton.applyHomeStyle(title: "🔥 Hot Tracks", style: .primary)
        tiktokHitsButton.applyHomeStyle(title: "🎧 Tik Tok Hits", style: .primary)
        hits2010Button.applyHomeStyle(title: "📀 Hits 2010–2019", style: .primary)
        hits2020Button.applyHomeStyle(title: "🚀 Hits 2020–2025", style: .primary)

        // Add buttons
        addSubview(tiktokHitsButton)
        addSubview(trendingButton)
        addSubview(hits2010Button)
        addSubview(hits2020Button)

        // Glass effect behind searchTextField
        addSubview(searchGlassView)
        addSubview(trackSelectionTextField)

        // Add foundArtistsView, always visible, pinned at top below safe area
        foundArtistsView.isHidden = false
        addSubview(foundArtistsView)

        tracksCountLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(16)
            make.leading.equalToSuperview().inset(24)
        }

        tracksCountSlider.snp.makeConstraints { make in
            make.top.equalTo(tracksCountLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(24)
        }

        foundArtistsView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(tracksCountSlider.snp.bottom).offset(16)
            foundArtistsViewBottomConstraint = make.bottom.equalTo(trackSelectionTextField.snp.top).offset(-16).constraint
        }

        // Layout buttons at the bottom in stack view with stored bottom constraint
        let buttonStack = UIStackView(arrangedSubviews: [trendingButton, tiktokHitsButton, hits2010Button, hits2020Button])
        buttonStack.axis = .vertical
        buttonStack.spacing = 16
        buttonStack.distribution = .fillEqually
        addSubview(buttonStack)

        buttonStack.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(24)
            buttonStackBottomConstraint = make.bottom.equalTo(safeAreaLayoutGuide).inset(16).constraint
            make.height.equalTo(220) // 4 buttons * 50 + spacing
        }

        // Layout searchGlassView and searchTextField above the buttons
        searchGlassView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(24)
            make.bottom.equalTo(buttonStack.snp.top).offset(-16)
            make.height.equalTo(44)
        }
        trackSelectionTextField.snp.makeConstraints { make in
            make.edges.equalTo(searchGlassView)
        }
        // Add input accessory view with Done button to searchTextField
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
        toolbar.items = [flexSpace, doneBarButton]
        trackSelectionTextField.inputAccessoryView = toolbar
    }

    @objc private func doneButtonTapped() {
        trackSelectionTextField.resignFirstResponder()
        onDone?(trackSelectionTextField.text ?? "")
    }

    func updateArtists(_ newArtists: [FoundedArtist]) {
        self.foundArtistsView.updateArtists(newArtists)
    }

    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber,
              let keyboardFrameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let animationCurveRaw = animationCurveRawNSN.uintValue
        let animationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw << 16)
        let keyboardFrame = keyboardFrameValue.cgRectValue
        let keyboardHeight = keyboardFrame.height - safeAreaInsets.bottom

        // Hide buttons by fading out and moving off screen
        buttonStackBottomConstraint.update(offset: -keyboardHeight - 220 - 16)

        // Adjust foundArtistsView bottom constraint to be above searchTextField with offset -16 (unchanged)
        foundArtistsViewBottomConstraint.update(offset: -16)

        UIView.animate(withDuration: animationDuration, delay: 0, options: animationOptions, animations: {
            self.trendingButton.alpha = 0
            self.tiktokHitsButton.alpha = 0
            self.hits2010Button.alpha = 0
            self.hits2020Button.alpha = 0
            self.tracksCountSlider.alpha = 0
            self.tracksCountLabel.alpha = 0

            self.layoutIfNeeded()
        }, completion: nil)
    }

    @objc private func keyboardWillHide(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber else { return }

        let animationCurveRaw = animationCurveRawNSN.uintValue
        let animationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw << 16)

        // Show buttons by resetting buttonStack bottom constraint
        buttonStackBottomConstraint.update(offset: -16)

        // Adjust foundArtistsView bottom constraint to be above searchTextField with offset -16 (unchanged)
        foundArtistsViewBottomConstraint.update(offset: -16)

        UIView.animate(withDuration: animationDuration, delay: 0, options: animationOptions, animations: {
            self.trendingButton.alpha = 1
            self.tiktokHitsButton.alpha = 1
            self.hits2010Button.alpha = 1
            self.hits2020Button.alpha = 1
            self.tracksCountSlider.alpha = 1
            self.tracksCountLabel.alpha = 1

            self.layoutIfNeeded()
        }, completion: nil)
    }

    deinit {
        Logger.log("🧼")
        NotificationCenter.default.removeObserver(self)
    }

    func hideAllExceptLoading() {
        trendingButton.isHidden = true
        tiktokHitsButton.isHidden = true
        hits2010Button.isHidden = true
        hits2020Button.isHidden = true
        foundArtistsView.isHidden = true
        trackSelectionTextField.isHidden = true
        searchGlassView.isHidden = true
        loadingView.isHidden = false
        tracksCountSlider.isHidden = true
        tracksCountLabel.isHidden = true
    }
}
