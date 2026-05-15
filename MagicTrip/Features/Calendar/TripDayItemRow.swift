import SwiftUI

struct TripDayItemRow: View {
    let item: TripDayItem
    var canMoveUp: Bool = false
    var canMoveDown: Bool = false
    var onTap: () -> Void
    var onMoveUp: () -> Void = {}
    var onMoveDown: () -> Void = {}

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(itemColor.opacity(0.15))
                        .frame(width: 34, height: 34)
                    Image(systemName: item.sfSymbol)
                        .mtFont(16, weight: .medium)
                        .foregroundStyle(itemColor)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .mtFont(15, weight: .medium)
                        .foregroundStyle(Color.mtText)
                    if let note = item.note, !note.isEmpty {
                        Text(note)
                            .mtFont(12.5)
                            .foregroundStyle(Color.mtText3)
                            .lineLimit(1)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .mtFont(11)
                    .foregroundStyle(Color.mtText3)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .contextMenu {
            if canMoveUp {
                Button {
                    onMoveUp()
                } label: {
                    Label(String(localized: "Mover para cima"), systemImage: "arrow.up")
                }
            }
            if canMoveDown {
                Button {
                    onMoveDown()
                } label: {
                    Label(String(localized: "Mover para baixo"), systemImage: "arrow.down")
                }
            }
        }
    }

    private var itemColor: Color {
        switch item.type {
        case .park:           return Color.mtPrimary
        case .commonActivity: return Color.mtViolet
        case .custom:         return Color.mtText3
        }
    }
}
