import Foundation
import SwiftData

@Model
final class TripProfile {
    var id: UUID = UUID()
    var country: String = "BR"
    var planningStatusRaw: String = PlanningStatus.dateConfirmed.rawValue
    var departureDate: Date? = nil
    var returnDate: Date? = nil
    var tentativeYear: Int? = nil
    var tentativeMonthStart: Int? = nil
    var tentativeMonthEnd: Int? = nil
    var tentativeDurationDays: Int = 10
    var adults: Int = 2
    var seniors: Int = 0
    var reducedMobility: Bool = false
    var budgetUSD: Double? = nil
    var hasVisa: Bool = false
    var hasValidPassport: Bool = true
    var passportExpiry: Date? = nil
    var isFirstTrip: Bool = true
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    @Relationship(deleteRule: .cascade) var children: [Child] = []
    @Relationship(deleteRule: .cascade) var taskResponses: [TaskResponse] = []
    @Relationship(deleteRule: .cascade) var appliedSavings: [AppliedSavingsTip] = []
    @Relationship(deleteRule: .cascade) var tripDays: [TripDay] = []

    var planningStatus: PlanningStatus {
        get { PlanningStatus(rawValue: planningStatusRaw) ?? .dateConfirmed }
        set { planningStatusRaw = newValue.rawValue }
    }

    var totalTravelers: Int { adults + seniors + children.count }

    var durationDays: Int? {
        guard let dep = departureDate, let ret = returnDate else { return nil }
        return Calendar.current.dateComponents([.day], from: dep, to: ret).day
    }

    var isLongTrip: Bool { (durationDays ?? 0) > 7 }

    init() {}
}
