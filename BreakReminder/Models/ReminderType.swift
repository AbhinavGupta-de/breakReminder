import Foundation

enum ReminderType: String, CaseIterable, Identifiable {
    case water = "water"
    case eyeRest = "eyeRest"
    case walk = "walk"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .water: return "Drink Water"
        case .eyeRest: return "Eye Rest"
        case .walk: return "Take a Walk"
        }
    }

    var systemImage: String {
        switch self {
        case .water: return "drop"
        case .eyeRest: return "eye"
        case .walk: return "figure.walk"
        }
    }

    var notificationTitle: String {
        switch self {
        case .water: return "Time to Hydrate!"
        case .eyeRest: return "Rest Your Eyes!"
        case .walk: return "Time to Move!"
        }
    }

    var notificationBody: String {
        switch self {
        case .water: return "Take a moment to drink some water. Stay hydrated!"
        case .eyeRest: return "Look away from the screen. Focus on something 20 feet away for 20 seconds."
        case .walk: return "Stand up and take a short walk. Touch some grass!"
        }
    }

    var defaultInterval: TimeInterval {
        switch self {
        case .water: return 30 * 60      // 30 minutes
        case .eyeRest: return 20 * 60    // 20 minutes
        case .walk: return 60 * 60       // 60 minutes
        }
    }

    var minInterval: TimeInterval {
        switch self {
        case .water: return 10 * 60
        case .eyeRest: return 10 * 60
        case .walk: return 15 * 60
        }
    }

    var maxInterval: TimeInterval {
        switch self {
        case .water: return 120 * 60
        case .eyeRest: return 60 * 60
        case .walk: return 180 * 60
        }
    }

    var intervalKey: String {
        return "interval_\(rawValue)"
    }

    var enabledKey: String {
        return "enabled_\(rawValue)"
    }
}
