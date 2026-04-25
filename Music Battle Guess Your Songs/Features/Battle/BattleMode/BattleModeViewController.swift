import UIKit
import AVFoundation
import Combine
import MusicKit

final class BattleModeViewController: UIViewController, UITextFieldDelegate {

    private let contentView = BattleModeView()
    private let viewModel: BattleModeViewModel
    private var randomUrl: URL?
    let player = AVPlayer()
    private var cancellables = Set<AnyCancellable>()
    var onBattleProcessTapped: ((_ tracks: [Track]) -> Void)?

    // MARK: - Init
    private var isActive = true

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isActive = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isActive = false
    }

    init(viewModel: BattleModeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        Logger.log("BattleModeViewController deinit 🧼")
    }

    // MARK: - Lifecycle

    override func loadView() {
        view = contentView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
        // Set self as delegate for the relevant UITextField
        bindTrackSelected()
        bindArtistsTable()
        bindArtistSelected()
        checkPremiumForSlider()
        Task {
            await ATTManager.shared.requestPermission()
        }
    }

    private func bindTrackSelected() {
        contentView.onDone = { [weak self] input in
            _ = self?.trackSelected(input: input)
        }
    }

    // MARK: - Actions

    private func setupActions() {

        contentView.trendingButton.addTarget(
            self,
            action: #selector(didTapTrending),
            for: .touchUpInside
        )

        contentView.tiktokHitsButton.addTarget(
            self,
            action: #selector(didTapTikTokHits),
            for: .touchUpInside
        )

        contentView.hits2010Button.addTarget(
            self,
            action: #selector(didTap2010Hits),
            for: .touchUpInside
        )

        contentView.hits2020Button.addTarget(
            self,
            action: #selector(didTap2026Hits),
            for: .touchUpInside
        )
    }

    private func showLoadingView() {
        self.contentView.loadingView.alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.contentView.loadingView.alpha = 1
            self.contentView.hideAllExceptLoading()
        }
    }

    @objc private func didTapTrending() {
        showLoadingView()
        Task {
            let mix = try await viewModel.loadPlaylist(.trending)
            AnalyticsService.shared.track(.battleStarted(mode: "trending"))
            Task {
                await wait1second()
                UIView.animate(withDuration: 0.3) {
                    self.contentView.loadingView.alpha = 0
                }
                if self.isActive {
                    self.onBattleProcessTapped?(mix)
                }
            }
        }
    }

    @objc private func didTapTikTokHits() {
        showLoadingView()
        Task {
            let mix = try await viewModel.loadPlaylist(.tiktok)
            AnalyticsService.shared.track(.battleStarted(mode: "tiktok"))
            Task {
                await wait1second()
                UIView.animate(withDuration: 0.3) {
                    self.contentView.loadingView.alpha = 0
                }
                if self.isActive {
                    self.onBattleProcessTapped?(mix)
                }
            }
        }
    }

    @objc private func didTap2010Hits() {
        showLoadingView()
        Task {
            let mix = try await viewModel.loadPlaylist(.hits2010)
            AnalyticsService.shared.track(.battleStarted(mode: "hits2010"))
            Task {
                await wait1second()
                UIView.animate(withDuration: 0.3) {
                    self.contentView.loadingView.alpha = 0
                }
                if self.isActive {
                    self.onBattleProcessTapped?(mix)
                }
            }
        }
    }

    @objc private func didTap2026Hits() {
        showLoadingView()
        Task {
            let mix = try await viewModel.loadPlaylist(.hits2026)
            AnalyticsService.shared.track(.battleStarted(mode: "hits 2026"))
            Task {
                await wait1second()
                UIView.animate(withDuration: 0.3) {
                    self.contentView.loadingView.alpha = 0
                }
                if self.isActive {
                    self.onBattleProcessTapped?(mix)
                }
            }
        }
    }

    // MARK: - UITextFieldDelegate

    func trackSelected(input: String) -> Bool {
        // Тримим пробелы
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return false }

        // Уведомляем viewModel
        Task {
            await viewModel.didConfirmTrackSelection(text: text)
        }

        return true
    }

    func bindArtistsTable() {
        viewModel.$artists
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newArtists in
                self?.contentView.foundArtistsView.updateArtists(newArtists)
            }
            .store(in: &cancellables)
    }
    
    private func bindTracksCount() {
        viewModel.$tracksPlayCount
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                guard let self else { return }
                contentView.tracksCountLabel.text = "Tracks Count: \(value)"
            }
            .store(in: &cancellables)
    }
    
    private func setNormalSlider() {
        contentView.tracksCountSlider.value = Float(self.viewModel.tracksPlayCount)
        contentView.tracksCountSlider.isEnabled = false
        contentView.tracksCountLabel.text = "🔒 \(self.viewModel.tracksPlayCount) tracks, get premium for more"
    }
    
    private func checkPremiumForSlider() {
        if SubscriptionService.shared.isPremium {
            setupSlider()
            bindTracksCount()
        } else {
            setNormalSlider()
        }
    }

    private func setupSlider() {
        contentView.tracksCountSlider.value = Float(RemoteConfigService.shared.trackPlayCount)
        contentView.tracksCountSlider.addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged)
    }
    
    @objc private func sliderChanged(_ sender: UISlider) {
        let value = Int(sender.value)

        viewModel.tracksPlayCount = value
    }
    
    private func bindArtistSelected() {
        contentView.foundArtistsView.onArtistSelected = { [weak self] artist in
            Logger.log("selected artist: \(artist.name)")
            _ = self
            CashedArtistService.shared.addArtist(artist)
            self?.showLoadingView()
            Task {
                do {
                    let rawMix = try await self?.viewModel.loadMix(artist: artist)
                    guard let mix = rawMix else {
                        throw AppError.noTracks
                    }
                    AnalyticsService.shared.track(.battleStarted(mode: "artist:\(artist.name)"))
                    Logger.log("mix founded with \(mix.count) tracks")
                    for track in mix {
                        print("track: \(track.title)")
                    }
                    Task {
                        await self?.wait1second()
                        UIView.animate(withDuration: 0.3) {
                            self?.contentView.loadingView.alpha = 0
                        }
                        guard let self else { return }
                        if self.isActive {
                            self.onBattleProcessTapped?(mix)
                        }
                    }
                } catch {
                    ErrorHandler.shared.handle(error)
                }
            }
            
        }
    }

    private func wait1second() async {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
    }
}
