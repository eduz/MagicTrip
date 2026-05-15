import SwiftUI

struct MTSegmentedOption: Identifiable {
    let id: String
    let label: String
}

struct MTSegmented: View {
    let options: [MTSegmentedOption]
    @Binding var selected: String

    var body: some View {
        HStack(spacing: 2) {
            ForEach(options) { opt in
                let active = selected == opt.id
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) { selected = opt.id }
                } label: {
                    Text(opt.label)
                        .mtFont(14, weight: active ? .semibold : .medium)
                        .foregroundStyle(Color.mtText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(active ? Color.mtCard : Color.clear)
                        .cornerRadius(8)
                        .shadow(color: active ? Color.black.opacity(0.08) : .clear, radius: 3, x: 0, y: 1)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(2)
        .background(Color.mtBg2)
        .cornerRadius(10)
    }
}
