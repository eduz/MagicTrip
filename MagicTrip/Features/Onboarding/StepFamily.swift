import SwiftUI

struct StepFamily: View {
    @Binding var draft: OnboardingDraft

    var body: some View {
        VStack(spacing: 0) {
            StepHeader(
                kicker: String(localized: "Passo 3"),
                title: String(localized: "Quem vai com você?"),
                subtitle: String(localized: "A composição do grupo aciona tarefas específicas — carrinho, scooter, restrições de altura.")
            )
            MTGroup(header: String(localized: "Adultos e idosos")) {
                FamilyStepperRow(label: String(localized: "Adultos (18+)"), sub: String(localized: "Mínimo 1"), value: $draft.adults, min: 1, max: 15)
                MTDivider()
                FamilyStepperRow(label: String(localized: "Idosos (65+)"), sub: String(localized: "Aciona tarefas de mobilidade e saúde"), value: $draft.seniors, min: 0, max: 10)
                MTDivider()
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(String(localized: "Mobilidade reduzida no grupo"))
                            .mtFont(16, weight: .medium)
                        Text(String(localized: "Mesmo entre adultos abaixo de 65"))
                            .mtFont(13.5)
                            .foregroundStyle(Color.mtText2)
                    }
                    Spacer()
                    Toggle("", isOn: $draft.reducedMobility)
                        .labelsHidden()
                        .tint(Color.mtSuccess)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
            }
            MTGroup(
                header: "\(String(localized: "Crianças")) (\(draft.children.count))",
                footer: String(localized: "A idade aciona regras: carrinho < 4 anos, altura < 10 anos, ingresso infantil.")
            ) {
                ForEach(draft.children.indices, id: \.self) { i in
                    HStack(spacing: 12) {
                        Text("\(String(localized: "Criança")) \(i + 1)")
                            .mtFont(15.5)
                        Spacer()
                        Text("\(draft.children[i].age) \(String(localized: "anos"))")
                            .mtFont(13).foregroundStyle(Color.mtText2)
                        MTStepper(value: $draft.children[i].age, min: 0, max: 17)
                        Button { draft.children.remove(at: i) } label: {
                            Image(systemName: "xmark")
                                .mtFont(15)
                                .foregroundStyle(Color.mtText3)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    if i < draft.children.count - 1 { MTDivider() }
                }
                Button {
                    draft.children.append(OnboardingDraft.ChildDraft())
                } label: {
                    Text("+ \(String(localized: "Adicionar criança"))")
                        .mtFont(14, weight: .semibold)
                        .foregroundStyle(Color.mtPrimary)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
            }
        }
    }
}

struct FamilyStepperRow: View {
    let label: String
    let sub: String
    @Binding var value: Int
    var min: Int = 0
    var max: Int = 99

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(label).mtFont(16, weight: .medium)
                Text(sub).mtFont(12.5).foregroundStyle(Color.mtText2)
            }
            Spacer()
            MTStepper(value: $value, min: min, max: max)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }
}
