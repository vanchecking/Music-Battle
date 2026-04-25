//
//  SubscriptionService.swift
//

import Foundation
import Adapty
internal import AdaptyLogger
import Combine

final class SubscriptionService {
    static let shared = SubscriptionService()
    private var paywall: AdaptyPaywall?
    private var products: [AdaptyPaywallProduct] = []
    @Published var isPremium: Bool = false
    
    // MARK: - Public
    
    func syncUserAccess() async -> Bool {
            do {
                isPremium = try await validateAccess()
            } catch {
                Logger.log("err on sync user access: \(error)")
                isPremium = false
            }
            return isPremium
    }
    
    func activate() async throws {
        do {
            let configuration = AdaptyConfiguration
                .builder(withAPIKey: RemoteConfigService.shared.adaptyKey)
                .with(logLevel: .verbose)
                .with(idfaCollectionDisabled: true)
                .with(ipAddressCollectionDisabled: true)
                .build()
            
            try await Adapty.activate(with: configuration)
            await preloadProducts()
            _ = await syncUserAccess()
        } catch {
            throw AppError.unknown(error)
        }
    }
    
    func preloadProducts() async {
        do {
            let paywall = try await getPaywall()
            _ = try await getProducts(paywall: paywall)
        } catch {
            Logger.log("error on preload products: \(error)")
        }
    }
    
    func fetchProducts() async throws -> [AdaptyPaywallProduct] {
        let paywall = try await getPaywall()
        return try await getProducts(paywall: paywall)
    }
    
    func purchase(product: AdaptyPaywallProduct) async throws -> Bool {
        do {
            _ = try await makePurchase(product: product)
            return await syncUserAccess()

        } catch {
            throw AppError.purchaseFailed
        }
    }
    
    func restore() async throws -> Bool {
        do {
            _ = try await restorePurchases()
            return await syncUserAccess()

        } catch let error as AppError {
            throw error
        } catch {
            throw AppError.unknown(error)
        }
    }
    
    // MARK: - Private
    
    private func getPaywall() async throws -> AdaptyPaywall {
        do {
            if let savedPaywall = self.paywall {
                return savedPaywall
            }
            let paywall = try await Adapty.getPaywall(placementId: "placement_id")
            self.paywall = paywall
            return paywall
        } catch {
            throw AppError.unknown(error)
        }
    }
    
    private func getProducts(paywall: AdaptyPaywall) async throws -> [AdaptyPaywallProduct] {
        do {
            let products = try await Adapty.getPaywallProducts(paywall: paywall)
            guard !products.isEmpty else {
                throw AppError.productsNotFound
            }
            self.products = products
            return products
        } catch {
            throw AppError.unknown(error)
        }
    }
    
    private func makePurchase(product: AdaptyPaywallProduct) async throws -> AdaptyPurchaseResult {
        do {
            return try await Adapty.makePurchase(product: product)
        } catch {
            throw AppError.unknown(error)
        }
    }
    
    private func restorePurchases() async throws -> AdaptyProfile {
        do {
            return try await Adapty.restorePurchases()
        } catch {
            throw AppError.unknown(error)
        }
    }
    
    private func validateAccess() async throws -> Bool {
        let profile = try await getProfile()
        
        guard let access = profile.accessLevels["premium"] else {
            throw AppError.accessLevelMissing
        }
        
        return access.isActive
    }
    
    private func getProfile() async throws -> AdaptyProfile {
        do {
            return try await Adapty.getProfile()
        } catch {
            throw AppError.unknown(error)
        }
    }
}
