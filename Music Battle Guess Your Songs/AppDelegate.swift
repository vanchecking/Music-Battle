import UIKit
import FirebaseCore
import GoogleMobileAds
import Adapty
import AmplitudeUnified

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        RemoteConfigService.shared.fetch()
        AnalyticsService.shared.configure(apiKey: RemoteConfigService.shared.amplitudeUnifiedKey)

        MusicService.shared.preloadMusicKit()
        MobileAds.shared.start(completionHandler: nil)
        Task {
            do {
                try await SubscriptionService.shared.activate()
            } catch {
                ErrorHandler.shared.handle(error, severity: .info)
            }
        }
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
