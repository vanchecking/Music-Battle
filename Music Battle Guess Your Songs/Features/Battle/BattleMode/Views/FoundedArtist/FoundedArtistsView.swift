//
//  FindedArtistsView.swift
//  Music Battle Guess Your Songs
//
//  Created by PowerMac on 11.03.2026.
//

import UIKit
import SnapKit

// Custom UITableViewCell to display artist name
class FoundArtistCell: UITableViewCell {
    static let identifier = "FoundArtistCell"

    let nameLabel = UILabel()
    private let backgroundColoredView = UIView()
    private let stackView = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        // Configure background view
        backgroundColoredView.backgroundColor = AppColors.foundedArtistCellPink
        contentView.insertSubview(backgroundColoredView, at: 0)
        backgroundColoredView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }

        // Configure stackView
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 0
        backgroundColoredView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().inset(12)
        }

        // Configure nameLabel and add to stackView
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(nameLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with artist: FoundedArtist) {
        nameLabel.text = artist.name
        nameLabel.font = AppFonts.foundedArtistCell()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Make background view oval (cornerRadius = half height)
        backgroundColoredView.layer.cornerRadius = backgroundColoredView.frame.height / 2
        backgroundColoredView.layer.masksToBounds = true
    }
}

// View displaying list of found artists
class FoundedArtistsView: UIView, UITableViewDataSource, UITableViewDelegate {
    private let tableView = UITableView()
    private var artists: [FoundedArtist] = []
    var onArtistSelected: ((FoundedArtist) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTableView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTableView()
        // Example mock data
    }
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(FoundArtistCell.self, forCellReuseIdentifier: FoundArtistCell.identifier)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return artists.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FoundArtistCell.identifier, for: indexPath) as? FoundArtistCell else {
            return UITableViewCell()
        }
        let artist = artists[indexPath.row]
        cell.configure(with: artist)
        return cell
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Handle cell selection if needed
        let selectedArtist = artists[indexPath.row]
        onArtistSelected?(selectedArtist)
    }
}

extension FoundedArtistsView {
    func updateArtists(_ newArtists: [FoundedArtist]) {
        self.artists = newArtists
        tableView.reloadData()
    }
}
