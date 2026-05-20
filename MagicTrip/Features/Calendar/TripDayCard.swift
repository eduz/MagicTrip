import SwiftUI

struct TripDayCard: View {
    let day: TripDay
    let country: String
    var onAddActivity: () -> Void
    var onEditItem: (TripDayItem) -> Void

    @State private var showNoteEditor = false

    private var sortedItems: [TripDayItem] {
        day.items.sorted { $0.order < $1.order }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(day.date.calendarFormatted(country: country))
                        .mtFont(15.5, weight: .semibold)
                        .foregroundStyle(day.date.isPast && !day.date.isToday ? Color.mtText3 : Color.mtText)
                    if day.date.isToday {
                        Text(String(localized: "Hoje"))
                            .mtFont(11, weight: .bold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.mtPrimary)
                            .cornerRadius(8)
                    }
                }
                Spacer()
                HStack(spacing: 16) {
                    Button(action: onAddActivity) {
                        Image(systemName: "plus")
                            .mtFont(16)
                            .foregroundStyle(Color.mtPrimary)
                    }
                    Button { showNoteEditor = true } label: {
                        Image(systemName: day.note?.isEmpty == false ? "note.text" : "pencil")
                            .mtFont(16)
                            .foregroundStyle(Color.mtText3)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)

            if !sortedItems.isEmpty {
                MTDivider()
                ForEach(Array(sortedItems.enumerated()), id: \.element.id) { index, item in
                    TripDayItemRow(
                        item: item,
                        canMoveUp: index > 0,
                        canMoveDown: index < sortedItems.count - 1,
                        onTap: { onEditItem(item) },
                        onMoveUp: { move(from: index, to: index - 1) },
                        onMoveDown: { move(from: index, to: index + 1) }
                    )
                    MTDivider().padding(.leading, 48)
                }
            }
        }
        .background(Color.mtCard)
        .cornerRadius(.mtCardLg)
        .mtCardShadow()
        .opacity(day.date.isPast && !day.date.isToday ? 0.65 : 1)
        .sheet(isPresented: $showNoteEditor) {
            DayNoteEditor(day: day) { showNoteEditor = false }
        }
    }

    private func move(from src: Int, to dst: Int) {
        var items = sortedItems
        guard items.indices.contains(src), items.indices.contains(dst) else { return }
        let moved = items.remove(at: src)
        items.insert(moved, at: dst)
        for (i, it) in items.enumerated() {
            it.order = i
        }
    }
}
