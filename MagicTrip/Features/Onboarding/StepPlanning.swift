import SwiftUI

struct StepPlanning: View {
    @Binding var draft: OnboardingDraft
    @State private var segmented: String = "dateConfirmed"

    var body: some View {
        VStack(spacing: 0) {
            StepHeader(
                kicker: String(localized: "Passo 2"),
                title: String(localized: "Você já decidiu quando vai?"),
                subtitle: String(localized: "Se ainda não, vamos te ajudar a comparar épocas antes de fechar a data.")
            )
            VStack(spacing: 18) {
                MTSegmented(
                    options: [
                        MTSegmentedOption(id: "dateConfirmed", label: String(localized: "Já tenho data")),
                        MTSegmentedOption(id: "undecided", label: String(localized: "Ainda decidindo")),
                    ],
                    selected: $segmented
                )
                .onChange(of: segmented) {
                    draft.planningStatus = segmented == "dateConfirmed" ? .dateConfirmed : .undecided
                }

                if segmented == "dateConfirmed" {
                    MTGroup {
                        HStack {
                            Text(String(localized: "Data de ida"))
                                .mtFont(16)
                            Spacer()
                            FormDatePicker(selection: $draft.departureDate)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 2)
                        MTDivider()
                        HStack {
                            Text(String(localized: "Data de volta"))
                                .mtFont(16)
                            Spacer()
                            FormDatePicker(selection: $draft.returnDate, in: draft.departureDate...)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 2)
                    }

                    // Duration hint
                    let days = Calendar.current.dateComponents([.day], from: draft.departureDate, to: draft.returnDate).day ?? 0
                    if days >= 0 {
                        HStack(spacing: 8) {
                            Image(systemName: "sparkles").foregroundStyle(Color.mtPrimary)
                            Text("\(days) \(String(localized: "dias")) · \(String(localized: "faltam")) \(max(0, draft.departureDate.daysFromNow)) \(String(localized: "dias"))")
                                .mtFont(14, weight: .medium)
                                .foregroundStyle(Color.mtPrimaryDk)
                        }
                        .padding(14)
                        .background(Color.mtPrimaryBg)
                        .cornerRadius(12)
                    }
                } else {
                    MTGroup(header: String(localized: "Janela tentativa"), footer: String(localized: "Tarefas com prazo fixo ficarão travadas até você definir a data.")) {
                        HStack {
                            Text(String(localized: "Ano"))
                                .mtFont(16)
                            Spacer()
                            Picker("", selection: $draft.tentativeYear) {
                                ForEach(Calendar.current.component(.year, from: .now)...(Calendar.current.component(.year, from: .now) + 3), id: \.self) { y in
                                    Text(verbatim: "\(y)").tag(y)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 4)
                    }
                    MTGroup(header: String(localized: "Duração pretendida")) {
                        HStack {
                            Text("\(draft.tentativeDurationDays) \(String(localized: "dias"))")
                                .mtFont(16, weight: .medium)
                            Spacer()
                            MTStepper(value: $draft.tentativeDurationDays, min: 3, max: 21)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .onAppear {
            segmented = draft.planningStatus == .dateConfirmed ? "dateConfirmed" : "undecided"
        }
    }
}
