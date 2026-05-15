import SwiftUI

struct TaskRow: View {
    let task: ResolvedTask
    let isNew: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 12) {
                statusIcon
                    .frame(width: 28, height: 28)
                    .padding(.top, 2)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(task.title)
                            .mtFont(15.5, weight: task.isCompleted ? .regular : .medium)
                            .foregroundStyle(task.isLocked ? Color.mtText3 : Color.mtText)
                            .strikethrough(task.isCompleted, color: Color.mtText3)
                            .lineLimit(2)
                        if isNew {
                            Text(String(localized: "Nova"))
                                .mtFont(10, weight: .bold)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.mtPrimary)
                                .cornerRadius(6)
                        }
                    }

                    HStack(spacing: 8) {
                        MTPriorityDot(priority: task.priority)

                        if task.isLocked {
                            Label(String(localized: "Aguarda data"), systemImage: "lock.fill")
                                .mtFont(12)
                                .foregroundStyle(Color.mtAmber)
                        } else if let deadline = task.effectiveDeadline {
                            deadlineBadge(deadline)
                        }

                        if let saving = task.estimatedSavingUSD, saving > 0, !task.isCompleted {
                            savingsChip(saving)
                        }
                    }
                }

                Spacer(minLength: 4)

                Image(systemName: "chevron.right")
                    .mtFont(11, weight: .semibold)
                    .foregroundStyle(Color.mtText3)
                    .padding(.top, 6)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var statusIcon: some View {
        if task.isLocked {
            ZStack {
                Circle()
                    .fill(Color.mtBgSecondary)
                    .frame(width: 28, height: 28)
                Image(systemName: "lock.fill")
                    .mtFont(13)
                    .foregroundStyle(Color.mtText3)
            }
        } else if task.taskType == .decision {
            ZStack {
                Circle()
                    .strokeBorder(
                        task.isCompleted ? Color.mtSuccess : Color.mtPrimary.opacity(0.5),
                        lineWidth: 2
                    )
                    .frame(width: 28, height: 28)
                if task.isCompleted {
                    Image(systemName: "checkmark")
                        .mtFont(13, weight: .bold)
                        .foregroundStyle(Color.mtSuccess)
                } else {
                    Text("?")
                        .mtFont(13, weight: .bold)
                        .foregroundStyle(Color.mtPrimary)
                }
            }
        } else {
            ZStack {
                Circle()
                    .strokeBorder(
                        task.isCompleted ? Color.mtSuccess : Color.mtBorder,
                        lineWidth: 2
                    )
                    .background(
                        Circle().fill(task.isCompleted ? Color.mtSuccess : Color.clear)
                    )
                    .frame(width: 28, height: 28)
                if task.isCompleted {
                    Image(systemName: "checkmark")
                        .mtFont(13, weight: .bold)
                        .foregroundStyle(.white)
                }
            }
        }
    }

    @ViewBuilder
    private func deadlineBadge(_ deadline: Date) -> some View {
        let days = max(0, deadline.daysFromNow)
        let isUrgent = days <= 7
        Label(
            days == 0 ? String(localized: "Hoje") : "\(days)d",
            systemImage: "clock"
        )
        .mtFont(11.5, weight: .medium)
        .foregroundStyle(isUrgent ? Color.mtDanger : Color.mtText3)
    }

    @ViewBuilder
    private func savingsChip(_ usd: Double) -> some View {
        HStack(spacing: 3) {
            Image(systemName: "sparkles")
                .mtFont(10)
            Text(usd.formatUSD())
                .mtFont(11.5, weight: .semibold).monospacedDigit()
        }
        .foregroundStyle(Color.mtViolet)
        .padding(.horizontal, 7)
        .padding(.vertical, 2)
        .background(Color.mtVioletBg)
        .cornerRadius(8)
    }
}
