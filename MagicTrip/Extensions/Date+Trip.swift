import Foundation

extension Date {
    var daysFromNow: Int {
        Calendar.current.dateComponents([.day], from: .now, to: self).day ?? 0
    }

    var tripDayFormatted: String {
        let f = DateFormatter()
        f.dateFormat = "EEE, d 'de' MMM"
        f.locale = Locale.current
        return f.string(from: self).capitalized
    }

    static func tripDays(from start: Date, to end: Date) -> [Date] {
        var dates: [Date] = []
        var current = Calendar.current.startOfDay(for: start)
        let last = Calendar.current.startOfDay(for: end)
        while current <= last {
            dates.append(current)
            current = Calendar.current.date(byAdding: .day, value: 1, to: current)!
        }
        return dates
    }

    var isToday: Bool { Calendar.current.isDateInToday(self) }
    var isPast: Bool  { self < Calendar.current.startOfDay(for: .now) }

    var shortFormatted: String {
        let f = DateFormatter()
        f.dateFormat = "dd/MM/yyyy"
        return f.string(from: self)
    }
}
