import SwiftUI

struct ChecklistView: View {
    let profile: TripProfile
    @Bindable var vm: ChecklistViewModel
    var onOpenTask: (ResolvedTask) -> Void
    var onOpenSavings: () -> Void

    @State private var collapsedCategories: Set<TaskCategory> = []

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer().frame(height: 60)

                // Header
                VStack(alignment: .leading, spacing: 2) {
                    Text(String(localized: "Sua viagem"))
                        .mtLabel()
                        .foregroundStyle(Color.mtText3)
                    Text(String(localized: "Pra Orlando"))
                        .mtLargeTitle()
                        .foregroundStyle(Color.mtText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 8)

                // Hero: progress + savings
                VStack(spacing: 10) {
                    // Progress card
                    HStack(spacing: 14) {
                        MTProgressRing(pct: vm.progressPct, size: 68, strokeWidth: 7, label: "\(Int(vm.progressPct * 100))%")
                        VStack(alignment: .leading, spacing: 2) {
                            Text(profile.planningStatus == .undecided ? String(localized: "Em modo planejamento") : String(localized: "Progresso geral"))
                                .mtFont(13)
                                .foregroundStyle(Color.mtText2)
                            Text("\(vm.completedCount) \(String(localized: "de")) \(vm.completedCount + vm.activeCount) \(String(localized: "tarefas"))")
                                .mtFont(17, weight: .semibold)
                                .foregroundStyle(Color.mtText)
                            if let dep = profile.departureDate {
                                Text("\(max(0, dep.daysFromNow)) \(String(localized: "dias até a viagem"))")
                                    .mtFont(13)
                                    .foregroundStyle(Color.mtText2)
                            }
                        }
                        Spacer()
                    }
                    .padding(16)
                    .background(Color.mtCard)
                    .cornerRadius(.mtCardLg)
                    .mtCardShadow()

                    // Savings tile
                    Button(action: onOpenSavings) {
                        GradientCard {
                            HStack(spacing: 14) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.18))
                                        .frame(width: 44, height: 44)
                                    Image(systemName: "sparkles")
                                        .mtFont(24, weight: .medium)
                                        .foregroundStyle(.white)
                                }
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(String(localized: "ECONOMIA ESTIMADA"))
                                        .mtFont(12.5, weight: .medium)
                                        .foregroundStyle(.white.opacity(0.85))
                                        .tracking(0.2)
                                    Text("≈ \(vm.totalSavedUSD.formatUSD())")
                                        .mtFont(26, weight: .bold).monospacedDigit()
                                        .tracking(-0.5)
                                        .foregroundStyle(.white)
                                    Text("≈ \(vm.totalSavedUSD.formatBRL(rate: ExchangeRateService.shared.usdToBRL))")
                                        .mtFont(12.5)
                                        .foregroundStyle(.white.opacity(0.85))
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.white.opacity(0.8))
                            }
                            .padding(16)
                        }
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 6)

                // Category sections
                ForEach(vm.groupedTasks, id: \.0) { category, tasks in
                    CategorySection(
                        category: category,
                        tasks: tasks,
                        newTaskIDs: vm.newTaskIDs,
                        isCollapsed: collapsedCategories.contains(category),
                        onToggleCollapse: {
                            if collapsedCategories.contains(category) {
                                collapsedCategories.remove(category)
                            } else {
                                collapsedCategories.insert(category)
                            }
                        },
                        onOpenTask: onOpenTask
                    )
                }
            }
        }
        .scrollIndicators(.hidden)
        .safeAreaInset(edge: .bottom) { Spacer().frame(height: 110) }
    }
}
