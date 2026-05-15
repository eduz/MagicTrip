import SwiftUI

struct MTPriorityDot: View {
    let priority: TaskPriority

    var color: Color {
        switch priority {
        case .critical: return .mtDanger
        case .high:     return .mtAmber
        case .medium:   return .mtSky
        case .low:      return .mtText3
        }
    }

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 7, height: 7)
    }
}
