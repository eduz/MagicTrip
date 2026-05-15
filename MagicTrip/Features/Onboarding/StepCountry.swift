import SwiftUI

struct StepCountry: View {
    @Binding var draft: OnboardingDraft
    private let countries = CatalogLoader.shared.countries

    var body: some View {
        VStack(spacing: 0) {
            StepHeader(
                kicker: String(localized: "Passo 1"),
                title: String(localized: "De onde você vai viajar?"),
                subtitle: String(localized: "Ajustamos as tarefas para o contexto regulatório do seu país — visto, IOF, declaração de bagagem.")
            )
            LazyVStack(spacing: 8) {
                ForEach(countries) { country in
                    CountryButton(
                        country: country,
                        isSelected: draft.country == country.code,
                        action: { draft.country = country.code }
                    )
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

struct CountryButton: View {
    let country: CountryEntry
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Text(country.flag)
                    .mtFont(26)
                Text(country.name)
                    .mtFont(16, weight: .medium)
                    .foregroundStyle(Color.mtText)
                Spacer()
                if country.pinned == true {
                    Text(String(localized: "Padrão"))
                        .mtFont(11, weight: .semibold)
                        .foregroundStyle(Color.mtText2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.mtBg2)
                        .cornerRadius(999)
                        .textCase(.uppercase)
                }
                if isSelected {
                    Image(systemName: "checkmark")
                        .mtFont(15, weight: .semibold)
                        .foregroundStyle(Color.mtPrimary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.mtCard)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.mtPrimary : Color.clear, lineWidth: 2)
            )
            .mtCardShadow()
        }
        .buttonStyle(.plain)
    }
}
