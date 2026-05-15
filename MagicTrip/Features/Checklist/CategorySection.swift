import SwiftUI

struct CategorySection: View {
    let category: TaskCategory
    let tasks: [ResolvedTask]
    let newTaskIDs: Set<String>
    let isCollapsed: Bool
    let onToggleCollapse: () -> Void
    let onOpenTask: (ResolvedTask) -> Void

    private var completedCount: Int { tasks.filter { $0.isCompleted }.count }
    private var allDone: Bool { completedCount == tasks.count && !tasks.isEmpty }

    var body: some View {
        VStack(spacing: 0) {
            // Section header
            Button(action: onToggleCollapse) {
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(allDone ? Color.mtSuccess.opacity(0.15) : Color.mtPrimaryBg)
                            .frame(width: 32, height: 32)
                        Image(systemName: category.sfSymbol)
                            .mtFont(15, weight: .medium)
                            .foregroundStyle(allDone ? Color.mtSuccess : Color.mtPrimary)
                    }
                    Text(category.label)
                        .mtFont(15.5, weight: .semibold)
                        .foregroundStyle(Color.mtText)
                    Spacer()
                    Text("\(completedCount)/\(tasks.count)")
                        .mtFont(13).monospacedDigit()
                        .foregroundStyle(Color.mtText3)
                    Image(systemName: isCollapsed ? "chevron.right" : "chevron.down")
                        .mtFont(12, weight: .semibold)
                        .foregroundStyle(Color.mtText3)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if !isCollapsed {
                VStack(spacing: 0) {
                    ForEach(Array(tasks.enumerated()), id: \.element.id) { index, task in
                        TaskRow(
                            task: task,
                            isNew: newTaskIDs.contains(task.id),
                            onTap: { onOpenTask(task) }
                        )
                        if index < tasks.count - 1 {
                            MTDivider()
                                .padding(.leading, 52)
                        }
                    }
                }
                .background(Color.mtCard)
                .cornerRadius(.mtCardLg)
                .mtCardShadow()
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isCollapsed)
    }
}
