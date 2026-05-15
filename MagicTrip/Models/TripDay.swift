import Foundation
import SwiftData

@Model
final class TripDay {
    var id: UUID = UUID()
    var date: Date = Date()
    var dayNumber: Int = 1
    var note: String? = nil
    var profile: TripProfile?
    @Relationship(deleteRule: .cascade) var items: [TripDayItem] = []

    var sortedItems: [TripDayItem] { items.sorted { $0.order < $1.order } }

    init(date: Date, dayNumber: Int) {
        self.date = date
        self.dayNumber = dayNumber
    }
}

@Model
final class TripDayItem {
    var id: UUID = UUID()
    var typeRaw: String = TripDayItemType.custom.rawValue
    var refID: String? = nil
    var title: String = ""
    var note: String? = nil
    var order: Int = 0
    var day: TripDay?

    var type: TripDayItemType {
        get { TripDayItemType(rawValue: typeRaw) ?? .custom }
        set { typeRaw = newValue.rawValue }
    }

    var sfSymbol: String {
        switch type {
        case .park:           return "ticket"
        case .commonActivity: return "star"
        case .custom:         return "pencil.line"
        }
    }

    init(type: TripDayItemType, refID: String?, title: String, note: String? = nil, order: Int) {
        self.typeRaw = type.rawValue
        self.refID = refID
        self.title = title
        self.note = note
        self.order = order
    }
}
