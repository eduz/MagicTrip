import SwiftUI
import SwiftData

struct ItemDetailSheet: View {
    let item: TripDayItem
    let profile: TripProfile
    var onClose: () -> Void

    @Environment(\.modelContext) private var modelContext
    @State private var noteText: String = ""
    @State private var showMovePicker = false

    private var otherDaysWithSameRef: [TripDay] {
        guard let ref = item.refID else { return [] }
        return profile.tripDays.filter { day in
            day.id != item.day?.id && day.items.contains { $0.refID == ref }
        }.sorted { $0.date < $1.date }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.mtPrimaryBg)
                                .frame(width: 44, height: 44)
                            Image(systemName: item.sfSymbol)
                                .mtFont(20)
                                .foregroundStyle(Color.mtPrimary)
                        }
                        Text(item.title)
                            .mtFont(17, weight: .semibold)
                    }
                    .padding(.vertical, 4)
                }

                Section(String(localized: "Nota")) {
                    TextField(String(localized: "Adicione uma nota..."), text: $noteText, axis: .vertical)
                        .lineLimit(3...6)
                        .mtFont(15)
                        .mtKeyboardDoneToolbar()
                }

                if !otherDaysWithSameRef.isEmpty {
                    Section(String(localized: "Também planejado em")) {
                        ForEach(otherDaysWithSameRef) { day in
                            Text(day.date.tripDayFormatted)
                                .mtFont(15)
                                .foregroundStyle(Color.mtText2)
                        }
                    }
                }

                Section {
                    Button(String(localized: "Mover para outro dia")) {
                        showMovePicker = true
                    }
                    .foregroundStyle(Color.mtPrimary)

                    Button(String(localized: "Remover"), role: .destructive) {
                        if let day = item.day {
                            day.items.removeAll { $0.id == item.id }
                        }
                        modelContext.delete(item)
                        onClose()
                    }
                }
            }
            .navigationTitle(String(localized: "Atividade"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(String(localized: "Cancelar"), action: onClose)
                        .foregroundStyle(Color.mtText2)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(String(localized: "Salvar")) {
                        item.note = noteText.isEmpty ? nil : noteText
                        onClose()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.mtPrimary)
                }
            }
            .sheet(isPresented: $showMovePicker) {
                MoveToDayPicker(item: item, profile: profile) { showMovePicker = false }
            }
        }
        .onAppear { noteText = item.note ?? "" }
    }
}

private struct MoveToDayPicker: View {
    let item: TripDayItem
    let profile: TripProfile
    var onClose: () -> Void

    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            List {
                ForEach(profile.tripDays.sorted { $0.date < $1.date }) { day in
                    if day.id != item.day?.id {
                        Button(day.date.tripDayFormatted) {
                            move(to: day)
                        }
                        .foregroundStyle(Color.mtText)
                    }
                }
            }
            .navigationTitle(String(localized: "Mover para"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(String(localized: "Cancelar"), action: onClose)
                }
            }
        }
    }

    private func move(to newDay: TripDay) {
        if let oldDay = item.day {
            oldDay.items.removeAll { $0.id == item.id }
        }
        item.order = newDay.items.count
        item.day = newDay
        newDay.items.append(item)
        onClose()
    }
}
