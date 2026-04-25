//
//  PaywallViewController.swift
//

import UIKit
import Adapty
import SnapKit

final class PaywallViewController: UIViewController {
        
    // MARK: - State
    private var isLoading: Bool = false {
        didSet { updateLoadingState() }
    }
    
    private let viewModel: PaywallViewModel
    
    // MARK: - UI
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Get Unlimited Music"
        l.font = .boldSystemFont(ofSize: 28)
        l.textAlignment = .center
        return l
    }()
    
    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Cancel anytime."
        l.textColor = .secondaryLabel
        l.textAlignment = .center
        l.numberOfLines = 0
        return l
    }()
    
    private let benefitsStack = UIStackView()
    private let cardsStack = UIStackView()
    private let ctaButton = UIButton(type: .system)
    private let footerStack = UIStackView()
    private let privacyButton = UIButton(type: .system)
    private let termsButton = UIButton(type: .system)
    private let restoreButton = UIButton(type: .system)
    private let activity = UIActivityIndicatorView(style: .large)
    
    private var cardViews: [ProductCardView] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradient()
        setupUI()
        bind()
        viewModel.load()
    }

    init(viewModel: PaywallViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }
    
    let gradientLayer = AppColors.mainGradient()
    
    private func setupGradient() {
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }
    
    private func setupButtons() {
        privacyButton.setTitle("Privacy", for: .normal)
        termsButton.setTitle("Terms", for: .normal)
        restoreButton.setTitle("Restore", for: .normal)

        [privacyButton, termsButton, restoreButton].forEach {
            $0.titleLabel?.font = .systemFont(ofSize: 13)
        }

        privacyButton.addTarget(self, action: #selector(privacyTapped), for: .touchUpInside)
        termsButton.addTarget(self, action: #selector(termsTapped), for: .touchUpInside)
        restoreButton.addTarget(self, action: #selector(restoreTapped), for: .touchUpInside)

        let dot1 = makeDot()
        let dot2 = makeDot()

        footerStack.addArrangedSubview(privacyButton)
        footerStack.addArrangedSubview(dot1)
        footerStack.addArrangedSubview(termsButton)
        footerStack.addArrangedSubview(dot2)
        footerStack.addArrangedSubview(restoreButton)
    }
    
    private func setupConstraints() {
        // MARK: SnapKit
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        benefitsStack.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        cardsStack.snp.makeConstraints { make in
            make.top.equalTo(benefitsStack.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        ctaButton.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(cardsStack.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(52)
            make.bottom.equalTo(footerStack.snp.top).offset(-12)
        }

        footerStack.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
            make.centerX.equalToSuperview()
        }
   
        activity.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        benefitsStack.axis = .vertical
        benefitsStack.spacing = 8
        
        [" 🔓 More tracks", " 🚫 No ads", "🎧 Exclusive content"].forEach { text in
            let row = makeBenefitRow(text)
            benefitsStack.addArrangedSubview(row)
        }
        
        cardsStack.axis = .vertical
        cardsStack.spacing = 12
        
        ctaButton.setTitle("Unlock Unlimited Music", for: .normal)
        ctaButton.titleLabel?.font = .boldSystemFont(ofSize: 17)
        ctaButton.backgroundColor = AppColors.accentPinkButton
        ctaButton.setTitleColor(.white, for: .normal)
        ctaButton.layer.cornerRadius = 12
        ctaButton.addTarget(self, action: #selector(ctaTapped), for: .touchUpInside)
        
        // Footer
        footerStack.axis = .horizontal
        footerStack.spacing = 8
        footerStack.alignment = .center
        footerStack.distribution = .equalCentering

        setupButtons()
        
        activity.hidesWhenStopped = true
        
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(benefitsStack)
        view.addSubview(cardsStack)
        view.addSubview(ctaButton)
        view.addSubview(footerStack)
        view.addSubview(activity)
        
        setupConstraints()
    }
    
    private func makeDot() -> UILabel {
        let l = UILabel()
        l.text = "·"
        l.textColor = .secondaryLabel
        l.font = .systemFont(ofSize: 13)
        return l
    }

    private func makeBenefitRow(_ text: String) -> UIView {
        let h = UIStackView()
        h.axis = .horizontal
        h.spacing = 8
        
        let label = UILabel()
        label.text = text
        
        h.addArrangedSubview(label)
        
        label.snp.makeConstraints { make in
            make.size.height.equalTo(16)
        }
        
        return h
    }
    
    // MARK: - Data
    private func setupCards(_ products: [AdaptyPaywallProduct]) {
        cardsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        cardViews.removeAll()
        
        for (index, product) in products.enumerated() {
            let card = ProductCardView()
            let discount = " \(self.viewModel.calculateDiscount()) OFF "
            let locPrice = product.localizedPrice ?? "$"
            card.configure(
                title: product.localizedTitle,
                price: locPrice,
                badge: index == products.count - 1 ? " Best Value " : nil,
                discount: index == products.count - 1 ? "\(discount)" : nil
            )
            card.onTap = { [weak self] in
                self?.viewModel.select(index: index)
            }
            
            cardsStack.addArrangedSubview(card)
            cardViews.append(card)
        }
    }

    private func bind() {
        viewModel.onProductsLoaded = { [weak self] products in
            self?.setupCards(products)
        }
        
        viewModel.onLoadingChanged = { [weak self] isLoading in
            self?.isLoading = isLoading
        }
        
        viewModel.onError = { [weak self] message in
            self?.showAlert(title: "Error", message: message)
        }
        
        viewModel.onPurchaseResult = { [weak self] isPremium in
            self?.handlePurchaseResult(isPremium)
        }
        
        viewModel.onSelectionChanged = { [weak self] index in
            self?.updateSelection(index)
        }
    }

    private func updateSelection(_ index: Int) {
        for (i, card) in cardViews.enumerated() {
            card.setSelected(i == index)
        }
    }
    
    // MARK: - Actions
    @objc private func ctaTapped() {
        viewModel.purchase()
    }
    
    @objc private func restoreTapped() {
        viewModel.restore()
    }
    
    @objc private func privacyTapped() {
        viewModel.openPrivacy()
    }

    @objc private func termsTapped() {
        viewModel.openTerms()
    }
    
    // MARK: - State UI
    private func updateLoadingState() {
        ctaButton.isEnabled = !isLoading
        cardViews.forEach { $0.isUserInteractionEnabled = !isLoading }
        restoreButton.isEnabled = !isLoading
        
        if isLoading {
            activity.startAnimating()
        } else {
            activity.stopAnimating()
        }
    }
    
    // MARK: - Handlers
    private func handlePurchaseResult(_ isPremium: Bool) {
        if isPremium {
            dismiss(animated: true)
        } else {
            showAlert(title: "Error", message: "Access not granted")
        }
    }
    
    private func handle(_ error: Error) {
        let message: String
        if let appError = error as? AppError {
            message = appError.localizedDescription
        } else {
            message = error.localizedDescription
        }
        showAlert(title: "Error", message: message)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Product Card

final class ProductCardView: UIView {
    
    var onTap: (() -> Void)?
    
    private let titleLabel = UILabel()
    private let priceLabel = UILabel()
    private let badgeLabel = UILabel()
    private let container = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setup() {
        container.layer.cornerRadius = 14
        container.layer.borderWidth = 1
        
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        priceLabel.font = .systemFont(ofSize: 14)
        priceLabel.textColor = .white
        
        badgeLabel.font = .systemFont(ofSize: 12, weight: .bold)
        badgeLabel.textColor = .white
        badgeLabel.backgroundColor = AppColors.accentBlue
        badgeLabel.layer.cornerRadius = 6
        badgeLabel.clipsToBounds = true
        badgeLabel.textAlignment = .center
        
        addSubview(container)
        container.addSubview(titleLabel)
        container.addSubview(priceLabel)
        container.addSubview(badgeLabel)
        
        container.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(12)
        }
        
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.equalTo(titleLabel)
            make.bottom.equalToSuperview().offset(-12)
        }
        
        badgeLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-12)
            make.height.equalTo(22)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
        addGestureRecognizer(tap)
        
        setSelected(false)
    }
    
    func configure(title: String, price: String, badge: String?, discount: String?) {
        titleLabel.text = title
        priceLabel.text = discount == nil ? price : "\(price), \(discount!)"
        badgeLabel.text = badge
        badgeLabel.isHidden = badge == nil
    }
    
    func setSelected(_ selected: Bool) {
        container.layer.borderColor = selected ? UIColor.label.cgColor : UIColor.systemGray4.cgColor
        container.backgroundColor = selected ? AppColors.accentGold.withAlphaComponent(0.8) : .clear
    }

    @objc private func didTap() {
        onTap?()
    }
}
