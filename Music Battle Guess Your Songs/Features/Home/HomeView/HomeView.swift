import UIKit
import SnapKit

final class HomeView: UIView {

    // MARK: - UI

    let activityIndicator = UIActivityIndicatorView(style: .large)

    private let profileSection = ProfileSectionView()
    private let statsSection = StatsSectionView()
    let actionButtonsView = HomeActionButtonsView()
    let premiumCardView = PremiumCardView()

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()

    private let backgroundLayer = AppColors.mainGradient()
    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Render

    func renderLoading() {
        activityIndicator.startAnimating()
        scrollView.isHidden = true
    }

    func renderContent(_ content: HomeViewState.Content) {
        activityIndicator.stopAnimating()

        // Подготовка scrollView для анимации
        scrollView.alpha = 0
        scrollView.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
        scrollView.isHidden = false
        configureProfileSection(content)
        statsSection.configure(
            wins: content.wins,
            battles: content.battles
        )
        premiumCardView.setIsPremium(SubscriptionService.shared.isPremium)

        UIView.animate(
            withDuration: 0.35,
            delay: 0,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 0.5,
            options: [.curveEaseOut],
            animations: {
                self.scrollView.alpha = 1
                self.scrollView.transform = .identity
            },
            completion: nil
        )
    }

    private func configureProfileSection(_ content: HomeViewState.Content) {
        let rating = content.rating
        // Настраиваем секции

        let intRating = Int(rating)

        let currentRank = RankingService.defineRank(rating: intRating)
        let nextRank = RankingService.defineNextRank(rating: intRating)

        let currentProgress = RankingService.trimRankForCurrentLeague(rating: intRating)
        let maxProgress = RankingService.provideMaxProgressForLeague(rating: intRating)
        let progress = RankingService.provideProgressForLeague(rating: intRating)

        let config = ProfileSectionView.ProfileConfig(
            greeting: GreetingsProvider.greetingText(),
            nickname: content.nickname,
            rating: Double(intRating),
            progressViewFilled: progress,
            currentProgress: currentProgress,
            maxProgress: maxProgress,
            currentRank: currentRank,
            nextRank: nextRank
        )
        profileSection.configure(
            config: config)
    }

    func renderError(_ message: String) {
        activityIndicator.stopAnimating()
        scrollView.isHidden = true
    }

    // MARK: - Setup

    private func setupUI() {
        backgroundColor = .systemBackground
        setupBackground()
        setupHierarchy()
        setupLayout()
    }

    private func setupBackground() {
        layer.insertSublayer(backgroundLayer, at: 0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundLayer.frame = bounds
    }

    private func setupHierarchy() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        addSubview(activityIndicator)

        stackView.axis = .vertical
        stackView.spacing = 12
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .vertical)
        
        stackView.addArrangedSubview(profileSection)
        stackView.addArrangedSubview(premiumCardView)
        stackView.addArrangedSubview(statsSection)
        stackView.addArrangedSubview(spacer)
        stackView.addArrangedSubview(actionButtonsView)
    }

    private func setupLayout() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(24)
        }
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        profileSection.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(statsSection)
        }
        statsSection.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(profileSection)
        }
    }
}
