import SwiftUI

struct StepWelcome: View {
    var body: some View {
        VStack(spacing: 0) {
            // Hero icon
            ZStack {
                RoundedRectangle(cornerRadius: 28)
                    .fill(LinearGradient(colors: [.mtPrimary, .mtViolet], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 96, height: 96)
                    .shadow(color: Color.mtPrimary.opacity(0.35), radius: 20, y: 10)
                Image(systemName: "sparkles")
                    .mtFont(48, weight: .medium)
                    .foregroundStyle(.white)
            }
            .padding(.top, 32)
            .padding(.bottom, 8)

            StepHeader(
                title: String(localized: "Sua viagem para Orlando, sem caos."),
                subtitle: String(localized: "Vamos montar um checklist personalizado em 2 minutos — visto, câmbio, ingressos, mobilidade. Tudo no seu ritmo.")
            )

            VStack(spacing: 10) {
                FeaturePill(icon: "list.bullet", text: String(localized: "Checklist gerado pelo seu perfil real"))
                FeaturePill(icon: "dollarsign.circle", text: String(localized: "Dicas de economia com contador no topo"))
                FeaturePill(icon: "bell", text: String(localized: "Avisos no prazo certo — sem cair fora da janela"))
            }
            .padding(.horizontal, 20)
            .padding(.top, 4)
        }
    }
}

struct FeaturePill: View {
    let icon: String
    let text: String
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.mtPrimaryBg)
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .mtFont(18, weight: .medium)
                    .foregroundStyle(Color.mtPrimary)
            }
            Text(text)
                .mtFont(15.5, weight: .medium)
                .foregroundStyle(Color.mtText)
            Spacer()
        }
        .padding(14)
        .background(Color.mtCard)
        .cornerRadius(14)
        .mtCardShadow()
    }
}

struct StepHeader: View {
    var kicker: String? = nil
    let title: String
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let k = kicker {
                Text(k)
                    .mtFont(13, weight: .semibold)
                    .foregroundStyle(Color.mtPrimary)
                    .textCase(.uppercase)
                    .tracking(0.6)
            }
            Text(title)
                .mtFont(28, weight: .bold)
                .tracking(-0.6)
                .foregroundStyle(Color.mtText)
            if let sub = subtitle {
                Text(sub)
                    .mtFont(15.5)
                    .foregroundStyle(Color.mtText2)
                    .lineSpacing(3)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 22)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
