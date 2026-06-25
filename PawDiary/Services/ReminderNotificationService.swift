import Foundation
import UserNotifications
import Observation

@MainActor
@Observable
final class ReminderNotificationService {
    private(set) var isAuthorized: Bool = false
    let bagheera = Bagheera()

    func requestAuthorizationIfNeeded() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .notDetermined:
            do {
                isAuthorized = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            } catch {
                isAuthorized = false
            }
        case .authorized, .provisional, .ephemeral:
            isAuthorized = true
        default:
            isAuthorized = false
        }
    }

    @discardableResult
    func schedule(
        title: String,
        body: String,
        fireDate: Date,
        kind: ReminderKind? = nil,
        identifier: String = UUID().uuidString
    ) async -> String? {
        guard fireDate > .now else { return nil }
        let voiced = bagheera.voice(title: title, body: body, kind: kind)
        let content = UNMutableNotificationContent()
        content.title = voiced.title
        content.body = voiced.body
        content.sound = .default

        let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        do {
            try await UNUserNotificationCenter.current().add(request)
            return identifier
        } catch {
            return nil
        }
    }

    func cancel(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}
