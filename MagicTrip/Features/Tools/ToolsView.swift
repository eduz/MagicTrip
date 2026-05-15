import SwiftUI

struct ToolsView: View {
    let profile: TripProfile
    @State private var segment: String = "currency"

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer().frame(height: 60)

                VStack(alignment: .leading, spacing: 2) {
                    Text(String(localized: "Ferramentas"))
                        .mtLabel()
                        .foregroundStyle(Color.mtText3)
                    Text(String(localized: "Câmbio e impostos"))
                        .mtLargeTitle()
                        .foregroundStyle(Color.mtText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 16)

                let showTax = profile.country == "BR"
                if showTax {
                    MTSegmented(
                        options: [
                            MTSegmentedOption(id: "currency", label: String(localized: "Câmbio")),
                            MTSegmentedOption(id: "tax",      label: String(localized: "Imposto")),
                        ],
                        selected: $segment
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                }

                if segment == "currency" || !showTax {
                    CurrencyConverter()
                } else {
                    ImportTaxCalculator()
                }
            }
        }
        .scrollIndicators(.hidden)
        .safeAreaInset(edge: .bottom) { Spacer().frame(height: 110) }
    }
}
