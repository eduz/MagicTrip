import SwiftUI

// Coral→violet gradient card used for the savings tile
struct GradientCard<Content: View>: View {
    var reversed: Bool = false
    @ViewBuilder let content: Content

    private var gradient: LinearGradient {
        LinearGradient(
            colors: reversed
                ? [.mtPrimary, .mtViolet]
                : [.mtViolet, .mtPrimary],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        content
            .background(gradient)
            .cornerRadius(.mtCardLg)
            .shadow(color: Color.mtViolet.opacity(0.28), radius: 11, x: 0, y: 8)
    }
}
