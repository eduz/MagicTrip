import SwiftUI

struct StepDocs: View {
    @Binding var draft: OnboardingDraft

    var body: some View {
        VStack(spacing: 0) {
            StepHeader(
                kicker: String(localized: "Passo 4"),
                title: String(localized: "Documentação"),
                subtitle: String(localized: "Passaporte e visto ditam o ritmo do planejamento. Vamos pular o que você já tem.")
            )
            MTGroup(header: String(localized: "Passaporte")) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(String(localized: "Tenho passaporte válido"))
                            .mtFont(16, weight: .medium)
                        Text(String(localized: "Validade ≥ 6 meses após a volta"))
                            .mtFont(12.5)
                            .foregroundStyle(Color.mtText2)
                    }
                    Spacer()
                    Toggle("", isOn: $draft.hasValidPassport)
                        .labelsHidden()
                        .tint(Color.mtSuccess)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                if draft.hasValidPassport {
                    MTDivider()
                    HStack {
                        Text(String(localized: "Validade do passaporte"))
                            .mtFont(16)
                        Spacer()
                        DatePicker("", selection: $draft.passportExpiry, displayedComponents: .date)
                            .labelsHidden()
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 4)
                }
            }
            MTGroup(
                header: String(localized: "Visto americano"),
                footer: String(localized: "O visto B1/B2 leva em média 60–120 dias entre solicitação e entrevista.")
            ) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(String(localized: "Já tenho visto B1/B2"))
                            .mtFont(16, weight: .medium)
                        Text(String(localized: "Pulamos a tarefa de solicitação"))
                            .mtFont(12.5)
                            .foregroundStyle(Color.mtText2)
                    }
                    Spacer()
                    Toggle("", isOn: $draft.hasVisa)
                        .labelsHidden()
                        .tint(Color.mtSuccess)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
            }
            MTGroup(header: String(localized: "Sua experiência")) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(String(localized: "É a primeira viagem a Orlando"))
                            .mtFont(16, weight: .medium)
                        Text(String(localized: "Aumenta o nível de detalhe das dicas"))
                            .mtFont(12.5)
                            .foregroundStyle(Color.mtText2)
                    }
                    Spacer()
                    Toggle("", isOn: $draft.isFirstTrip)
                        .labelsHidden()
                        .tint(Color.mtSuccess)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
            }
        }
    }
}
