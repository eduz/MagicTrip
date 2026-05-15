import SwiftUI

struct ImportTaxCalculator: View {
    @State private var totalUSDText: String = ""
    @State private var transport: String = "air"

    private let airQuota: Double   = 1000
    private let groundQuota: Double = 500
    private let taxRate: Double = 50   // % on amount above quota (Receita Federal — bagagem acompanhada)

    private var quota: Double { transport == "air" ? airQuota : groundQuota }
    private var totalUSD: Double { Double(totalUSDText.replacingOccurrences(of: ",", with: ".")) ?? 0 }
    private var taxableUSD: Double { max(0, totalUSD - quota) }
    private var taxUSD: Double { taxableUSD * taxRate / 100 }
    private var rate: Double { ExchangeRateService.shared.usdToBRL }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Total input
                MTGroup(header: String(localized: "Total de compras (US$)")) {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text("US$")
                            .mtFont(28, weight: .bold)
                            .foregroundStyle(Color.mtText3)
                        TextField("0", text: $totalUSDText)
                            .keyboardType(.decimalPad)
                            .mtFont(40, weight: .bold).monospacedDigit()
                            .tracking(-1)
                            .foregroundStyle(Color.mtText)
                            .mtKeyboardDoneToolbar()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }

                // Transport mode
                VStack(alignment: .leading, spacing: 8) {
                    Text(String(localized: "Meio de entrada no Brasil"))
                        .mtFont(13)
                        .foregroundStyle(Color.mtText2)
                    MTSegmented(
                        options: [
                            MTSegmentedOption(id: "air", label: "✈ Aéreo (US$ 1.000)"),
                            MTSegmentedOption(id: "ground", label: "🚌 Terrestre (US$ 500)"),
                        ],
                        selected: $transport
                    )
                }

                // Result
                if totalUSD > 0 {
                    VStack(spacing: 0) {
                        resultRow(
                            label: String(localized: "Cota de isenção"),
                            value: quota.formatUSD(),
                            highlight: false
                        )
                        MTDivider()
                        resultRow(
                            label: String(localized: "Valor tributável"),
                            value: taxableUSD.formatUSD(),
                            highlight: false
                        )
                        MTDivider()
                        resultRow(
                            label: String(localized: "Imposto estimado (50%)"),
                            value: taxUSD.formatUSD(),
                            highlight: true
                        )
                        if taxUSD > 0 {
                            MTDivider()
                            resultRow(
                                label: String(localized: "≈ em reais"),
                                value: taxUSD.formatBRL(rate: rate),
                                highlight: false
                            )
                        }
                    }
                    .background(Color.mtCard)
                    .cornerRadius(.mtCardLg)
                    .mtCardShadow()

                    if taxableUSD == 0 {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color.mtSuccess)
                            Text(String(localized: "Dentro da cota de isenção. Sem imposto."))
                                .mtFont(13.5)
                                .foregroundStyle(Color.mtSuccess)
                        }
                        .padding(14)
                        .background(Color.mtSuccess.opacity(0.1))
                        .cornerRadius(12)
                    }
                }

                // Info
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "info.circle")
                        .foregroundStyle(Color.mtViolet)
                    Text(String(localized: "Alíquota de 50% sobre o valor excedente da cota. Verifique as regras atuais da Receita Federal antes de viajar."))
                        .mtFont(13)
                        .foregroundStyle(Color.mtViolet)
                        .lineSpacing(3)
                }
                .padding(14)
                .background(Color.mtVioletBg)
                .cornerRadius(12)
            }
            .padding(16)
        }
    }

    @ViewBuilder
    private func resultRow(label: String, value: String, highlight: Bool) -> some View {
        HStack {
            Text(label)
                .mtFont(15)
                .foregroundStyle(highlight ? Color.mtDanger : Color.mtText)
            Spacer()
            Text(value)
                .mtFont(15, weight: .semibold).monospacedDigit()
                .foregroundStyle(highlight ? Color.mtDanger : Color.mtText)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }
}
