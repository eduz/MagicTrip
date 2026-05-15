import SwiftUI

struct SavingsDetailSheet: View {
    let profile: TripProfile
    var vm: ChecklistViewModel
    var onClose: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Gradient hero
                    GradientCard {
                        VStack(spacing: 6) {
                            Image(systemName: "sparkles")
                                .mtFont(36)
                                .foregroundStyle(.white)
                            Text(String(localized: "Economia estimada"))
                                .mtFont(14)
                                .foregroundStyle(.white.opacity(0.85))
                            Text("≈ \(vm.totalSavedUSD.formatUSD())")
                                .mtFont(40, weight: .bold).monospacedDigit()
                                .tracking(-1)
                                .foregroundStyle(.white)
                            Text("≈ \(vm.totalSavedUSD.formatBRL(rate: ExchangeRateService.shared.usdToBRL))")
                                .mtFont(15)
                                .foregroundStyle(.white.opacity(0.85))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                    if profile.appliedSavings.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "sparkles")
                                .mtFont(40)
                                .foregroundStyle(Color.mtText3)
                            Text(String(localized: "Nenhuma dica de economia aplicada ainda."))
                                .mtFont(15)
                                .foregroundStyle(Color.mtText2)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(40)
                    } else {
                        VStack(alignment: .leading, spacing: 0) {
                            Text(String(localized: "Dicas aplicadas"))
                                .mtFont(13, weight: .semibold)
                                .foregroundStyle(Color.mtText3)
                                .textCase(.uppercase)
                                .tracking(0.4)
                                .padding(.horizontal, 16)
                                .padding(.top, 24)
                                .padding(.bottom, 8)

                            VStack(spacing: 0) {
                                ForEach(Array(profile.appliedSavings.enumerated()), id: \.element.id) { idx, tip in
                                    let template = CatalogLoader.shared.template(id: tip.taskID)
                                    let tipDesc = template?.savings.first(where: { $0.id == tip.tipID })?.description
                                    HStack(alignment: .top, spacing: 12) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(template?.title ?? tip.taskID)
                                                .mtFont(15, weight: .semibold)
                                                .foregroundStyle(Color.mtText)
                                                .fixedSize(horizontal: false, vertical: true)
                                            if let tipDesc {
                                                Text(tipDesc)
                                                    .mtFont(13)
                                                    .foregroundStyle(Color.mtText2)
                                                    .lineSpacing(2)
                                                    .fixedSize(horizontal: false, vertical: true)
                                            }
                                            Text(tip.totalSavedUSD.formatUSD())
                                                .mtFont(15, weight: .semibold).monospacedDigit()
                                                .foregroundStyle(Color.mtViolet)
                                        }
                                        Spacer(minLength: 0)
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(Color.mtSuccess)
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 12)
                                    if idx < profile.appliedSavings.count - 1 { MTDivider() }
                                }
                            }
                            .background(Color.mtCard)
                            .cornerRadius(.mtCardLg)
                            .mtCardShadow()
                            .padding(.horizontal, 16)
                        }
                    }

                    // Recalc notice if group size changed
                    HStack(spacing: 10) {
                        Image(systemName: "info.circle")
                            .foregroundStyle(Color.mtAmber)
                        Text(String(localized: "O valor é estimado. Pode variar conforme promoções e disponibilidade."))
                            .mtFont(13)
                            .foregroundStyle(Color.mtAmberText)
                            .lineSpacing(3)
                    }
                    .padding(14)
                    .background(Color.mtAmberBg)
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                    .padding(.top, 20)

                    Spacer().frame(height: 40)
                }
            }
            .navigationTitle(String(localized: "Economia estimada"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(String(localized: "Fechar"), action: onClose)
                        .foregroundStyle(Color.mtText2)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    ShareLink(
                        item: shareText,
                        label: { Label(String(localized: "Compartilhar"), systemImage: "square.and.arrow.up") }
                    )
                    .foregroundStyle(Color.mtPrimary)
                }
            }
        }
    }

    private var shareText: String {
        let usd = vm.totalSavedUSD.formatUSD()
        let brl = vm.totalSavedUSD.formatBRL(rate: ExchangeRateService.shared.usdToBRL)
        return String(localized: "Minha viagem para Orlando vai economizar \(usd) (\(brl)) com \(profile.appliedSavings.count) dicas do MagicTrip! 🎉")
    }
}
