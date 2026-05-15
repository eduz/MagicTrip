import Foundation

@Observable
final class ExchangeRateService {
    private(set) var usdToBRL: Double = 5.42
    private(set) var lastUpdated: Date? = nil
    private(set) var isOffline: Bool = false

    static let shared = ExchangeRateService()
    private let cacheKey = "exchangeRate_USDBRL"
    private let cacheDate = "exchangeRate_lastUpdated"
    private let cacheTTL: TimeInterval = 3600 // 1 hour

    private init() { loadCached() }

    func refresh() async {
        // Check cache freshness
        if let last = lastUpdated, Date().timeIntervalSince(last) < cacheTTL { return }

        let url = URL(string: "https://economia.awesomeapi.com.br/json/last/USD-BRL")!
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let usdbrl = json["USDBRL"] as? [String: Any],
               let bidStr = usdbrl["bid"] as? String,
               let rate = Double(bidStr) {
                usdToBRL = rate
                lastUpdated = Date()
                isOffline = false
                UserDefaults.standard.set(rate, forKey: cacheKey)
                UserDefaults.standard.set(Date(), forKey: cacheDate)
            }
        } catch {
            isOffline = true
        }
    }

    var lastUpdatedLabel: String {
        guard let d = lastUpdated else { return String(localized: "desconhecida") }
        let f = DateFormatter()
        f.dateStyle = .short; f.timeStyle = .short
        return f.string(from: d)
    }

    private func loadCached() {
        let cached = UserDefaults.standard.double(forKey: cacheKey)
        if cached > 0 { usdToBRL = cached }
        lastUpdated = UserDefaults.standard.object(forKey: cacheDate) as? Date
    }

    func convert(usd: Double, iofPct: Double = 0) -> Double {
        usd * usdToBRL * (1 + iofPct / 100)
    }
}
