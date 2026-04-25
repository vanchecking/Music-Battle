//
//  BattleResultViewController.swift
//  Music Battle Guess Your Songs
//
//  Created by PowerMac on 16.03.2026.
//
import Foundation
import UIKit
import SnapKit
import MusicKit
import Lottie
import AVFoundation

final class BattleResultViewController: UIViewController {
    private let animationViewConfetti = LottieAnimationView(name: "confetti")
    private let animationViewVictory = LottieAnimationView(name: "victory")

    private let score: BattleScore
    private let player: AVPlayer

    var onHomeTapped: (() -> Void)?

    init(score: BattleScore, player: AVPlayer) {
        self.player = player
        self.score = score
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI

    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()

    private let scoreLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        return tableView
    }()

    private let homeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Continue", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        button.layer.cornerRadius = 14
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configure()
        
        let scoreModel = BattleScoreModel(
                playerScore: score.playerScore,
                botScore: score.botScore,
                tracks: score.tracks.map {
                    TrackMeta(
                        url: $0.url?.absoluteString ?? "",
                        artistName: $0.artistName,
                        trackName: $0.title
                    )
                }
            )
        AnalyticsService.shared.track(.battleCompleted(score: scoreModel))
        Task {
            await saveRating()
            await saveBattle()
        }
    }

    private func saveRating() async {
        let ratingDelta = score.ratingChange()

        do {
            try await CloudKitService.shared.updateStats(
                isWin: score.isWin,
                rating: Double(ratingDelta)
            )
        } catch {
            ErrorHandler.shared.handle(error)
        }
    }

    private func saveBattle() async {
        let tracksMeta = score.tracks.map {
            TrackMeta(
                url: $0.url?.absoluteString ?? "",
                artistName: $0.artistName,
                trackName: $0.title
            )
        }

        let history = BattleHistory(
            id: UUID(),
            date: Date(),
            score: BattleScoreModel(
                playerScore: score.playerScore,
                botScore: score.botScore,
                tracks: tracksMeta
            )
        )

        do {
            guard let userID = CloudKitService.shared.currentUser?.userID else {
                throw AppError.noUser
            }
            try await CloudKitService.shared.addBattle(userID: userID, history: history)
        } catch {
            ErrorHandler.shared.handle(error)
        }
        Logger.log("battle saved")
    }

    // MARK: - Setup

    private func setupLottieAnimations() {
        animationViewConfetti.isUserInteractionEnabled = false
        animationViewConfetti.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        animationViewVictory.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(75)
        }
    }
    private func startAnimations() {
        guard score.isWin else { return }

        animationViewVictory.play()

        animationViewConfetti.isUserInteractionEnabled = false
        animationViewConfetti.loopMode = .playOnce
        animationViewConfetti.play { [weak self] _ in
            self?.animationViewConfetti.removeFromSuperview()
        }
    }

    private func setupUI() {
        if score.isWin {
            view.addSubview(animationViewVictory)
            view.addSubview(animationViewConfetti)
            setupLottieAnimations()
        }

        let gradient = AppColors.mainGradient()
        gradient.frame = view.bounds
        view.layer.insertSublayer(gradient, at: 0)

        view.addSubview(titleLabel)
        view.addSubview(scoreLabel)
        view.addSubview(tableView)
        view.addSubview(homeButton)

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(score.isWin ? animationViewVictory.snp.bottom : view.safeAreaLayoutGuide).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        scoreLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(scoreLabel.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(homeButton.snp.top).offset(-16)
        }

        homeButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.height.equalTo(50)
        }

        tableView.dataSource = self
        tableView.delegate = self
        homeButton.addTarget(self, action: #selector(homeTapped), for: .touchUpInside)
        startAnimations()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layer.sublayers?.first?.frame = view.bounds
    }

    private func configure() {
        titleLabel.text = titleText

        let delta = score.ratingChange()
        let sign = delta > 0 ? "+" : ""
        scoreLabel.text = "Rating: \(sign)\(delta)"

        if delta > 0 {
            scoreLabel.textColor = .systemGreen
        } else if delta < 0 {
            scoreLabel.textColor = .systemRed
        } else {
            scoreLabel.textColor = .white
        }
    }

    // MARK: - Computed

    private var titleText: String {
        if score.isWin { return "You Win" }
        if score.isDraw { return "Draw" }
        return "You Lose"
    }

    private var scoreText: String {
        "Rating: \(score.ratingChange())"
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension BattleResultViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        score.tracks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let track = score.tracks[indexPath.row]

        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "trackCell")
        configureCell(cell, forTrack: track)
        return cell
    }

    private func configureCell(_ cell: UITableViewCell, forTrack track: Track) {
        cell.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        cell.layer.cornerRadius = 12
        cell.layer.masksToBounds = true

        cell.textLabel?.textColor = .white
        cell.textLabel?.font = .systemFont(ofSize: 16, weight: .semibold)

        cell.detailTextLabel?.textColor = .lightGray
        cell.detailTextLabel?.font = .systemFont(ofSize: 13, weight: .regular)

        cell.textLabel?.text = track.title
        cell.detailTextLabel?.text = "Open in Apple Music · \(track.artistName)"

        let icon = UIImage(systemName: "play.circle.fill")
        let imageView = UIImageView(image: icon)
        imageView.tintColor = .white
        cell.accessoryView = imageView
        cell.selectionStyle = .none

        // Добавим отступы через layoutMargins
        cell.layoutMargins = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let track = score.tracks[indexPath.row]

        guard let url = track.url else { return }
        UIApplication.shared.open(url)
    }

    @objc private func homeTapped() {
        onHomeTapped?()
    }
}
