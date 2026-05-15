import Foundation

@Observable
final class CatalogLoader {
    private(set) var tasks: [TaskTemplate] = []
    private(set) var seasonality: [SeasonalityData] = []
    private(set) var commonActivities: [CommonActivity] = []
    private(set) var countries: [CountryEntry] = []

    static let shared = CatalogLoader()

    private init() { load() }

    private func load() {
        tasks = decode("tasks", as: [TaskTemplate].self) ?? []
        seasonality = decode("seasonality", as: [SeasonalityData].self) ?? []
        commonActivities = decode("common_activities", as: [CommonActivity].self) ?? []
        countries = decode("countries", as: [CountryEntry].self) ?? []
    }

    private func decode<T: Decodable>(_ name: String, as type: T.Type) -> T? {
        let url = Bundle.main.url(forResource: name, withExtension: "json", subdirectory: "Catalog")
            ?? Bundle.main.url(forResource: name, withExtension: "json")
        guard let url, let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }

    func parkOptions() -> [ParkGroup] {
        tasks.first(where: { $0.id == "P-01" })?.groups ?? []
    }

    func template(id: String) -> TaskTemplate? {
        tasks.first(where: { $0.id == id })
    }

    func commonActivitiesByCategory() -> [(String, [CommonActivity])] {
        var dict: [String: [CommonActivity]] = [:]
        for a in commonActivities {
            dict[a.category, default: []].append(a)
        }
        return dict.map { ($0.key, $0.value) }.sorted { $0.0 < $1.0 }
    }
}

struct CountryEntry: Codable, Identifiable {
    let code: String
    let name: String
    let flag: String
    let pinned: Bool?

    var id: String { code }
}
