import SwiftUI
import SwiftData

struct TaskDetailSheet: View {
    let task: ResolvedTask
    let profile: TripProfile
    var vm: ChecklistViewModel
    var onClose: () -> Void

    @Environment(\.modelContext) private var modelContext
    @State private var selectedOptionID: String? = nil
    @State private var multiSelectedIDs: Set<String> = []

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Title (wraps naturally on multiple lines)
                    Text(task.title)
                        .mtFont(24, weight: .bold)
                        .tracking(-0.4)
                        .foregroundStyle(Color.mtText)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                    // Why is this here banner
                    let explanations = ChecklistRuleEngine.explainRequires(
                        task.template,
                        responses: vm.responses,
                        templates: CatalogLoader.shared.tasks
                    )
                    if !explanations.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(String(localized: "Por que esta tarefa apareceu?"))
                                .mtFont(13, weight: .semibold)
                                .foregroundStyle(Color.mtPrimary)
                            ForEach(explanations, id: \.parentID) { exp in
                                Text("→ \(exp.parentTitle): **\(exp.answerLabel)**")
                                    .mtFont(14)
                                    .foregroundStyle(Color.mtText2)
                            }
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.mtPrimaryBg)
                        .cornerRadius(12)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                    }

                    // Description
                    Text(task.description)
                        .mtFont(16)
                        .foregroundStyle(Color.mtText2)
                        .lineSpacing(4)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)

                    // Deadline info
                    if let deadline = task.effectiveDeadline {
                        let days = max(0, deadline.daysFromNow)
                        HStack(spacing: 8) {
                            Image(systemName: "clock.fill")
                                .foregroundStyle(days <= 7 ? Color.mtDanger : Color.mtAmber)
                            Text(days == 0
                                 ? String(localized: "Prazo: hoje!")
                                 : "\(String(localized: "Prazo: em")) \(days) \(String(localized: "dias"))")
                                .mtFont(14.5, weight: .medium)
                                .foregroundStyle(days <= 7 ? Color.mtDanger : Color.mtText2)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                    }

                    // Decision section
                    if let dec = task.decision {
                        SectionHeader(title: dec.question)
                        VStack(spacing: 8) {
                            ForEach(dec.options) { option in
                                DecisionOptionCard(
                                    option: option,
                                    isSelected: selectedOptionID == option.id,
                                    onSelect: {
                                        selectedOptionID = option.id
                                        vm.setAndPersistResponse(
                                            taskID: task.id,
                                            optionIDs: [option.id],
                                            profile: profile,
                                            context: modelContext
                                        )
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                    }

                    // Multi-select grouped section
                    if let groups = task.groups, task.taskType == .multiSelectGrouped {
                        SectionHeader(title: String(localized: "Selecione os parques"))
                        MultiSelectGroupedView(
                            groups: groups,
                            selectedIDs: multiSelectedIDs,
                            onToggle: { id in
                                if multiSelectedIDs.contains(id) { multiSelectedIDs.remove(id) }
                                else { multiSelectedIDs.insert(id) }
                                vm.setAndPersistResponse(
                                    taskID: task.id,
                                    optionIDs: Array(multiSelectedIDs),
                                    profile: profile,
                                    context: modelContext
                                )
                            }
                        )
                        .padding(.horizontal, 16)
                    }

                    // Seasonality comparator (for planning/date task)
                    if task.id == "PL-01" || task.id == "PL-02" {
                        SectionHeader(title: String(localized: "Comparar épocas"))
                        SeasonalityComparator(data: CatalogLoader.shared.seasonality)
                    }

                    // Tips section
                    let applicableTips = task.tips.filter {
                        guard let cond = $0.applicableConditions else { return true }
                        return ApplicableConditionsMatcher.isTipApplicable(conditions: cond, profile: profile)
                    }
                    if !applicableTips.isEmpty {
                        SectionHeader(title: String(localized: "Dicas"))
                        VStack(spacing: 10) {
                            ForEach(applicableTips) { tip in
                                TipCard(tip: tip.displayText)
                            }
                        }
                        .padding(.horizontal, 16)
                    }

                    // Savings tips section
                    let applicableSavings = task.savings.filter {
                        guard let cond = $0.applicableConditions else { return true }
                        return ApplicableConditionsMatcher.isTipApplicable(conditions: cond, profile: profile)
                    }
                    if !applicableSavings.isEmpty {
                        SectionHeader(title: String(localized: "Dicas de economia"))
                        VStack(spacing: 8) {
                            ForEach(applicableSavings) { tip in
                                let totalSaved = SavingsCalculator.apply(tip: tip, travelers: profile.totalTravelers)
                                SavingsTipCard(
                                    tip: tip,
                                    isApplied: vm.isTipApplied(taskID: task.id, tipID: tip.id, profile: profile),
                                    totalSaved: totalSaved,
                                    onToggle: {
                                        vm.toggleSavingsTip(
                                            taskID: task.id,
                                            tip: tip,
                                            travelers: profile.totalTravelers,
                                            profile: profile,
                                            context: modelContext
                                        )
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                    }

                    // More info link
                    if let urlStr = task.moreInfoUrl, let label = task.moreInfoLabel {
                        Button {
                            LinkOpener.open(urlString: urlStr)
                        } label: {
                            HStack {
                                Image(systemName: "link")
                                Text(label)
                                    .mtFont(14.5)
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .mtFont(12)
                            }
                            .foregroundStyle(Color.mtPrimary)
                            .padding(14)
                            .background(Color.mtPrimaryBg)
                            .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                    }

                    Spacer().frame(height: 120)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .mtFont(15, weight: .semibold)
                            .foregroundStyle(Color.mtText2)
                            .frame(width: 32, height: 32)
                            .background(Color.mtBg2)
                            .clipShape(Circle())
                    }
                    .accessibilityLabel(String(localized: "Fechar"))
                }
            }
            .safeAreaInset(edge: .bottom) {
                actionsFooter
            }
        }
        .onAppear {
            let ids = vm.responses[task.id] ?? []
            if task.taskType == .decision {
                selectedOptionID = ids.first
            } else {
                multiSelectedIDs = Set(ids)
            }
        }
    }

    @ViewBuilder
    private var actionsFooter: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 12) {
                if task.isCompleted || task.isSkipped {
                    MTButton(label: String(localized: "Reabrir"), variant: .ghost) {
                        vm.setStatus(taskID: task.id, status: .pending)
                        onClose()
                    }
                } else {
                    MTButton(label: String(localized: "Pular"), variant: .ghost) {
                        vm.setStatus(taskID: task.id, status: .skipped)
                        onClose()
                    }
                    MTButton(
                        label: task.taskType == .decision || task.taskType == .multiSelectGrouped
                            ? String(localized: "Salvar resposta")
                            : String(localized: "Marcar como feita"),
                        variant: .primary
                    ) {
                        vm.setStatus(taskID: task.id, status: .completed)
                        onClose()
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(.ultraThinMaterial)
        }
    }
}

private struct SectionHeader: View {
    let title: String
    var body: some View {
        Text(title)
            .mtFont(13.5, weight: .bold)
            .foregroundStyle(Color.mtText2)
            .textCase(.uppercase)
            .tracking(0.5)
            .padding(.horizontal, 16)
            .padding(.top, 24)
            .padding(.bottom, 8)
    }
}
