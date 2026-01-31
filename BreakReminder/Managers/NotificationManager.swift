import Foundation
import UserNotifications

@MainActor
class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()

    @Published var isAuthorized = false
    private var timers: [ReminderType: Timer] = [:]

    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        setupNotificationCategories()
        checkAuthorization()
    }

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            Task { @MainActor in
                self.isAuthorized = granted
                if granted {
                    self.startAllReminders()
                }
            }
            if let error = error {
                print("Notification authorization error: \(error)")
            }
        }
    }

    func checkAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            Task { @MainActor in
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }

    private func setupNotificationCategories() {
        let acknowledgeAction = UNNotificationAction(
            identifier: "ACKNOWLEDGE",
            title: "Got it!",
            options: [.foreground]
        )

        for reminderType in ReminderType.allCases {
            let category = UNNotificationCategory(
                identifier: reminderType.rawValue,
                actions: [acknowledgeAction],
                intentIdentifiers: [],
                options: []
            )
            UNUserNotificationCenter.current().setNotificationCategories([category])
        }

        // Set all categories at once
        let categories = Set(ReminderType.allCases.map { type in
            UNNotificationCategory(
                identifier: type.rawValue,
                actions: [acknowledgeAction],
                intentIdentifiers: [],
                options: []
            )
        })
        UNUserNotificationCenter.current().setNotificationCategories(categories)
    }

    func startReminder(for type: ReminderType) {
        stopReminder(for: type)

        let interval = getInterval(for: type)
        guard isEnabled(for: type) else { return }

        let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.sendNotification(for: type)
            }
        }
        timers[type] = timer

        print("Started \(type.displayName) reminder every \(Int(interval / 60)) minutes")
    }

    func stopReminder(for type: ReminderType) {
        timers[type]?.invalidate()
        timers[type] = nil
    }

    func startAllReminders() {
        for type in ReminderType.allCases {
            if isEnabled(for: type) {
                startReminder(for: type)
            }
        }
    }

    func stopAllReminders() {
        for type in ReminderType.allCases {
            stopReminder(for: type)
        }
    }

    func restartReminder(for type: ReminderType) {
        if isEnabled(for: type) {
            startReminder(for: type)
        } else {
            stopReminder(for: type)
        }
    }

    private func sendNotification(for type: ReminderType) {
        let content = UNMutableNotificationContent()
        content.title = type.notificationTitle
        content.body = type.notificationBody
        content.sound = .default
        content.categoryIdentifier = type.rawValue
        content.interruptionLevel = .timeSensitive

        let request = UNNotificationRequest(
            identifier: "\(type.rawValue)_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil  // Deliver immediately
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to send notification: \(error)")
            }
        }
    }

    // MARK: - Settings

    func getInterval(for type: ReminderType) -> TimeInterval {
        let stored = UserDefaults.standard.double(forKey: type.intervalKey)
        return stored > 0 ? stored : type.defaultInterval
    }

    func setInterval(_ interval: TimeInterval, for type: ReminderType) {
        let clamped = min(max(interval, type.minInterval), type.maxInterval)
        UserDefaults.standard.set(clamped, forKey: type.intervalKey)
        restartReminder(for: type)
    }

    func isEnabled(for type: ReminderType) -> Bool {
        if UserDefaults.standard.object(forKey: type.enabledKey) == nil {
            return true  // Enabled by default
        }
        return UserDefaults.standard.bool(forKey: type.enabledKey)
    }

    func setEnabled(_ enabled: Bool, for type: ReminderType) {
        UserDefaults.standard.set(enabled, forKey: type.enabledKey)
        restartReminder(for: type)
    }

    // Test notification
    func sendTestNotification(for type: ReminderType) {
        sendNotification(for: type)
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationManager: UNUserNotificationCenterDelegate {
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound])
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // Handle notification tap or action
        print("User acknowledged: \(response.notification.request.content.title)")
        completionHandler()
    }
}
