import UIKit
import SnapKit
import Combine

enum PremiumState {
    case free
    case premium
}

final class PremiumCardView: UIView {
    
    private let cardView = CardView()
    
    private var isPremium: Bool = false {
        didSet {
            updateUI()
        }
    }

    private var cancellables = Set<AnyCancellable>()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Premium"
        l.font = .boldSystemFont(ofSize: 22)
        return l
    }()
    
    private let featuresStack: UIStackView = {
        let v = UIStackView()
        v.axis = .vertical
        v.spacing = 6
        return v
    }()
    
    private let moreTracksLabel = UILabel()
    private let noAdsLabel = UILabel()
    private let exclusiveLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
        updateUI()
        bindSubscription()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setIsPremium(_ state: Bool) {
        self.isPremium = state
    }

    // for update when changed subscription bought
    private func bindSubscription() {
        SubscriptionService.shared.$isPremium
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isPremium in
                self?.isPremium = isPremium
            }
            .store(in: &cancellables)
    }

    private func updateUI() {
        if isPremium {
            titleLabel.text = "Premium 💎"
        } else {
            titleLabel.text = "No Premium"
            featuresStack.isHidden = false

        }
    }
    
    private func setupUI() {
        addSubview(cardView)
        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        moreTracksLabel.text = "🔓 More tracks"
        noAdsLabel.text = "🚫 No ads"
        exclusiveLabel.text = "🎧 Exclusive content"
        
        [moreTracksLabel, noAdsLabel, exclusiveLabel].forEach {
            featuresStack.addArrangedSubview($0)
        }
        
        addSubview(cardView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(featuresStack)
    }
    
    private func setupLayout() {
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(16)
        }
        
        featuresStack.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(16)
        }
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
}
