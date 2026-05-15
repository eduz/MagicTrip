import SwiftUI

struct DecisionOptionCard: View {
    let option: DecisionOption
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .strokeBorder(isSelected ? Color.mtPrimary : Color.mtBorder, lineWidth: 2)
                        .frame(width: 22, height: 22)
                    if isSelected {
                        Circle()
                            .fill(Color.mtPrimary)
                            .frame(width: 12, height: 12)
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(option.label)
                        .mtFont(15.5, weight: isSelected ? .semibold : .regular)
                        .foregroundStyle(Color.mtText)
                    if let sub = option.subtitle {
                        Text(sub)
                            .mtFont(13)
                            .foregroundStyle(Color.mtText2)
                    }
                }
                Spacer()
            }
            .padding(14)
            .background(isSelected ? Color.mtPrimaryBg : Color.mtCard)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isSelected ? Color.mtPrimary.opacity(0.4) : Color.clear, lineWidth: 1.5)
            )
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}
