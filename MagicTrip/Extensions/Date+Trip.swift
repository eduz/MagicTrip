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

    func calendarFormatted(country: String, shortYear: Bool = false) -> String {
        let f = DateFormatter()
        let isUS = country == "US"
        f.dateFormat = isUS
            ? (shortYear ? "MM/dd/yy" : "MM/dd/yyyy")
            : (shortYear ? "dd/MM/yy" : "dd/MM/yyyy")
        f.locale = Locale(identifier: isUS ? "en_US" : "pt_BR")
        let datePart = f.string(from: self)
        let weekF = DateFormatter()
        weekF.dateFormat = "EEE"
        weekF.locale = f.locale
        let weekDay = weekF.string(from: self).capitalized
        return "\(datePart) (\(weekDay))"
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
