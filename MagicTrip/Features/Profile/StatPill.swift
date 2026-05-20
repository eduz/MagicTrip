import SwiftUI

struct StatPill: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .mtFont(13)
                .foregroundStyle(Color.mtPrimary)
            VStack(alignment: .leading, spacing: 0) {
                Text(value)
                    .mtFont(14, weight: .semibold)
                    .foregroundStyle(Color.mtText)
                Text(label)
                    .mtFont(11)
                    .foregroundStyle(Color.mtText3)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.mtCard)
        .cornerRadius(12)
        .mtCardShadow()
    }
}
