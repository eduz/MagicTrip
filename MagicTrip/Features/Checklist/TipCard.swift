import SwiftUI

struct TipCard: View {
    let tip: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "sparkles")
                .mtFont(15)
                .foregroundStyle(Color.mtPrimary)
                .padding(.top, 2)
            Text(tip)
                .mtFont(15.5)
                .foregroundStyle(Color.mtText2)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
    }
}

struct SavingsTipCard: View {
    let tip: SavingsTipTemplate
    let isApplied: Bool
    let totalSaved: Double
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    Circle()
                        .strokeBorder(isApplied ? Color.clear : Color.mtText3, lineWidth: 1.8)
                        .background(
                            Circle().fill(isApplied ? Color.mtSuccess : Color.clear)
                        )
                        .frame(width: 28, height: 28)
                    if isApplied {
                        Image(systemName: "checkmark")
                            .mtFont(14, weight: .bold)
                            .foregroundStyle(.white)
                    }
                }
                .padding(.top, 2)
                VStack(alignment: .leading, spacing: 6) {
                    Text(tip.description)
                        .mtFont(16)
                        .foregroundStyle(Color.mtText)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                    HStack(spacing: 8) {
                        if tip.savingsScope == .perPerson {
                            Label(String(localized: "por pessoa"), systemImage: "person.fill")
                                .mtFont(13)
                                .foregroundStyle(Color.mtText3)
                        } else {
                            Label(String(localized: "compartilhado"), systemImage: "person.2.fill")
                                .mtFont(13)
                                .foregroundStyle(Color.mtText3)
                        }
                        Text(totalSaved.formatUSD())
                            .mtFont(13.5, weight: .semibold).monospacedDigit()
                            .foregroundStyle(Color.mtViolet)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.mtVioletBg)
                            .cornerRadius(7)
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(14)
            .background(isApplied ? Color.mtSuccess.opacity(0.06) : Color.mtCard)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isApplied ? Color.mtSuccess.opacity(0.3) : Color.mtCardLine, lineWidth: 1)
            )
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tip.description)
        .accessibilityHint(isApplied
            ? String(localized: "Aplicada. Toque para desfazer.")
            : String(localized: "Toque para marcar como aplicada."))
        .accessibilityAddTraits(isApplied ? [.isButton, .isSelected] : .isButton)
        .animation(.easeInOut(duration: 0.15), value: isApplied)
    }
}
