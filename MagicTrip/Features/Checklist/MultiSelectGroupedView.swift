import SwiftUI

struct MultiSelectGroupedView: View {
    let groups: [ParkGroup]
    let selectedIDs: Set<String>
    let onToggle: (String) -> Void

    @State private var collapsedGroups: Set<String> = []

    var body: some View {
        VStack(spacing: 8) {
            ForEach(groups) { group in
                let groupSelected = group.options.filter { selectedIDs.contains($0.id) }.count
                let isCollapsed = collapsedGroups.contains(group.id)

                VStack(spacing: 0) {
                    Button {
                        if isCollapsed { collapsedGroups.remove(group.id) }
                        else { collapsedGroups.insert(group.id) }
                    } label: {
                        HStack {
                            Text(group.label)
                                .mtFont(14, weight: .semibold)
                                .foregroundStyle(Color.mtText)
                            Spacer()
                            if groupSelected > 0 {
                                Text("\(groupSelected)")
                                    .mtFont(12, weight: .bold)
                                    .foregroundStyle(.white)
                                    .frame(minWidth: 20, minHeight: 20)
                                    .background(Color.mtPrimary)
                                    .clipShape(Circle())
                            }
                            Image(systemName: isCollapsed ? "chevron.right" : "chevron.down")
                                .mtFont(11, weight: .semibold)
                                .foregroundStyle(Color.mtText3)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                    }
                    .buttonStyle(.plain)

                    if !isCollapsed {
                        MTDivider()
                        ForEach(Array(group.options.enumerated()), id: \.element.id) { idx, option in
                            HStack(spacing: 12) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 5)
                                        .strokeBorder(
                                            selectedIDs.contains(option.id) ? Color.mtPrimary : Color.mtBorder,
                                            lineWidth: 2
                                        )
                                        .background(
                                            RoundedRectangle(cornerRadius: 5)
                                                .fill(selectedIDs.contains(option.id) ? Color.mtPrimary : Color.clear)
                                        )
                                        .frame(width: 22, height: 22)
                                    if selectedIDs.contains(option.id) {
                                        Image(systemName: "checkmark")
                                            .mtFont(12, weight: .bold)
                                            .foregroundStyle(.white)
                                    }
                                }
                                Text(option.label)
                                    .mtFont(15)
                                    .foregroundStyle(Color.mtText)
                                Spacer()
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .contentShape(Rectangle())
                            .onTapGesture { onToggle(option.id) }

                            if idx < group.options.count - 1 { MTDivider().padding(.leading, 48) }
                        }
                    }
                }
                .background(Color.mtCard)
                .cornerRadius(12)
                .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isCollapsed)
            }
        }
    }
}
