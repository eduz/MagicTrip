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
            SplashHostView {
                RootTabView()
            }
                .modelContainer(container)
                .preferredColorScheme(appearanceMode.colorScheme)
                .task { await ExchangeRateService.shared.refresh() }
        }
    }
}

private struct SplashHostView<Content: View>: View {
    private let content: Content
    @State private var isShowingSplash = true

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            content

            if isShowingSplash {
                SplashScreenView()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .task {
            try? await Task.sleep(for: .milliseconds(900))
            withAnimation(.easeOut(duration: 0.35)) {
                isShowingSplash = false
            }
        }
    }
}

private struct SplashScreenView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.055, green: 0.071, blue: 0.118),
                    Color(red: 0.120, green: 0.080, blue: 0.180),
                    Color(red: 0.300, green: 0.105, blue: 0.110)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 18) {
                Image("SplashLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 148, height: 148)
                    .shadow(color: .black.opacity(0.28), radius: 18, x: 0, y: 12)

                Text("MagicTrip")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
        }
    }
}
