import Foundation

// MARK: - Task template structures (decoded from tasks.json)

struct TaskTemplate: Codable, Identifiable {
    let id: String
    let title: String
    let categoryRaw: String
    let taskTypeRaw: String?
    let priorityRaw: String
    let deadlineDays: Int?
    let requiresDate: Bool
    let scope: String            // "GLOBAL" | "BR"
    let description: String
    let moreInfoUrl: String?
    let moreInfoLabel: String?
    let tips: [TipTemplate]
    let savings: [SavingsTipTemplate]
    let triggers: TriggerConditions
    let requires: [DependencyCondition]?
    let conditionalDeadline: ConditionalDeadlineSpec?
    let decision: DecisionSpec?
    let groups: [ParkGroup]?     // for multi_select_grouped

    enum CodingKeys: String, CodingKey {
        case id, title, description, tips, savings, triggers, requires, decision, groups
        case categoryRaw = "category"
        case taskTypeRaw = "taskType"
        case priorityRaw = "priority"
        case deadlineDays
        case requiresDate
        case scope
        case moreInfoUrl
        case moreInfoLabel
        case conditionalDeadline
    }

    var category: TaskCategory {
        switch categoryRaw {
        case "planning":      return .planning
        case "documentation": return .documentation
        case "finance":       return .finance
        case "lodging":       return .lodging
        case "transport":     return .transport
        case "parks":         return .parks
        case "daily":         return .dailyLogistics
        case "shopping":      return .shopping
        case "health":        return .health
        case "return":        return .returnHome
        default:              return .planning
        }
    }

    var taskType: TaskType {
        switch taskTypeRaw {
        case "decision":             return .decision
        case "multi_select_grouped": return .multiSelectGrouped
        case "confirmation":         return .confirmation
        default:                     return .action
        }
    }

    var priority: TaskPriority {
        switch priorityRaw {
        case "critical": return .critical
        case "high":     return .high
        case "medium":   return .medium
        default:         return .low
        }
    }
}

struct TipTemplate: Codable, Identifiable {
    let id: String?
    let title: String?
    let body: String?
    let moreInfoUrl: String?
    let moreInfoLabel: String?
    let applicableConditions: TriggerConditions?

    enum CodingKeys: String, CodingKey {
        case id, title, moreInfoUrl, moreInfoLabel, applicableConditions
        case body = "description"
    }

    // In the JSON, tips can be just strings OR structured objects
    init(from decoder: Decoder) throws {
        if let str = try? decoder.singleValueContainer().decode(String.self) {
            id = UUID().uuidString; title = nil; body = str
            moreInfoUrl = nil; moreInfoLabel = nil; applicableConditions = nil
        } else {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            id = try c.decodeIfPresent(String.self, forKey: .id)
            title = try c.decodeIfPresent(String.self, forKey: .title)
            body = try c.decodeIfPresent(String.self, forKey: .body)
            moreInfoUrl = try c.decodeIfPresent(String.self, forKey: .moreInfoUrl)
            moreInfoLabel = try c.decodeIfPresent(String.self, forKey: .moreInfoLabel)
            applicableConditions = try c.decodeIfPresent(TriggerConditions.self, forKey: .applicableConditions)
        }
    }

    var displayText: String { body ?? title ?? "" }
}

struct SavingsTipTemplate: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let usdPerPerson: Double
    let scope: String?
    let moreInfoUrl: String?
    let moreInfoLabel: String?
    let applicableConditions: TriggerConditions?

    enum CodingKeys: String, CodingKey {
        case id, title, description, scope, moreInfoUrl, moreInfoLabel, applicableConditions
        case usdPerPerson = "usd"
    }

    var savingsScope: SavingsScope {
        scope == "shared" ? .shared : .perPerson
    }
}

struct TriggerConditions: Codable {
    let country: String?
    let planning: String?
    let hasVisa: Bool?
    let hasPassport: Bool?
    let hasSeniors: Bool?
    let needsMobility: Bool?
    let hasYoungKid: Bool?
    let hasKidUnder10: Bool?
    let allAdults: Bool?
    let durationLong: Bool?
    let isFirstTrip: Bool?

    init(
        country: String? = nil, planning: String? = nil,
        hasVisa: Bool? = nil, hasPassport: Bool? = nil,
        hasSeniors: Bool? = nil, needsMobility: Bool? = nil,
        hasYoungKid: Bool? = nil, hasKidUnder10: Bool? = nil,
        allAdults: Bool? = nil, durationLong: Bool? = nil,
        isFirstTrip: Bool? = nil
    ) {
        self.country = country; self.planning = planning; self.hasVisa = hasVisa
        self.hasPassport = hasPassport; self.hasSeniors = hasSeniors
        self.needsMobility = needsMobility; self.hasYoungKid = hasYoungKid
        self.hasKidUnder10 = hasKidUnder10; self.allAdults = allAdults
        self.durationLong = durationLong; self.isFirstTrip = isFirstTrip
    }
}

struct DependencyCondition: Codable {
    let task: String
    let answerIn: [String]?
    let answerContainsAny: [String]?
    let answerContainsAll: [String]?

    enum CodingKeys: String, CodingKey {
        case task, answerIn, answerContainsAny, answerContainsAll
    }
}

struct ConditionalDeadlineSpec: Codable {
    let rules: [ConditionalDeadlineRule]
    let fallbackDays: Int
}

struct ConditionalDeadlineRule: Codable {
    let condition: DependencyCondition
    let days: Int
}

struct DecisionSpec: Codable {
    let question: String
    let options: [DecisionOption]
}

struct DecisionOption: Codable, Identifiable {
    let id: String
    let label: String
    let subtitle: String?
}

struct ParkGroup: Codable, Identifiable {
    let id: String
    let label: String
    let options: [ParkOption]
}

struct ParkOption: Codable, Identifiable {
    let id: String
    let label: String
    let recommendedVisits: Int?
    let moreInfoUrl: String?
    let moreInfoLabel: String?
}
