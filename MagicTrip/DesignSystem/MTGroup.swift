import SwiftUI

// iOS Settings-style inset card group (ported from MTGroup in ui.jsx)
struct MTGroup<Content: View>: View {
    var header: String?
    var footer: String?
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let h = header {
                Text(h)
                    .mtLabel()
                    .foregroundStyle(Color.mtText2)
                    .padding(.horizontal, 20)
                    .padding(.top, 6)
                    .padding(.bottom, 8)
            }
            VStack(spacing: 0) {
                content
            }
            .background(Color.mtCard)
            .cornerRadius(.mtCard)
            .mtCardShadow()
            .padding(.horizontal, 16)

            if let f = footer {
                Text(f)
                    .mtFont(12.5)
                    .foregroundStyle(Color.mtText3)
                    .lineSpacing(3)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
            }
        }
        .padding(.bottom, 22)
    }
}

// Thin divider used between rows
struct MTDivider: View {
    var body: some View {
        Divider()
            .background(Color.mtDivider)
            .padding(.leading, 14)
    }
}
