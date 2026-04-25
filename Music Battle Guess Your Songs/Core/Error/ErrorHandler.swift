import Foundation
import FirebaseCrashlytics

extension Notification.Name {
    static let appError = Notification.Name("appError")
}
final class ErrorHandler {

    /// Convenience shared instance for singleton usage.
    static let shared = ErrorHandler(alertPresenter: AlertPresenter())

    private var alertPresenter: AlertPresenting

    init(alertPresenter: AlertPresenting) {
        self.alertPresenter = alertPresenter
    }

    // MARK: - Error Severity

    enum Severity {
        case info
        case warning
        case critical

        var shouldReport: Bool {
            self == .critical
        }
    }

    // MARK: - Public API

    func handle(
        _ error: Error,
        severity: Severity = .warning,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {

        let appError = map(error)
        
        log(
            error: appError,
            severity: severity,
            file: file,
            function: function,
            line: line
        )

        if severity != .info {
            alertPresenter.show(error: appError)
        }

        reportIfNeeded(appError, severity: severity)
    }

    // MARK: - Mapping

    private func map(_ error: Error) -> AppError {
        if let error = error as? AppError {
            return error
        }

        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet:
                return .network
            default:
                return .unknown(error)
            }
        }
        return .unknown(error)
    }

    // MARK: - Logging

    private func log(
        error: AppError,
        severity: Severity,
        file: String,
        function: String,
        line: Int
    ) {
        #if DEBUG
        print("""
        ❗️Error captured
        Severity: \(severity)
        Error: \(error.localizedDescription)
        Location: \(file):\(line)
        Function: \(function)
        """)
        #endif
        Crashlytics.crashlytics().log("\(severity) | \(file):\(line) \(function) — \(error.localizedDescription)")

    }

    // MARK: - External Reporting

    private func reportIfNeeded(_ error: AppError, severity: Severity) {
        guard severity.shouldReport else { return }
        
        let crashlytics = Crashlytics.crashlytics()
        crashlytics.setValue("\(severity)", forKey: "severity")
        crashlytics.record(error: error)
    }
}
