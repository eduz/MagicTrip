import SwiftUI
import SwiftData

struct CalendarView: View {
    let profile: TripProfile
    @Environment(\.modelContext) private var modelContext
    @State private var showAddActivity: TripDay? = nil
    @State private var editingItem: TripDayItem? = nil

    private var sortedDays: [TripDay] {
        profile.tripDays.sorted { $0.date < $1.date }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer().frame(height: 60)

                VStack(alignment: .leading, spacing: 2) {
                    Text(String(localized: "Calendário"))
                        .mtLabel()
                        .foregroundStyle(Color.mtText3)
                    Text(String(localized: "Dia a dia"))
                        .mtLargeTitle()
                        .foregroundStyle(Color.mtText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 16)

                if profile.planningStatus == .undecided {
                    lockedPlaceholder
                } else {
                    if sortedDays.isEmpty {
                        buildDaysButton
                    } else {
                        VStack(spacing: 12) {
                            ForEach(sortedDays) { day in
                                TripDayCard(
                                    day: day,
                                    onAddActivity: { showAddActivity = day },
                                    onEditItem: { editingItem = $0 }
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }

                Spacer().frame(height: 110)
            }
        }
        .scrollIndicators(.hidden)
        .sheet(item: $showAddActivity) { day in
            AddActivitySheet(day: day, profile: profile) { showAddActivity = nil }
        }
        .sheet(item: $editingItem) { item in
            ItemDetailSheet(item: item, profile: profile) { editingItem = nil }
        }
        .onAppear { buildTripDaysIfNeeded() }
    }

    @ViewBuilder
    private var lockedPlaceholder: some View {
        VStack(spacing: 14) {
            Image(systemName: "lock.fill")
                .mtFont(40)
                .foregroundStyle(Color.mtAmber)
            Text(String(localized: "Defina a data da viagem para usar o calendário"))
                .mtFont(15)
                .foregroundStyle(Color.mtText2)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
    }

    @ViewBuilder
    private var buildDaysButton: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar")
                .mtFont(40)
                .foregroundStyle(Color.mtPrimary)
            Text(String(localized: "Pronto para planejar seu roteiro?"))
                .mtFont(15)
                .foregroundStyle(Color.mtText2)
            MTButton(label: String(localized: "Criar dias da viagem"), variant: .primary) {
                buildTripDays()
            }
        }
        .frame(maxWidth: .infinity)
        .padding(40)
    }

    private func buildTripDaysIfNeeded() {
        guard profile.planningStatus == .dateConfirmed,
              profile.tripDays.isEmpty,
              let dep = profile.departureDate,
              let ret = profile.returnDate else { return }
        buildTripDays()
    }

    private func buildTripDays() {
        guard let dep = profile.departureDate, let ret = profile.returnDate else { return }
        let dates = Date.tripDays(from: dep, to: ret)
        for (idx, date) in dates.enumerated() {
            let day = TripDay(date: date, dayNumber: idx + 1)
            day.profile = profile
            profile.tripDays.append(day)
            modelContext.insert(day)
        }
    }
}
