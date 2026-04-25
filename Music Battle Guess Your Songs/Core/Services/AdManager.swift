import Foundation
import GoogleMobileAds
import UIKit

final class AdManager: NSObject {

    static let shared = AdManager()

    private var interstitial: InterstitialAd?
    private var isLoading = false
    private var onDismiss: (() -> Void)?

    private override init() {}

    // MARK: - Load

    func loadInterstitial() {
        guard !isLoading else { return }
        isLoading = true

        let request = Request()
        InterstitialAd.load(
            with: RemoteConfigService.shared.addId,
            request: request
        ) { [weak self] ad, error in
            guard let self else { return }
            self.isLoading = false

            if let error {
                AnalyticsService.shared.track(.adFailed(type: "interstitial", placement: "battle_end", reason: error.localizedDescription))
                print("Ad load failed: \(error)")
                return
            }

            self.interstitial = ad
            print("Ad loaded")
        }
    }

    // MARK: - Show

    func showInterstitial(from vc: UIViewController, completion: @escaping () -> Void) {
        guard let interstitial else {
            loadInterstitial()
            completion()
            return
        }

        interstitial.fullScreenContentDelegate = self
        self.onDismiss = completion

        AnalyticsService.shared.track(.adShown(type: "interstitial", placement: "battle_end"))
        interstitial.present(from: vc)
        self.interstitial = nil
    }
}

extension AdManager: FullScreenContentDelegate {
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        onDismiss?()
        onDismiss = nil
        loadInterstitial()
    }
}
