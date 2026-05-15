import SwiftUI
import SwiftData

struct OnboardingFlow: View {
    @Environment(\.modelContext) private var modelContext
    var profile: TripProfile?               // non-nil when editing existing profile
    var onFinish: (TripProfile) -> Void
    var onCancel: () -> Void

    // Mutable working copy
    @State private var draft: OnboardingDraft

    init(profile: TripProfile? = nil, onFinish: @escaping (TripProfile) -> Void, onCancel: @escaping () -> Void) {
        self.profile = profile
        self.onFinish = onFinish
        self.onCancel = onCancel
        _draft = State(initialValue: OnboardingDraft(from: profile))
    }

    @State private var step = 0
    private var steps: [OnboardingStep] {
        var s: [OnboardingStep] = [.welcome, .country, .planning, .family]
        if draft.country == "BR" { s.append(.docs) }
        s.append(.budget)
        return s
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.mtBg.ignoresSafeArea()
            VStack(spacing: 0) {
                // Progress bar + nav
                HStack(spacing: 12) {
                    if step > 0 {
                        Button(action: { withAnimation { step -= 1 } }) {
                            Image(systemName: "chevron.left")
                                .mtFont(18, weight: .medium)
                                .foregroundStyle(Color.mtText)
                        }
                    } else {
                        Button(String(localized: "Cancelar"), action: onCancel)
                            .foregroundStyle(Color.mtText2)
                            .mtFont(15)
                    }
                    HStack(spacing: 4) {
                        ForEach(0..<steps.count, id: \.self) { i in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(i <= step ? Color.mtPrimary : Color.mtBg2)
                                .frame(maxWidth: .infinity)
                                .frame(height: 3)
                                .animation(.easeInOut(duration: 0.3), value: step)
                        }
                    }
                    Spacer().frame(width: 30)
                }
                .padding(.horizontal, 20)
                .padding(.top, 54)
                .padding(.bottom, 16)

                // Step content
                ScrollView { stepView }
                    .scrollIndicators(.hidden)
                    .animation(.easeInOut(duration: 0.25), value: step)
            }

            // Continue button
            VStack(spacing: 0) {
                MTButton(
                    label: step == steps.count - 1
                        ? String(localized: "Gerar meu checklist")
                        : String(localized: "Continuar"),
                    variant: .coral,
                    action: advance
                )
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 38)
                .background(.ultraThinMaterial)
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }

    @ViewBuilder
    private var stepView: some View {
        let current = steps[safe: step] ?? .welcome
        switch current {
        case .welcome:  StepWelcome()
        case .country:  StepCountry(draft: $draft)
        case .planning: StepPlanning(draft: $draft)
        case .family:   StepFamily(draft: $draft)
        case .docs:     StepDocs(draft: $draft)
        case .budget:   StepBudget(draft: $draft)
        }
    }

    private func advance() {
        if step < steps.count - 1 {
            withAnimation { step += 1 }
        } else {
            commit()
        }
    }

    private func commit() {
        let p = profile ?? TripProfile()
        draft.apply(to: p)
        if profile == nil { modelContext.insert(p) }
        p.updatedAt = Date()
        onFinish(p)
    }
}

enum OnboardingStep { case welcome, country, planning, family, docs, budget }

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Mutable draft (does not touch SwiftData until commit)
struct OnboardingDraft {
    var country: String = "BR"
    var planningStatus: PlanningStatus = .dateConfirmed
    var departureDate: Date = Calendar.current.date(byAdding: .month, value: 3, to: .now)!
    var returnDate: Date = Calendar.current.date(byAdding: .month, value: 3, to: Calendar.current.date(byAdding: .day, value: 10, to: .now)!)!
    var tentativeYear: Int = Calendar.current.component(.year, from: .now)
    var tentativeMonthStart: Int = 6
    var tentativeMonthEnd: Int = 8
    var tentativeDurationDays: Int = 10
    var adults: Int = 2
    var seniors: Int = 0
    var reducedMobility: Bool = false
    var children: [ChildDraft] = []
    var hasVisa: Bool = false
    var hasValidPassport: Bool = true
    var passportExpiry: Date = Calendar.current.date(byAdding: .year, value: 4, to: .now)!
    var isFirstTrip: Bool = true
    var budgetUSD: Double? = nil

    struct ChildDraft: Identifiable {
        var id = UUID()
        var age: Int = 5
    }

    init(from profile: TripProfile? = nil) {
        guard let p = profile else { return }
        country = p.country
        planningStatus = p.planningStatus
        departureDate = p.departureDate ?? departureDate
        returnDate = p.returnDate ?? returnDate
        tentativeYear = p.tentativeYear ?? tentativeYear
        tentativeMonthStart = p.tentativeMonthStart ?? tentativeMonthStart
        tentativeMonthEnd = p.tentativeMonthEnd ?? tentativeMonthEnd
        tentativeDurationDays = p.tentativeDurationDays
        adults = p.adults
        seniors = p.seniors
        reducedMobility = p.reducedMobility
        children = p.children.map { ChildDraft(age: $0.age) }
        hasVisa = p.hasVisa
        hasValidPassport = p.hasValidPassport
        passportExpiry = p.passportExpiry ?? passportExpiry
        isFirstTrip = p.isFirstTrip
        budgetUSD = p.budgetUSD
    }

    func apply(to profile: TripProfile) {
        profile.country = country
        profile.planningStatus = planningStatus
        profile.departureDate = planningStatus == .dateConfirmed ? departureDate : nil
        profile.returnDate = planningStatus == .dateConfirmed ? returnDate : nil
        profile.tentativeYear = planningStatus == .undecided ? tentativeYear : nil
        profile.tentativeMonthStart = planningStatus == .undecided ? tentativeMonthStart : nil
        profile.tentativeMonthEnd = planningStatus == .undecided ? tentativeMonthEnd : nil
        profile.tentativeDurationDays = tentativeDurationDays
        profile.adults = adults
        profile.seniors = seniors
        profile.reducedMobility = reducedMobility
        profile.hasVisa = hasVisa
        profile.hasValidPassport = hasValidPassport
        profile.passportExpiry = hasValidPassport ? passportExpiry : nil
        profile.isFirstTrip = isFirstTrip
        profile.budgetUSD = budgetUSD

        // Sync children
        profile.children.removeAll()
        profile.children = children.map { d in
            let c = Child(age: d.age)
            c.profile = profile
            return c
        }
    }
}
