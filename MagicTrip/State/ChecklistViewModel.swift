import SwiftUI
import SwiftData

@Observable
final class ChecklistViewModel {
    private(set) var resolvedTasks: [ResolvedTask] = []
    private(set) var responses: [String: [String]] = [:]
    private(set) var newTaskIDs: Set<String> = []
    private var previousVisibleIDs: Set<String> = []
    private(set) var totalSavedUSD: Double = 0

    let catalog = CatalogLoader.shared

    // Grouped by category, in canonical order, excluding archived/skipped
    var groupedTasks: [(TaskCategory, [ResolvedTask])] {
        var byCat: [TaskCategory: [ResolvedTask]] = [:]
        for cat in TaskCategory.allCases { byCat[cat] = [] }
        for t in resolvedTasks where t.status != .archived && t.status != .skipped {
            byCat[t.category, default: []].append(t)
        }
        return TaskCategory.allCases.compactMap { cat in
            let prio: [TaskPriority: Int] = [.critical: 0, .high: 1, .medium: 2, .low: 3]
            let list = (byCat[cat] ?? []).sorted { a, b in
                let dA = a.template.deadlineDays ?? -1
                let dB = b.template.deadlineDays ?? -1
                if dA != dB { return dA > dB }
                return (prio[a.priority] ?? 3) < (prio[b.priority] ?? 3)
            }
            return list.isEmpty ? nil : (cat, list)
        }
    }

    var activeCount: Int    { resolvedTasks.filter { !$0.isCompleted && !$0.isSkipped && !$0.isArchived }.count }
    var completedCount: Int { resolvedTasks.filter { $0.isCompleted }.count }
    var progressPct: Double { activeCount + completedCount == 0 ? 0 : Double(completedCount) / Double(activeCount + completedCount) }
    var urgentCount: Int    { resolvedTasks.filter { $0.priority == .critical && !$0.isCompleted && !$0.locked }.count }

    func evaluate(profile: TripProfile) {
        let existingStatuses = Dictionary(uniqueKeysWithValues: resolvedTasks.map { ($0.id, $0.status) })
        let newResolved = ChecklistRuleEngine.evaluate(
            templates: catalog.tasks,
            profile: profile,
            responses: responses,
            existingStatuses: existingStatuses
        )
        let visibleIDs = Set(newResolved.map { $0.id })
        let newlyVisible = visibleIDs.subtracting(previousVisibleIDs)
        resolvedTasks = newResolved.map { t in
            var mt = t
            mt.isNew = newlyVisible.contains(t.id) && !existingStatuses.isEmpty
            return mt
        }
        previousVisibleIDs = visibleIDs
        recalcTotalSaved(profile: profile)
    }

    func setStatus(taskID: String, status: TaskStatus, profile: TripProfile) {
        resolvedTasks = resolvedTasks.map { t in
            var mt = t; if t.id == taskID { mt.status = status }; return mt
        }
        evaluate(profile: profile)
    }

    func setResponse(taskID: String, optionIDs: [String], profile: TripProfile) {
        responses[taskID] = optionIDs
        evaluate(profile: profile)
    }

    func clearResponse(taskID: String, profile: TripProfile) {
        responses.removeValue(forKey: taskID)
        evaluate(profile: profile)
    }

    func dismissNew(_ id: String) {
        resolvedTasks = resolvedTasks.map { t in
            var mt = t; if t.id == id { mt.isNew = false }; return mt
        }
    }

    func recalcTotalSaved(profile: TripProfile) {
        totalSavedUSD = profile.appliedSavings.reduce(0) { $0 + $1.totalSavedUSD }
    }

    func isTipApplied(taskID: String, tipID: String, profile: TripProfile) -> Bool {
        profile.appliedSavings.contains { $0.taskID == taskID && $0.tipID == tipID }
    }

    func toggleSavingsTip(
        taskID: String,
        tip: SavingsTipTemplate,
        travelers: Int,
        profile: TripProfile,
        context: ModelContext
    ) {
        if let existing = profile.appliedSavings.first(where: { $0.taskID == taskID && $0.tipID == tip.id }) {
            context.delete(existing)
        } else {
            let entry = AppliedSavingsTip(
                tipID: tip.id,
                taskID: taskID,
                amountPerPerson: tip.usdPerPerson,
                travelers: travelers,
                scope: tip.savingsScope
            )
            entry.profile = profile
            profile.appliedSavings.append(entry)
            context.insert(entry)
        }
        recalcTotalSaved(profile: profile)
    }

    /// Load responses from persisted TaskResponse records on the profile.
    func loadResponses(from profile: TripProfile) {
        responses = Dictionary(uniqueKeysWithValues: profile.taskResponses.map { ($0.taskID, $0.selectedOptionIDs) })
    }

    /// Persist a response to SwiftData via the profile's task responses.
    func setAndPersistResponse(taskID: String, optionIDs: [String], profile: TripProfile, context: ModelContext) {
        if let existing = profile.taskResponses.first(where: { $0.taskID == taskID }) {
            existing.selectedOptionIDs = optionIDs
        } else {
            let r = TaskResponse(taskID: taskID, selectedOptionIDs: optionIDs)
            r.profile = profile
            profile.taskResponses.append(r)
            context.insert(r)
        }
        responses[taskID] = optionIDs
        evaluate(profile: profile)
    }
}
