import SwiftUI
import SwiftData

@main
struct MagicTripApp: App {
    let container: ModelContainer

    @AppStorage("appearanceMode") private var appearanceModeRaw: String = AppearanceMode.system.rawValue
    private var appearanceMode: AppearanceMode {
        AppearanceMode(rawValue: appearanceModeRaw) ?? .system
    }

    init() {
        do {
            container = try ModelContainer(for:
                TripProfile.self,
                Child.self,
                TaskResponse.self,
                AppliedSavingsTip.self,
                TripDay.self,
                TripDayItem.self
            )
        } catch {
            fatalError("SwiftData container failed: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .modelContainer(container)
                .preferredColorScheme(appearanceMode.colorScheme)
                .task { await ExchangeRateService.shared.refresh() }
        }
    }
}
