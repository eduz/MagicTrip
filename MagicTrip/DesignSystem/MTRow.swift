import SwiftUI

// Settings-style row with optional icon tile, title, subtitle, value, chevron
struct MTRow: View {
    var icon: MTIcon? = nil
    var iconColor: Color = .mtText
    var iconBg: Color = .mtBg2
    var title: String
    var subtitle: String? = nil
    var value: String? = nil
    var chevron: Bool = false
    var last: Bool = false
    var danger: Bool = false
    var action: (() -> Void)? = nil
    var trailing: (() -> AnyView)? = nil

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                if let ic = icon {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(iconBg)
                            .frame(width: 30, height: 30)
                        Image(systemName: ic.rawValue)
                            .mtFont(15, weight: .medium)
                            .foregroundStyle(iconColor)
                    }
                }
                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .mtFont(16, weight: .medium)
                        .foregroundStyle(danger ? Color.mtDanger : Color.mtText)
                    if let sub = subtitle {
                        Text(sub)
                            .mtFont(13.5)
                            .foregroundStyle(Color.mtText2)
                    }
                }
                Spacer()
                if let val = value {
                    Text(val)
                        .mtFont(15)
                        .foregroundStyle(Color.mtText2)
                }
                if let trailingView = trailing {
                    trailingView()
                }
                if chevron {
                    Image(systemName: MTIcon.chevron.rawValue)
                        .mtFont(13, weight: .medium)
                        .foregroundStyle(Color.mtText3)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
            .onTapGesture { action?() }

            if !last {
                MTDivider()
            }
        }
    }
}
