import UIKit
import AVFoundation
import Combine
import MusicKit

final class BattleModeViewController: UIViewController, UITextFieldDelegate {

    // MARK: - UI
    private let contentView = BattleModeView()

    // MARK: - Dependencies
    private let viewModel: BattleModeViewModel

    // MARK: - Player
    private var randomUrl: URL?
    let player = AVPlayer()

    // MARK: - State
    private var cancellables = Set<AnyCancellable>()
    private var isActive = true

    // Callback to start battle flow
    var onBattleProcessTapped: ((_ tracks: [Track]) -> Void)?

    // MARK: - Init
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
        bindTrackSelected()
        bindArtistsTable()
        bindArtistSelected()
        checkPremiumForSlider()

        Task {
            await ATTManager.shared.requestPermission()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isActive = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isActive = false
    }

    // MARK: - Track input binding
    private func bindTrackSelected() {
        contentView.onDone = { [weak self] input in
            _ = self?.trackSelected(input: input)
        }
    }

    // MARK: - Button setup
    private func setupActions() {

        contentView.trendingButton.addTarget(self, action: #selector(didTapTrending), for: .touchUpInside)
        contentView.tiktokHitsButton.addTarget(self, action: #selector(didTapTikTokHits), for: .touchUpInside)
        contentView.hits2010Button.addTarget(self, action: #selector(didTap2010Hits), for: .touchUpInside)
        contentView.hits2020Button.addTarget(self, action: #selector(didTap2026Hits), for: .touchUpInside)
    }

    // MARK: - Loading UI
    private func showLoadingView() {
        UIView.animate(withDuration: 0.3) {
            self.contentView.loadingView.alpha = 1
            self.contentView.hideAllExceptLoading()
        }
    }

    // MARK: - Playlist actions

    @objc private func didTapTrending() {
        loadPlaylist(.trending, mode: "trending")
    }

    @objc private func didTapTikTokHits() {
        loadPlaylist(.tiktok, mode: "tiktok")
    }

    @objc private func didTap2010Hits() {
        loadPlaylist(.hits2010, mode: "hits2010")
    }

    @objc private func didTap2026Hits() {
        loadPlaylist(.hits2026, mode: "hits 2026")
    }

    // Shared playlist loading logic
    private func loadPlaylist(_ type: PlaylistType, mode: String) {
        showLoadingView()

        Task {
            let mix = try await viewModel.loadPlaylist(type)

            AnalyticsService.shared.track(.battleStarted(mode: mode))

            await wait1second()

            UIView.animate(withDuration: 0.3) {
                self.contentView.loadingView.alpha = 0
            }

            if self.isActive {
                self.onBattleProcessTapped?(mix)
            }
        }
    }

    // MARK: - Track selection (UITextField)
    func trackSelected(input: String) -> Bool {
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return false }

        Task {
            await viewModel.didConfirmTrackSelection(text: text)
        }

        return true
    }

    // MARK: - Artists list binding
    private func bindArtistsTable() {
        viewModel.$artists
            .receive(on: DispatchQueue.main)
            .sink { [weak self] artists in
                self?.contentView.foundArtistsView.updateArtists(artists)
            }
            .store(in: &cancellables)
    }

    // MARK: - Tracks count / slider
    private func bindTracksCount() {
        viewModel.$tracksPlayCount
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.contentView.tracksCountLabel.text = "Tracks Count: \(value)"
            }
            .store(in: &cancellables)
    }

    private func setNormalSlider() {
        contentView.tracksCountSlider.value = Float(viewModel.tracksPlayCount)
        contentView.tracksCountSlider.isEnabled = false
        contentView.tracksCountLabel.text =
            "🔒 \(viewModel.tracksPlayCount) tracks, get premium for more"
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
        contentView.tracksCountSlider.addTarget(self,
                                                 action: #selector(sliderChanged(_:)),
                                                 for: .valueChanged)
    }

    @objc private func sliderChanged(_ sender: UISlider) {
        viewModel.tracksPlayCount = Int(sender.value)
    }

    // MARK: - Artist selection
    private func bindArtistSelected() {
        contentView.foundArtistsView.onArtistSelected = { [weak self] artist in
            guard let self else { return }

            Logger.log("Selected artist: \(artist.name)")
            CashedArtistService.shared.addArtist(artist)

            self.showLoadingView()

            Task {
                do {
                    let mix = try await self.viewModel.loadMix(artist: artist)

                    AnalyticsService.shared.track(.battleStarted(mode: "artist:\(artist.name)"))

                    Logger.log("Mix loaded: \(mix.count) tracks")

                    await self.wait1second()

                    UIView.animate(withDuration: 0.3) {
                        self.contentView.loadingView.alpha = 0
                    }

                    if self.isActive {
                        self.onBattleProcessTapped?(mix)
                    }

                } catch {
                    ErrorHandler.shared.handle(error)
                }
            }
        }
    }

    // MARK: - Helpers
    private func wait1second() async {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
    }
}
