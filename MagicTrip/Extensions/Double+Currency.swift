import Foundation

extension Double {
    func formatUSD() -> String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = "USD"
        f.locale = Locale(identifier: "en_US")
        return f.string(from: NSNumber(value: self)) ?? "US$ \(self)"
    }

    func formatBRL(rate: Double = 5.42) -> String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = "BRL"
        f.locale = Locale(identifier: "pt_BR")
        return f.string(from: NSNumber(value: self * rate)) ?? "R$ \(self * rate)"
    }
}
