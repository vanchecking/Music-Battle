import UIKit
import SnapKit
import Lottie

final class ProfileSectionView: UIView {
    struct ProfileConfig {
        /// greeting text (e.g. 'Welcome back')
        let greeting: String
        /// user nickname
        let nickname: String
        /// user total rating
        let rating: Double
        /// normalized progress (0.0–1.0) for progressView
        let progressViewFilled: Float
        /// current progress within league (0–500)
        let currentProgress: Int
        /// maximum progress for current league (usually 500)
        let maxProgress: Int
        /// user current league
        let currentRank: RankingModel.League
        /// user next league
        let nextRank: RankingModel.League
    }

    private let cardView = CardView()

    private let greetingLabel = UILabel()
    private let nicknameLabel = UILabel()
    private let currentRankBadge = UILabel()
    private let nextRankBadge = UILabel()
    private let rankProgressView = UIProgressView(progressViewStyle: .default)
    private let rankProgressLabel = UILabel()

    private let ratingStackView = UIStackView()
    private let rankStackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func configure(config: ProfileConfig) {
        greetingLabel.text = config.greeting
        greetingLabel.font = AppFonts.profile()
        greetingLabel.textAlignment = .left
        greetingLabel.adjustsFontSizeToFitWidth = true
        greetingLabel.minimumScaleFactor = 0.5

        nicknameLabel.text = config.nickname
        nicknameLabel.font = AppFonts.profile().withSize(24)
        nicknameLabel.textAlignment = .left
        nicknameLabel.adjustsFontSizeToFitWidth = true
        nicknameLabel.minimumScaleFactor = 0.5

        currentRankBadge.text = RankingModel.shared.leagueEmoji(for: config.currentRank)
        currentRankBadge.font = AppFonts.badge()
        currentRankBadge.textAlignment = .center

        nextRankBadge.text = RankingModel.shared.leagueEmoji(for: config.nextRank)
        nextRankBadge.font = AppFonts.badge()
        nextRankBadge.textAlignment = .center

        rankProgressView.progress = config.progressViewFilled
        rankProgressView.progressTintColor = AppColors.homePrimaryTint

        rankProgressLabel.text = "\(config.currentProgress) / \(config.maxProgress)"
        rankProgressLabel.font = AppFonts.rating()
        rankProgressLabel.textAlignment = .center
        rankProgressLabel.adjustsFontSizeToFitWidth = true
        rankProgressLabel.minimumScaleFactor = 0.5
    }
    private func addSubviews() {
        cardView.addSubview(greetingLabel)
        cardView.addSubview(nicknameLabel)
        cardView.addSubview(ratingStackView)
        cardView.addSubview(currentRankBadge)
        cardView.addSubview(rankProgressLabel)
        cardView.addSubview(nextRankBadge)
        cardView.addSubview(rankProgressView)
    }
    private func setupUI() {
        addSubview(cardView)
        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        addSubviews()
        // Left block: greetingLabel and nicknameLabel vertically
        greetingLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(16)
            make.trailing.lessThanOrEqualTo(cardView.snp.centerX).offset(-8)
        }

        nicknameLabel.snp.makeConstraints { make in
            make.leading.equalTo(greetingLabel)
            make.top.equalTo(greetingLabel.snp.bottom).offset(8)
            make.trailing.lessThanOrEqualTo(cardView.snp.centerX).offset(-8)
        }

        // Right block: ratingStackView and badges horizontally aligned at top right
        ratingStackView.axis = .horizontal
        ratingStackView.spacing = 8

        ratingStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.trailing.lessThanOrEqualTo(currentRankBadge.snp.leading).offset(-8)
            make.leading.greaterThanOrEqualTo(cardView.snp.centerX).offset(8)
        }

        // Badges arranged horizontally: currentRankBadge, rankProgressLabel, nextRankBadge
        currentRankBadge.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.trailing.equalTo(rankProgressLabel.snp.leading).offset(-8)
        }

        rankProgressLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.centerX.equalToSuperview().offset(80)
            make.width.greaterThanOrEqualTo(40)
            make.height.greaterThanOrEqualTo(20)
        }

        nextRankBadge.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.leading.equalTo(rankProgressLabel.snp.trailing).offset(8)
            make.trailing.lessThanOrEqualToSuperview().inset(16)
        }

        // Progress bar below badges
        rankProgressView.snp.makeConstraints { make in
            make.top.equalTo(currentRankBadge.snp.bottom).offset(8)
            make.leading.equalTo(currentRankBadge)
            make.trailing.equalTo(nextRankBadge)
            make.height.equalTo(4)
        }
    }
}

#if canImport(SwiftUI)
import SwiftUI

struct ProfileSectionViewRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> ProfileSectionView {
        let view = ProfileSectionView()
        // Example data for preview
        let rating = 1
        let intRating = Int(rating)

        let currentRank = RankingService.defineRank(rating: intRating)
        let nextRank = RankingService.defineNextRank(rating: intRating)

        let currentProgress = RankingService.trimRankForCurrentLeague(rating: intRating)
        let maxProgress = RankingService.provideMaxProgressForLeague(rating: intRating)
        let progress = RankingService.provideProgressForLeague(rating: intRating)

        let config = ProfileSectionView.ProfileConfig(
            greeting: "Evening 🌚",
            nickname: "Dev",
            rating: Double(intRating),
            progressViewFilled: progress,
            currentProgress: currentProgress,
            maxProgress: maxProgress,
            currentRank: currentRank,
            nextRank: nextRank
        )

        view.configure(config: config)
        return view
    }
    func updateUIView(_ uiView: ProfileSectionView, context: Context) {
        // No dynamic updates needed for preview
    }
}

struct ProfileSectionView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSectionViewRepresentable()
            .frame(height: 180)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
#endif
