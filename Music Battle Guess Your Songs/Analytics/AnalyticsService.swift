//
//  AnalyticsService.swift
//  Music Battle Guess Your Songs
//
//  Created by PowerMac on 05.04.2026.
//

import Foundation
import AmplitudeSwift
import FirebaseCrashlytics

// MARK: - AnalyticsService

final class AnalyticsService {

    static let shared = AnalyticsService()

    private var amplitude: Amplitude?
    
    func setIDFA(_ idfa: String) {
        let identify = Identify()
        identify.set(property: "idfa", value: idfa)
        amplitude?.identify(identify: identify)
    }

    private init() {}

    // MARK: - Setup

    func configure(apiKey: String) {
        amplitude = Amplitude(configuration: Configuration(
            apiKey: apiKey,
            logLevel: .warn
        ))
    }

    // MARK: - Track

    func track(_ event: AnalyticsEvent) {
        guard let amplitude else {
            assertionFailure("AnalyticsService: configure(apiKey:) not called")
            return
        }
        let props = event.properties
        amplitude.track(
            eventType: event.name,
            eventProperties: props.isEmpty ? nil : props
        )
        Crashlytics.crashlytics().log(event.name)
    }

    // MARK: - Revenue

    func trackRevenue(plan: String, price: Double, currency: String = "USD") {
        guard let amplitude else { return }

        let revenue = Revenue()
        revenue.price = price
        revenue.productId = plan
        revenue.quantity = 1
        amplitude.revenue(revenue: revenue)
    }

    // MARK: - Reset

    func reset() {
        amplitude?.reset()
        Crashlytics.crashlytics().setUserID("")
    }
}
