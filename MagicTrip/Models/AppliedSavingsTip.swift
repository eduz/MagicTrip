import Foundation
import SwiftData

@Model
final class AppliedSavingsTip {
    var id: UUID = UUID()
    var tipID: String = ""
    var taskID: String = ""
    var savedAmountPerPersonUSD: Double = 0
    var travelersCountAtApplication: Int = 1
    var scopeRaw: String = SavingsScope.perPerson.rawValue
    var totalSavedUSD: Double = 0
    var appliedAt: Date = Date()
    var profile: TripProfile?

    var scope: SavingsScope {
        get { SavingsScope(rawValue: scopeRaw) ?? .perPerson }
        set { scopeRaw = newValue.rawValue }
    }

    init(tipID: String, taskID: String, amountPerPerson: Double, travelers: Int, scope: SavingsScope) {
        self.tipID = tipID
        self.taskID = taskID
        self.savedAmountPerPersonUSD = amountPerPerson
        self.travelersCountAtApplication = travelers
        self.scopeRaw = scope.rawValue
        self.totalSavedUSD = scope == .shared ? amountPerPerson : amountPerPerson * Double(travelers)
    }
}
