import SwiftUI
import SwiftData

struct AddActivitySheet: View {
    let day: TripDay
    let profile: TripProfile
    var onClose: () -> Void

    @Environment(\.modelContext) private var modelContext
    @State private var segment: String = "parks"
    @State private var customTitle: String = ""
    @State private var searchText: String = ""

    private var parkOptions: [ParkOption] {
        CatalogLoader.shared.parkOptions().flatMap { $0.options }
    }

    private var commonActivities: [CommonActivity] {
        let all = CatalogLoader.shared.commonActivities
        if searchText.isEmpty { return all }
        return all.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }

    private var alreadyInDayIDs: Set<String> {
        Set(day.items.compactMap { $0.refID })
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                MTSegmented(
                    options: [
                        MTSegmentedOption(id: "parks", label: String(localized: "Parques")),
                        MTSegmentedOption(id: "common", label: String(localized: "Atividades")),
                        MTSegmentedOption(id: "custom", label: String(localized: "Personalizado")),
                    ],
                    selected: $segment
                )
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                if segment == "parks" {
                    parksSection
                } else if segment == "common" {
                    commonSection
                } else {
                    customSection
                }
            }
            .navigationTitle(String(localized: "Adicionar atividade"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(String(localized: "Cancelar"), action: onClose)
                        .foregroundStyle(Color.mtText2)
                }
            }
        }
    }

    @ViewBuilder
    private var parksSection: some View {
        // Filter to parks the user selected in P-01
        let selectedParkIDs = Set(profile.taskResponses
            .first(where: { $0.taskID == "P-01" })?.selectedOptionIDs ?? [])
        let filtered = selectedParkIDs.isEmpty ? parkOptions : parkOptions.filter { selectedParkIDs.contains($0.id) }

        ScrollView {
            VStack(spacing: 8) {
                ForEach(filtered) { park in
                    let inDay = alreadyInDayIDs.contains(park.id)
                    ActivityOptionRow(
                        title: park.label,
                        subtitle: inDay ? String(localized: "Já neste dia") : nil,
                        isAdded: inDay,
                        onAdd: { addItem(type: .park, refID: park.id, title: park.label) }
                    )
                }
            }
            .padding(16)
        }
    }

    @ViewBuilder
    private var commonSection: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color.mtText3)
                TextField(String(localized: "Buscar atividade..."), text: $searchText)
                    .mtKeyboardDoneToolbar()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color.mtBgSecondary)
            .cornerRadius(12)
            .padding(.horizontal, 16)
            .padding(.bottom, 8)

            ScrollView {
                VStack(spacing: 8) {
                    ForEach(commonActivities) { activity in
                        ActivityOptionRow(
                            title: activity.title,
                            subtitle: activity.category,
                            isAdded: false,
                            onAdd: { addItem(type: .commonActivity, refID: activity.id, title: activity.title) }
                        )
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    @ViewBuilder
    private var customSection: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(String(localized: "Nome da atividade"))
                    .mtFont(13)
                    .foregroundStyle(Color.mtText2)
                TextField(String(localized: "Ex: Jantar no Disney Springs"), text: $customTitle)
                    .mtFont(16)
                    .padding(14)
                    .background(Color.mtCard)
                    .cornerRadius(12)
                    .mtCardShadow()
                    .mtKeyboardDoneToolbar()
            }
            MTButton(label: String(localized: "Adicionar"), variant: .primary) {
                guard !customTitle.isEmpty else { return }
                addItem(type: .custom, refID: nil, title: customTitle)
            }
        }
        .padding(16)
        Spacer()
    }

    private func addItem(type: TripDayItemType, refID: String?, title: String) {
        let order = day.items.count
        let item = TripDayItem(type: type, refID: refID, title: title, order: order)
        item.day = day
        day.items.append(item)
        modelContext.insert(item)
        onClose()
    }
}

private struct ActivityOptionRow: View {
    let title: String
    let subtitle: String?
    let isAdded: Bool
    let onAdd: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .mtFont(15.5)
                    .foregroundStyle(Color.mtText)
                if let sub = subtitle {
                    Text(sub)
                        .mtFont(12.5)
                        .foregroundStyle(Color.mtText3)
                }
            }
            Spacer()
            Button(action: onAdd) {
                Image(systemName: "plus.circle.fill")
                    .mtFont(24)
                    .foregroundStyle(Color.mtPrimary)
            }
            .disabled(isAdded)
            .opacity(isAdded ? 0.4 : 1)
        }
        .padding(14)
        .background(Color.mtCard)
        .cornerRadius(12)
        .mtCardShadow()
    }
}
