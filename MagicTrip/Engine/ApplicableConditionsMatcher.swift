import Foundation

struct ApplicableConditionsMatcher {
    let flags: ProfileFlags

    init(profile: TripProfile) {
        self.flags = ProfileFlags(profile)
    }

    func isTipApplicable(conditions: TriggerConditions?) -> Bool {
        guard let c = conditions else { return true }
        if let v = c.country,       v != flags.country       { return false }
        if let v = c.hasSeniors,    v != flags.hasSeniors    { return false }
        if let v = c.needsMobility, v != flags.needsMobility { return false }
        if let v = c.hasYoungKid,   v != flags.hasYoungKid   { return false }
        if let v = c.hasKidUnder10, v != flags.hasKidUnder10 { return false }
        if let v = c.isFirstTrip,   v != flags.isFirstTrip   { return false }
        if let v = c.allAdults,     v != flags.allAdults     { return false }
        return true
    }

    static func isTipApplicable(conditions: TriggerConditions?, profile: TripProfile) -> Bool {
        ApplicableConditionsMatcher(profile: profile).isTipApplicable(conditions: conditions)
    }
}
