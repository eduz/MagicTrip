import SwiftUI
import SwiftData

struct RootTabView: View {
    @Query private var profiles: [TripProfile]
    @Environment(\.modelContext) private var modelContext

    @State private var selectedTab: Tab = .checklist
    @State private var showOnboarding = false
    @State private var selectedTask: ResolvedTask? = nil
    @State private var showSavings = false

    @State private var vm = ChecklistViewModel()

    private var profile: TripProfile? { profiles.first }

    enum Tab { case checklist, calendar, tools, profile }

    var body: some View {
        Group {
            if let profile {
                ZStack(alignment: .bottom) {
                    Color.mtBg.ignoresSafeArea()
                    tabContent(profile: profile)
                    tabBar(profile: profile)
                }
                .ignoresSafeArea(edges: .bottom)
                .sheet(item: $selectedTask) { task in
                    TaskDetailSheet(
                        task: task,
                        profile: profile,
                        vm: vm,
                        onClose: { selectedTask = nil }
                    )
                    .presentationDetents([.fraction(0.93)])
                    .presentationDragIndicator(.visible)
                }
                .sheet(isPresented: $showSavings) {
                    SavingsDetailSheet(
                        profile: profile,
                        vm: vm,
                        onClose: { showSavings = false }
                    )
                    .presentationDetents([.fraction(0.93)])
                    .presentationDragIndicator(.visible)
                }
            } else {
                Color.mtBg.ignoresSafeArea()
                    .onAppear { showOnboarding = true }
            }
        }
        .sheet(isPresented: $showOnboarding) {
            OnboardingFlow(
                onFinish: { newProfile in
                    modelContext.insert(newProfile)
                    vm.loadResponses(from: newProfile)
                    vm.evaluate(profile: newProfile)
                    showOnboarding = false
                },
                onCancel: { showOnboarding = true }
            )
        }
        .onChange(of: profiles.first?.id) {
            if let p = profiles.first {
                vm.loadResponses(from: p)
                vm.evaluate(profile: p)
            }
        }
        .task {
            if let p = profiles.first {
                vm.loadResponses(from: p)
                vm.evaluate(profile: p)
            }
        }
    }

    @ViewBuilder
    private func tabContent(profile: TripProfile) -> some View {
        switch selectedTab {
        case .checklist:
            ChecklistView(
                profile: profile,
                vm: vm,
                onOpenTask: { task in selectedTask = task },
                onOpenSavings: { showSavings = true }
            )
        case .calendar:
            CalendarView(profile: profile)
        case .tools:
            ToolsView(profile: profile)
        case .profile:
            ProfileView(profile: profile, vm: vm)
        }
    }

    @ViewBuilder
    private func tabBar(profile: TripProfile) -> some View {
        HStack(spacing: 0) {
            tabBarItem(tab: .checklist, icon: "checkmark.circle", selectedIcon: "checkmark.circle.fill", label: String(localized: "Checklist"), badge: vm.urgentCount > 0 ? "\(vm.urgentCount)" : nil)
            tabBarItem(tab: .calendar,  icon: "calendar", selectedIcon: "calendar", label: String(localized: "Calendário"), badge: profile.planningStatus == .undecided ? "🔒" : nil)
            tabBarItem(tab: .tools,     icon: "dollarsign.circle", selectedIcon: "dollarsign.circle.fill", label: String(localized: "Ferramentas"))
            tabBarItem(tab: .profile,   icon: "person.circle", selectedIcon: "person.circle.fill", label: String(localized: "Perfil"))
        }
        .padding(.horizontal, 8)
        .padding(.top, 10)
        .padding(.bottom, 28)
        .background(.ultraThinMaterial)
        .overlay(alignment: .top) {
            Divider()
        }
    }

    @ViewBuilder
    private func tabBarItem(tab: Tab, icon: String, selectedIcon: String, label: String, badge: String? = nil) -> some View {
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 4) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: selectedTab == tab ? selectedIcon : icon)
                        .mtFont(22)
                        .foregroundStyle(selectedTab == tab ? Color.mtPrimary : Color.mtText3)
                    if let badge {
                        Text(badge)
                            .mtFont(10, weight: .bold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color.mtDanger)
                            .clipShape(Capsule())
                            .offset(x: 8, y: -6)
                    }
                }
                Text(label)
                    .mtFont(10)
                    .foregroundStyle(selectedTab == tab ? Color.mtPrimary : Color.mtText3)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}
