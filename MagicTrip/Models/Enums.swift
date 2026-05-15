import Foundation

enum PlanningStatus: String, Codable {
    case dateConfirmed
    case undecided
}

enum TaskType: String, Codable {
    case action
    case decision
    case multiSelectGrouped
    case confirmation
}

enum TaskStatus: String, Codable {
    case pending, inProgress, completed, skipped, archived, locked, hidden
}

enum TaskCategory: String, Codable, CaseIterable {
    case planning
    case documentation
    case finance
    case lodging
    case transport
    case parks
    case dailyLogistics
    case shopping
    case health
    case returnHome

    var label: String {
        switch self {
        case .planning:       return String(localized: "Planejamento")
        case .documentation:  return String(localized: "Documentação")
        case .finance:        return String(localized: "Finanças")
        case .lodging:        return String(localized: "Hospedagem")
        case .transport:      return String(localized: "Transporte")
        case .parks:          return String(localized: "Parques e ingressos")
        case .dailyLogistics: return String(localized: "Logística diária")
        case .shopping:       return String(localized: "Compras")
        case .health:         return String(localized: "Saúde")
        case .returnHome:     return String(localized: "Volta ao Brasil")
        }
    }

    var sfSymbol: String {
        switch self {
        case .planning:       return "calendar"
        case .documentation:  return "person.text.rectangle"
        case .finance:        return "dollarsign.circle"
        case .lodging:        return "bed.double"
        case .transport:      return "airplane"
        case .parks:          return "ticket"
        case .dailyLogistics: return "sun.max"
        case .shopping:       return "bag"
        case .health:         return "heart"
        case .returnHome:     return "house"
        }
    }
}

enum TaskPriority: String, Codable {
    case critical, high, medium, low

    var label: String {
        switch self {
        case .critical: return String(localized: "Crítica")
        case .high:     return String(localized: "Alta")
        case .medium:   return String(localized: "Média")
        case .low:      return String(localized: "Baixa")
        }
    }
}

enum SavingsScope: String, Codable {
    case perPerson
    case shared
}

enum TripDayItemType: String, Codable {
    case park
    case commonActivity
    case custom
}

enum CrowdLevel: String, Codable {
    case low, medium, high, veryHigh

    var label: String {
        switch self {
        case .low:     return String(localized: "Baixa")
        case .medium:  return String(localized: "Média")
        case .high:    return String(localized: "Alta")
        case .veryHigh: return String(localized: "Muito alta")
        }
    }
}

enum PriceLevel: String, Codable {
    case low, medium, high

    var label: String {
        switch self {
        case .low:    return String(localized: "Baixo")
        case .medium: return String(localized: "Médio")
        case .high:   return String(localized: "Alto")
        }
    }
}
