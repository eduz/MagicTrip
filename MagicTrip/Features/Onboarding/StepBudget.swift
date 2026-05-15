import SwiftUI

struct StepBudget: View {
    @Binding var draft: OnboardingDraft
    @State private var budgetText: String = ""
    private let rate = ExchangeRateService.shared.usdToBRL

    var body: some View {
        VStack(spacing: 0) {
            StepHeader(
                kicker: String(localized: "Último passo"),
                title: String(localized: "Orçamento total (opcional)"),
                subtitle: String(localized: "Usado para calibrar dicas de economia. Fica salvo só no aparelho.")
            )
            VStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(String(localized: "Orçamento estimado"))
                        .mtFont(13)
                        .foregroundStyle(Color.mtText2)
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text("US$")
                            .mtFont(28, weight: .bold)
                            .foregroundStyle(Color.mtText3)
                        TextField("0", text: $budgetText)
                            .keyboardType(.decimalPad)
                            .mtFont(40, weight: .bold).monospacedDigit()
                            .tracking(-1)
                            .foregroundStyle(Color.mtText)
                            .mtKeyboardDoneToolbar()
                            .onChange(of: budgetText) {
                                draft.budgetUSD = Double(budgetText.replacingOccurrences(of: ",", with: "."))
                            }
                    }
                    if let usd = draft.budgetUSD, usd > 0 {
                        Text("≈ \(usd.formatBRL(rate: rate))")
                            .mtFont(14)
                            .foregroundStyle(Color.mtText2)
                    }
                }
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.mtCard)
                .cornerRadius(16)
                .mtCardShadow()

                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "sparkles")
                        .mtFont(16)
                        .foregroundStyle(Color.mtViolet)
                    Text(String(localized: "Você poderá pular dicas que não fizerem sentido. O contador soma só as que você marcar como aplicadas."))
                        .mtFont(13.5)
                        .foregroundStyle(Color.mtViolet)
                        .lineSpacing(3)
                }
                .padding(14)
                .background(Color.mtVioletBg)
                .cornerRadius(12)
            }
            .padding(.horizontal, 16)
        }
        .onAppear {
            if let b = draft.budgetUSD { budgetText = String(Int(b)) }
        }
    }
}
