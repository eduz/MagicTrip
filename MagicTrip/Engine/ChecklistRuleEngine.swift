import Foundation

// MARK: - Resolved task (runtime state wrapping a template)
struct ResolvedTask: Identifiable {
    let template: TaskTemplate
    var status: TaskStatus
    var locked: Bool          // date-dependent task while profile.planningStatus == .undecided
    var effectiveDeadlineDays: Int?
    var departureDate: Date?  // copied from profile at evaluation time
    var isNew: Bool = false   // appeared due to dependency resolution this pass

    var id: String { template.id }
    var title: String { template.title }
    var category: TaskCategory { template.category }
    var taskType: TaskType { template.taskType }
    var priority: TaskPriority { template.priority }
    var description: String { template.description }
    var tips: [TipTemplate] { template.tips }
    var savings: [SavingsTipTemplate] { template.savings }
    var decision: DecisionSpec? { template.decision }
    var groups: [ParkGroup]? { template.groups }
    var moreInfoUrl: String? { template.moreInfoUrl }
    var moreInfoLabel: String? { template.moreInfoLabel }
    var conditionalDeadline: ConditionalDeadlineSpec? { template.conditionalDeadline }

    var isCompleted: Bool { status == .completed }
    var isSkipped: Bool { status == .skipped }
    var isArchived: Bool { status == .archived }
    var isLocked: Bool { locked }

    var effectiveDeadline: Date? {
        guard let days = effectiveDeadlineDays, let dep = departureDate else { return nil }
        return Calendar.current.date(byAdding: .day, value: -days, to: dep)
    }

    var estimatedSavingUSD: Double? {
        let total = savings.reduce(0.0) { $0 + $1.usdPerPerson }
        return total > 0 ? total : nil
    }
}

// MARK: - Profile flags computed from TripProfile
struct ProfileFlags {
    let country: String
    let planning: String
    let hasVisa: Bool
    let hasPassport: Bool
    let hasSeniors: Bool
    let needsMobility: Bool
    let hasYoungKid: Bool
    let hasKidUnder10: Bool
    let allAdults: Bool
    let durationLong: Bool
    let isFirstTrip: Bool

    init(_ profile: TripProfile) {
        let childAges = profile.children.map { $0.age }
        country       = profile.country
        planning      = profile.planningStatusRaw
        hasVisa       = profile.hasVisa
        hasPassport   = profile.hasValidPassport
        hasSeniors    = profile.seniors > 0
        needsMobility = profile.seniors > 0 || profile.reducedMobility
        hasYoungKid   = childAges.contains { $0 < 4 }
        hasKidUnder10 = childAges.contains { $0 < 10 }
        allAdults     = childAges.isEmpty
        durationLong  = (profile.durationDays ?? 0) > 7
        isFirstTrip   = profile.isFirstTrip
    }
}

// MARK: - Checklist rule engine

final class ChecklistRuleEngine {

    /// Idempotent evaluation: maps templates → resolved tasks visible to this profile+responses.
    /// Hidden tasks (unsatisfied requires) are excluded from the result.
    static func evaluate(
        templates: [TaskTemplate],
        profile: TripProfile,
        responses: [String: [String]],     // taskID → selected option IDs
        existingStatuses: [String: TaskStatus] = [:]
    ) -> [ResolvedTask] {
        let flags = ProfileFlags(profile)
        let isPlanning = profile.planningStatus == .undecided

        return templates.compactMap { tmpl in
            // 1. Scope filter
            if tmpl.scope == "BR" && profile.country != "BR" { return nil }

            // 2. Trigger conditions filter
            if !matchesTriggers(tmpl.triggers, flags: flags) { return nil }

            // 3. Dependency filter (requires)
            if let reqs = tmpl.requires {
                if !reqs.allSatisfy({ satisfied($0, responses: responses, statuses: existingStatuses) }) { return nil }
            }

            // 4. Determine locked state
            let locked = isPlanning && tmpl.requiresDate

            // 5. Effective deadline
            let deadline = effectiveDeadline(tmpl, responses: responses)

            // 6. Existing status (preserved across re-evaluations)
            let status = existingStatuses[tmpl.id] ?? (locked ? .locked : .pending)

            return ResolvedTask(
                template: tmpl,
                status: status,
                locked: locked,
                effectiveDeadlineDays: deadline,
                departureDate: profile.departureDate
            )
        }
    }

    // MARK: - Trigger matching

    private static func matchesTriggers(_ t: TriggerConditions, flags: ProfileFlags) -> Bool {
        if let v = t.country,      v != flags.country  { return false }
        if let v = t.planning,     v != flags.planning  { return false }
        if let v = t.hasVisa,      v != flags.hasVisa   { return false }
        if let v = t.hasPassport,  v != flags.hasPassport { return false }
        if let v = t.hasSeniors,   v != flags.hasSeniors { return false }
        if let v = t.needsMobility, v != flags.needsMobility { return false }
        if let v = t.hasYoungKid,  v != flags.hasYoungKid { return false }
        if let v = t.hasKidUnder10, v != flags.hasKidUnder10 { return false }
        if let v = t.allAdults,    v != flags.allAdults  { return false }
        if let v = t.durationLong, v != flags.durationLong { return false }
        if let v = t.isFirstTrip,  v != flags.isFirstTrip { return false }
        return true
    }

    // MARK: - Dependency satisfaction

    static func satisfied(_ dep: DependencyCondition, responses: [String: [String]], statuses: [String: TaskStatus] = [:]) -> Bool {
        if let mustBeCompleted = dep.completed {
            let isCompleted = statuses[dep.task] == .completed
            return isCompleted == mustBeCompleted
        }
        guard let ans = responses[dep.task] else { return false }
        if let needed = dep.answerIn {
            return needed.contains(where: ans.contains)
        }
        if let any = dep.answerContainsAny {
            return any.contains(where: ans.contains)
        }
        if let all = dep.answerContainsAll {
            return all.allSatisfy(ans.contains)
        }
        return !ans.isEmpty
    }

    // MARK: - Deadline calculation

    static func effectiveDeadline(_ tmpl: TaskTemplate, responses: [String: [String]]) -> Int? {
        guard let cd = tmpl.conditionalDeadline else { return tmpl.deadlineDays }
        for rule in cd.rules {
            if satisfied(rule.condition, responses: responses) { return rule.days }
        }
        return cd.fallbackDays
    }

    // MARK: - Why-is-this-here explanation

    struct DependencyExplanation {
        let parentID: String
        let parentTitle: String
        let answerLabel: String
    }

    static func explainRequires(
        _ tmpl: TaskTemplate,
        responses: [String: [String]],
        templates: [TaskTemplate]
    ) -> [DependencyExplanation] {
        guard let reqs = tmpl.requires else { return [] }
        return reqs.compactMap { dep in
            guard let ans = responses[dep.task], !ans.isEmpty else { return nil }
            let parent = templates.first(where: { $0.id == dep.task })
            let label: String
            if let opt = parent?.decision?.options.first(where: { ans.contains($0.id) }) {
                label = opt.label
            } else if let grp = parent?.groups?.flatMap({ $0.options }).first(where: { ans.contains($0.id) }) {
                label = grp.label
            } else {
                label = ans.joined(separator: ", ")
            }
            return DependencyExplanation(
                parentID: dep.task,
                parentTitle: parent?.title ?? dep.task,
                answerLabel: label
            )
        }
    }
}
