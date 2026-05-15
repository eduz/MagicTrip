import SwiftUI
import SwiftData

@Observable
final class AppState {
    var selectedTab: Tab = .checklist
    var showOnboarding: Bool = false
    var showEditProfile: Bool = false
    var openTaskID: String? = nil
    var showSavingsSheet: Bool = false

    enum Tab: String { case checklist, calendar, tools, profile }
}
