//
//  AlertSender.swift
//  Music Battle Guess Your Songs
//
//  Created by PowerMac on 08.03.2026.
//

import UIKit

/// A protocol defining the interface for presenting alerts.
protocol AlertPresenting {
    /// Presents an alert for the given error.
    /// - Parameter error: The error to display.
    func show(error: AppError)
}

/// Responsible for presenting alert controllers to notify users of errors.
final class AlertPresenter: AlertPresenting {
    /// Presents an alert displaying the given error.
    /// - Parameter error: The error to display.
    func show(error: AppError) {
        let alert = UIAlertController(
            title: error.title,
            message: error.errorDescription,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default))

        topViewController()?.present(alert, animated: true)
    }

    /// Recursively finds the top-most view controller to present alerts on.
    /// - Parameter base: The base view controller to start the search from.
    /// - Returns: The top-most view controller if found; otherwise, `nil`.
    func topViewController(
        _ base: UIViewController? = UIApplication.shared
            .connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?
            .rootViewController
    ) -> UIViewController? {

        // Navigate through navigation, tab bar, or presented view controllers to find the top one.
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }

        if let tab = base as? UITabBarController {
            return topViewController(tab.selectedViewController)
        }

        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }

        return base
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
