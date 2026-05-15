import Foundation

struct CommonActivity: Codable, Identifiable {
    let id: String
    let category: String
    let title: String
    let description: String?
    let moreInfoUrl: String?
    let moreInfoLabel: String?
    let typicalDurationHint: String?

    enum CodingKeys: String, CodingKey {
        case id, category, title, description, moreInfoUrl, moreInfoLabel
        case typicalDurationHint = "dur"
    }
}
