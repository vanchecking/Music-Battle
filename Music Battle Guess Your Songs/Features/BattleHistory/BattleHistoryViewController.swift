//
//  BattleHistoryViewController.swift
//  Music Battle Guess Your Songs
//
//  Created by PowerMac on 22.03.2026.
//

import Foundation
import UIKit
import SnapKit

final class BattleHistoryCell: UITableViewCell {

    private let mainArtistLabel = UILabel()
    private let scoreLabel = UILabel()
    private let trackLabel = UILabel()
    private let dateLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        selectionStyle = .none
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        mainArtistLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        scoreLabel.font = .systemFont(ofSize: 14, weight: .regular)
        trackLabel.font = .systemFont(ofSize: 14, weight: .regular)
        dateLabel.font = .systemFont(ofSize: 12, weight: .light)
        dateLabel.textColor = .secondaryLabel

        let vStack = UIStackView(arrangedSubviews: [mainArtistLabel, trackLabel, scoreLabel, dateLabel])
        vStack.axis = .vertical
        vStack.spacing = 4
        contentView.addSubview(vStack)
        vStack.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().inset(8)
        }
    }

    func configure(with battle: BattleHistory) {
        let mainArtist = battle.score.tracks.first?.artistName ?? "Mix"
        mainArtistLabel.text = mainArtist

        trackLabel.text = "Tracks played: \(battle.score.tracks.count)"

        let change = battle.score.ratingChange()
        let sign = change > 0 ? "+" : ""
        scoreLabel.text = "Rating: \(sign)\(change)"
        scoreLabel.textColor = change > 0 ? .systemGreen : change < 0 ? .systemRed : .label

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        dateLabel.text = formatter.string(from: battle.date)

        if battle.score.isWin {
            contentView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.2)
        } else {
            contentView.backgroundColor = UIColor.systemIndigo.withAlphaComponent(0.4)
        }
    }
}

final class BattleHistoryViewController: UIViewController {

    private let gradientLayer = AppColors.mainGradient()

    private var battles: [BattleHistory] = []
    private let tableView = UITableView()
    private let loadingView = UIActivityIndicatorView(style: .large)
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "No battle history yet. Here will appear your battles."
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradient()
        setupTableView()
        view.addSubview(placeholderLabel)
        placeholderLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(16)
        }
        setupLoadingView()
        loadBattles()
        AnalyticsService.shared.track(.historyViewed)
    }

    private func loadBattles() {
        loadingView.startAnimating()
        Task {
            do {
                guard let userID = CloudKitService.shared.currentUser?.userID else {
                    throw AppError.noUser
                }
                let battles = try await CloudKitService.shared.loadBattleHistory(userID: userID)
                let sortedBattles = battles.sorted { $0.date > $1.date }
                await MainActor.run {
                    self.battles = sortedBattles
                    self.placeholderLabel.isHidden = !self.battles.isEmpty
                    self.tableView.isHidden = self.battles.isEmpty
                    self.tableView.reloadData()
                    self.loadingView.stopAnimating()
                }
            } catch {
                await MainActor.run {
                    self.loadingView.stopAnimating()
                    ErrorHandler.shared.handle(error)
                }
            }
        }
    }

    private func setupGradient() {
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func setupTableView() {
        tableView.frame = view.bounds
        tableView.backgroundColor = .clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(BattleHistoryCell.self, forCellReuseIdentifier: "BattleHistoryCell")
        view.addSubview(tableView)
    }

    private func setupLoadingView() {
        loadingView.hidesWhenStopped = true
        view.addSubview(loadingView)
        loadingView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }
}

extension BattleHistoryViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        battles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let battle = battles[indexPath.row]
        // forced cast is safe because we registered BattleHistoryCell
        // swiftlint:disable:next force_cast
        let cell = tableView.dequeueReusableCell(withIdentifier: "BattleHistoryCell", for: indexPath) as! BattleHistoryCell
        cell.configure(with: battle)
        return cell
    }
}
