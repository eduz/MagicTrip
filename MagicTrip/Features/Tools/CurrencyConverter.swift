import SwiftUI

struct CurrencyConverter: View {
    @State private var usdText: String = ""
    @State private var iofSegment: String = "card_debit"
    @State private var includeSalesTax: Bool = false

    private let iofOptions: [(id: String, label: String, rate: Double)] = [
        ("cash",       "Espécie",  0.0),
        ("card_debit", "Débito",   1.1),
        ("card_credit","Crédito",  3.5),
    ]
    private let salesTaxRate: Double = 6.5  // Orange County (Orlando) — FL state 6% + 0.5% county

    private var usdValue: Double { Double(usdText.replacingOccurrences(of: ",", with: ".")) ?? 0 }
    private var iofRate: Double { iofOptions.first(where: { $0.id == iofSegment })?.rate ?? 1.1 }

    private var rate: Double { ExchangeRateService.shared.usdToBRL }
    private var usdWithSalesTax: Double { includeSalesTax ? usdValue * (1 + salesTaxRate / 100) : usdValue }
    private var brl: Double { usdWithSalesTax * rate }
    private var brlWithIOF: Double { brl * (1 + iofRate / 100) }
    private var iofAmount: Double { brl * (iofRate / 100) }
    private var salesTaxAmountBRL: Double {
        includeSalesTax ? (usdValue * salesTaxRate / 100) * rate * (1 + iofRate / 100) : 0
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Offline banner
                if ExchangeRateService.shared.isOffline {
                    HStack(spacing: 8) {
                        Image(systemName: "wifi.slash")
                            .foregroundStyle(Color.mtAmber)
                        Text(String(localized: "Cotação offline. Última atualização: \(ExchangeRateService.shared.lastUpdatedLabel)"))
                            .mtFont(13)
                            .foregroundStyle(Color.mtAmberText)
                    }
                    .padding(12)
                    .background(Color.mtAmberBg)
                    .cornerRadius(12)
                }

                // USD input
                MTGroup {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text("US$")
                            .mtFont(28, weight: .bold)
                            .foregroundStyle(Color.mtText3)
                        TextField("0", text: $usdText)
                            .keyboardType(.decimalPad)
                            .mtFont(40, weight: .bold).monospacedDigit()
                            .tracking(-1)
                            .foregroundStyle(Color.mtText)
                            .mtKeyboardDoneToolbar()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }

                // IOF segmented
                VStack(alignment: .leading, spacing: 8) {
                    Text(String(localized: "Tipo de pagamento"))
                        .mtFont(13)
                        .foregroundStyle(Color.mtText2)
                    MTSegmented(
                        options: iofOptions.map { MTSegmentedOption(id: $0.id, label: "\($0.label) (\($0.rate)%)") },
                        selected: $iofSegment
                    )
                }

                // Sales tax toggle
                Toggle(isOn: $includeSalesTax) {
                    HStack(spacing: 10) {
                        Image(systemName: "receipt")
                            .foregroundStyle(Color.mtPrimary)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(String(localized: "Incluir sales tax de Orlando"))
                                .mtFont(15)
                                .foregroundStyle(Color.mtText)
                            Text(String(localized: "6,5% — não está no preço de etiqueta"))
                                .mtFont(12)
                                .foregroundStyle(Color.mtText3)
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color.mtCard)
                .cornerRadius(12)
                .mtCardShadow()
                .tint(Color.mtPrimary)

                // Result card
                if usdValue > 0 {
                    GradientCard {
                        VStack(spacing: 14) {
                            VStack(spacing: 4) {
                                Text(String(localized: "Custo real estimado"))
                                    .mtFont(13)
                                    .foregroundStyle(.white.opacity(0.8))
                                Text(brlWithIOF.formatBRL(rate: 1))
                                    .mtFont(36, weight: .bold).monospacedDigit()
                                    .tracking(-0.5)
                                    .foregroundStyle(.white)
                            }

                            Divider().overlay(Color.white.opacity(0.3))

                            HStack(alignment: .top) {
                                resultRow(label: String(localized: "Câmbio"), value: "1 US$ = \(rate.formatBRL(rate: 1))")
                                Spacer()
                                resultRow(label: String(localized: "IOF (\(iofRate)%)"), value: iofAmount.formatBRL(rate: 1))
                                if includeSalesTax {
                                    Spacer()
                                    resultRow(label: "\(String(localized: "Sales tax")) (\(salesTaxRate.formatted(.number.precision(.fractionLength(1))))%)", value: salesTaxAmountBRL.formatBRL(rate: 1))
                                }
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .padding(16)
        }
        .task { await ExchangeRateService.shared.refresh() }
    }

    @ViewBuilder
    private func resultRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .mtFont(11)
                .foregroundStyle(.white.opacity(0.7))
            Text(value)
                .mtFont(14, weight: .semibold).monospacedDigit()
                .foregroundStyle(.white)
        }
    }
}
