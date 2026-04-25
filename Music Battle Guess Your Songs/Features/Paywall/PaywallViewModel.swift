import Foundation
import Adapty
import UIKit

final class PaywallViewModel {

    // MARK: - Output
    var onProductsLoaded: (([AdaptyPaywallProduct]) -> Void)?
    var onLoadingChanged: ((Bool) -> Void)?
    var onError: ((String) -> Void)?
    var onPurchaseResult: ((Bool) -> Void)?
    var onSelectionChanged: ((Int) -> Void)?

    // MARK: - Dependencies
    private let service: SubscriptionService

    private(set) var products: [AdaptyPaywallProduct] = []
    private(set) var selectedIndex: Int = 0

    init(service: SubscriptionService) {
        self.service = service
    }

    // MARK: - Load

    func load() {
        onLoadingChanged?(true)

        Task {
            do {
                let result = try await service.fetchProducts()
                products = result.sorted { $0.price < $1.price }
                selectedIndex = products.count > 1 ? 1 : 0

                onProductsLoaded?(products)
                onLoadingChanged?(false)
                onSelectionChanged?(selectedIndex)
            } catch {
                onLoadingChanged?(false)
                onError?(error.localizedDescription)
            }
        }
    }

    // MARK: - Select

    func select(index: Int) {
        selectedIndex = index
        onSelectionChanged?(index)
    }

    // MARK: - Purchase

    func purchase() {
        guard products.indices.contains(selectedIndex) else { return }

        let product = products[selectedIndex]
        let plan = product.vendorProductId
        let price = NSDecimalNumber(decimal: product.price).doubleValue

        onLoadingChanged?(true)
        AnalyticsService.shared.track(.subscriptionStarted(plan: plan, price: price))

        Task {
            do {
                let result = try await service.purchase(product: product)
                onLoadingChanged?(false)

                if result {
                    AnalyticsService.shared.track(.subscriptionCompleted(plan: plan, price: price))
                    AnalyticsService.shared.trackRevenue(plan: plan, price: price)
                }

                onPurchaseResult?(result)
            } catch {
                onLoadingChanged?(false)
                AnalyticsService.shared.track(.subscriptionFailed(plan: plan, reason: error.localizedDescription))
                onError?(error.localizedDescription)
            }
        }
    }

    // MARK: - Restore

    func restore() {
        onLoadingChanged?(true)

        Task {
            do {
                let result = try await service.restore()
                onLoadingChanged?(false)

                if result {
                    AnalyticsService.shared.track(.subscriptionRestored)
                }

                onPurchaseResult?(result)
            } catch {
                onLoadingChanged?(false)
                onError?(error.localizedDescription)
            }
        }
    }

    // MARK: - Links

    func openPrivacy() {
        if let url = URL(string: RemoteConfigService.shared.privacy) {
            UIApplication.shared.open(url)
        }
    }

    func openTerms() {
        if let url = URL(string: RemoteConfigService.shared.terms) {
            UIApplication.shared.open(url)
        }
    }

    // MARK: - Helpers

    func calculateDiscount() -> String {
        guard products.count >= 2 else { return "" }

        let monthly = products[0]
        let yearly = products[1]

        guard monthly.price > 0 else { return "" }

        let yearlyPerMonth = yearly.price / 12
        let discount = ((monthly.price - yearlyPerMonth) / monthly.price) * 100

        let rounded = NSDecimalNumber(decimal: discount).doubleValue
        return rounded > 0 ? "-\(Int(rounded.rounded()))%" : "0%"
    }
}
