import Foundation

struct SavingsCalculator {
    static func total(applied: [AppliedSavingsTip]) -> Double {
        applied.reduce(0) { $0 + $1.totalSavedUSD }
    }

    static func recalculate(tip: AppliedSavingsTip, newTravelers: Int) -> Double {
        tip.scope == .shared
            ? tip.savedAmountPerPersonUSD
            : tip.savedAmountPerPersonUSD * Double(newTravelers)
    }

    static func apply(
        tip: SavingsTipTemplate,
        travelers: Int
    ) -> Double {
        tip.savingsScope == .shared
            ? tip.usdPerPerson
            : tip.usdPerPerson * Double(travelers)
    }
}
