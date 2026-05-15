import UserNotifications
import Foundation

final class NotificationScheduler {
    static let shared = NotificationScheduler()
    private init() {}

    func requestPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let granted = try? await center.requestAuthorization(options: [.alert, .badge, .sound])
        return granted ?? false
    }

    func scheduleAll(for profile: TripProfile, tasks: [ResolvedTask]) {
        cancelAll()
        guard profile.planningStatus == .dateConfirmed,
              let departure = profile.departureDate else { return }

        let content = UNMutableNotificationContent()
        let center = UNUserNotificationCenter.current()

        // Task deadline notifications
        for task in tasks where task.effectiveDeadlineDays != nil && !task.isCompleted && !task.isSkipped {
            guard let days = task.effectiveDeadlineDays else { continue }
            let deadlineDate = departure.addingTimeInterval(TimeInterval(-days * 86400))
            for advance in [30, 14, 7] {
                let fireDate = deadlineDate.addingTimeInterval(TimeInterval(-advance * 86400))
                if fireDate > Date() {
                    let c = UNMutableNotificationContent()
                    c.title = task.title
                    c.body = String(format: NSLocalizedString("Faltam %d dias para concluir esta tarefa.", comment: ""), advance)
                    c.sound = .default
                    c.userInfo = ["taskID": task.id]
                    let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
                    let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
                    let request = UNNotificationRequest(identifier: "task_\(task.id)_\(advance)d", content: c, trigger: trigger)
                    center.add(request)
                }
            }
        }

        // Day-before trip notification
        let dayBefore = departure.addingTimeInterval(-86400)
        if dayBefore > Date() {
            content.title = NSLocalizedString("Sua viagem é amanhã! 🎢", comment: "")
            content.body = NSLocalizedString("Confira sua checklist de embarque.", comment: "")
            content.sound = .default
            var comps = Calendar.current.dateComponents([.year, .month, .day], from: dayBefore)
            comps.hour = 9
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
            center.add(UNNotificationRequest(identifier: "trip_tomorrow", content: content, trigger: trigger))
        }

        // e-DBV notification (BR only)
        if profile.country == "BR", let returnDate = profile.returnDate, returnDate > Date() {
            let c = UNMutableNotificationContent()
            c.title = NSLocalizedString("🛂 Não esqueça da e-DBV!", comment: "")
            c.body = NSLocalizedString("Preencha a Declaração de Bagagem antes de pousar.", comment: "")
            c.sound = .default
            var comps = Calendar.current.dateComponents([.year, .month, .day], from: returnDate)
            comps.hour = 8
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
            center.add(UNNotificationRequest(identifier: "edbv_reminder", content: c, trigger: trigger))
        }
    }

    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
