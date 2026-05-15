import Foundation

struct SeasonalityData: Codable, Identifiable {
    var id: Int { month }
    let month: Int
    let name: String
    let crowdRaw: String
    let avgTempF: Int
    let rainChancePct: Int
    let priceRaw: String
    let specialEvents: [String]
    let bestFor: [String]
    let summary: String

    enum CodingKeys: String, CodingKey {
        case month = "m", name, avgTempF = "tempF", rainChancePct = "rain", specialEvents = "events", bestFor, summary
        case crowdRaw = "crowd", priceRaw = "price"
    }

    var crowd: CrowdLevel {
        switch crowdRaw {
        case "Baixa":     return .low
        case "Média":     return .medium
        case "Alta":      return .high
        case "Muito alta": return .veryHigh
        default:          return .medium
        }
    }

    var priceLevel: PriceLevel {
        switch priceRaw {
        case "Baixo": return .low
        case "Médio": return .medium
        default:      return .high
        }
    }

    var crowdCount: Int {
        switch crowd {
        case .low:     return 1
        case .medium:  return 2
        case .high:    return 3
        case .veryHigh: return 5
        }
    }

    var crowdLabel: String { crowdRaw }
    var priceLabel: String { priceRaw }
}
