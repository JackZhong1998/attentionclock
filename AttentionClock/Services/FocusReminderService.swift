import Foundation
import UserNotifications

@MainActor
final class FocusReminderService: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = FocusReminderService()

    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    func notifySessionCompleted(minutes: Int) {
        let effect = FocusReminderMessages.nextEffect()
        let content = UNMutableNotificationContent()
        content.title = String(localized: "专注完成")
        content.body = L10n.sessionCompletedBody(minutes: minutes, effect: effect)
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request)
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}
