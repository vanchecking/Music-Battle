//
//  ATTManager.swift
//  Music Battle Guess Your Songs
//
//  Created by PowerMac on 05.04.2026.
//

import AppTrackingTransparency
import AdSupport
import AmplitudeSwift

final class ATTManager {
    static let shared = ATTManager()
    private init() {}

    func requestPermission() async {
        try? await Task.sleep(nanoseconds: 1_000_000_000)

        let status = await ATTrackingManager.requestTrackingAuthorization()

        switch status {
        case .authorized:
            let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
            //  IDFA in Amplitude for precise atribution
            let identify = Identify()
            identify.set(property: "idfa", value: idfa)
            AnalyticsService.shared.setIDFA(idfa)
        default:
            break
        }
    }

    func checkATTStatus() {
        guard ATTrackingManager.trackingAuthorizationStatus == .authorized else { return }
        let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        let identify = Identify()
        identify.set(property: "idfa", value: idfa)
        AnalyticsService.shared.setIDFA(idfa)
    }
}
