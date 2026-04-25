import UIKit

final class HomeViewController: UIViewController {

    let viewModel: HomeViewModel
    private let contentView = HomeView()

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = contentView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        bind()
        viewModel.loadProfile()

        contentView.actionButtonsView.startBattleButton.addTarget(
            self,
            action: #selector(startBattleTapped),
            for: .touchUpInside
        )

        contentView.actionButtonsView.premiumButton.addTarget(
            self,
            action: #selector(settingsTapped),
            for: .touchUpInside
        )

        contentView.actionButtonsView.logoutButton.addTarget(
            self,
            action: #selector(logoutTapped),
            for: .touchUpInside
        )

        contentView.actionButtonsView.battleHistoryButton.addTarget(
            self,
            action: #selector(battleHistoryTapped),
            for: .touchUpInside
        )
    }

    private func bind() {
        viewModel.onStateChange = { [weak self] state in
            DispatchQueue.main.async {
                self?.handle(state)
            }
        }
    }

    private func handle(_ state: HomeViewState) {
        switch state {
        case .loading:
            contentView.renderLoading()

        case .content(let content):
            contentView.renderContent(content)

        case .error(let message):
            contentView.renderError(message)
        }
    }

    @objc private func startBattleTapped() {
        Logger.log("Start battle tapped")

        Task {
            do {
                try await MusicService.shared.requestAuthorization()
                viewModel.toBattleMode()
            } catch {
                ErrorHandler.shared.handle(error)
            }
        }
    }

    @objc private func logoutTapped() {
        viewModel.logout()
//        Task {
//            try await CloudKitService.shared.deleteUserProfile(userID: CloudKitService.shared.currentUser?.userID ?? "")
//        }
//        
    }

    @objc private func battleHistoryTapped() {
        Logger.log("Battle history tapped")
        self.viewModel.onBattleHistoryTapped?()
    }

    @objc private func settingsTapped() {
        Logger.log("Settings tapped")
        self.viewModel.onSettingsTapped?()
    }
    deinit {
        Logger.log("Deinit")
    }

}
