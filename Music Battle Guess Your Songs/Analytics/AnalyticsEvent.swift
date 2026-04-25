import Foundation
// swiftlint:disable colon

// MARK: - Events

enum AnalyticsEvent {

    // Auth
    case signUpStarted
    case signUpCompleted(method: String)
    case loginStarted
    case loginCompleted(method: String)
    case logoutCompleted

    // Battle
    case battleStarted(mode: String)
    case battleCompleted(score: BattleScoreModel)
    case songGuessed(correct: Bool, round: Int)

    // History & Stats
    case historyViewed

    // Paywall & Subscription
    case paywallShown(source: String)
    case paywallDismissed(source: String)
    case subscriptionStarted(plan: String, price: Double)
    case subscriptionCompleted(plan: String, price: Double)
    case subscriptionFailed(plan: String, reason: String)
    case subscriptionRestored
    case trialStarted(plan: String)

    // Ads
    case adShown(type: String, placement: String)
    case adClicked(type: String, placement: String)
    case adFailed(type: String, placement: String, reason: String)
}

// MARK: - Event Mapping

extension AnalyticsEvent {

    var name: String {
        switch self {
        case .signUpStarted:              return "sign_up_started"
        case .signUpCompleted:            return "sign_up_completed"
        case .loginStarted:               return "login_started"
        case .loginCompleted:             return "login_completed"
        case .logoutCompleted:            return "logout_completed"
        case .battleStarted:              return "battle_started"
        case .battleCompleted:            return "battle_completed"
        case .historyViewed:              return "history_viewed"
        case .paywallShown:               return "paywall_shown"
        case .paywallDismissed:           return "paywall_dismissed"
        case .subscriptionStarted:        return "subscription_started"
        case .subscriptionCompleted:      return "subscription_completed"
        case .subscriptionFailed:         return "subscription_failed"
        case .subscriptionRestored:       return "subscription_restored"
        case .trialStarted:               return "trial_started"
        case .adShown:                    return "ad_shown"
        case .adClicked:                  return "ad_clicked"
        case .adFailed:                   return "ad_failed"
        case .songGuessed:                return "song_guessed"
        }
    }

    var properties: [String: Any] {
        switch self {
        case .signUpCompleted(let method),
             .loginCompleted(let method):
            return ["method": method]
            
        case .battleStarted(let mode):
            return ["mode": mode]
        case .battleCompleted(let score):
            return [
                "player_score":  score.playerScore,
                "bot_score":     score.botScore,
                "rounds_count":  score.roundsCount,
                "is_win":        score.isWin,
                "is_draw":       score.isDraw,
                "perfect_game":  score.allPlayerRightAnswers,
                "rating_change": score.ratingChange()
            ]

        case .paywallShown(let source),
             .paywallDismissed(let source):
            return ["source": source]

        case .subscriptionStarted(let plan, let price),
             .subscriptionCompleted(let plan, let price):
            return ["plan": plan, "price": price]

        case .subscriptionFailed(let plan, let reason):
            return ["plan": plan, "reason": reason]

        case .trialStarted(let plan):
            return ["plan": plan]

        case .adShown(let type, let placement),
             .adClicked(let type, let placement):
            return ["ad_type": type, "placement": placement]

        case .adFailed(let type, let placement, let reason):
            return ["ad_type": type, "placement": placement, "reason": reason]
            
        case .songGuessed(let correct, let round):
            return ["correct": correct, "round": round]
            
        default:
            return [:]
        }
    }
}
