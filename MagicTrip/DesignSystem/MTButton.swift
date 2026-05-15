import SwiftUI

enum MTButtonVariant {
    case primary, coral, violet, ghost, outline, danger, soft
}

struct MTButton: View {
    let label: String
    let variant: MTButtonVariant
    var size: MTButtonSize = .lg
    var disabled: Bool = false
    let action: () -> Void

    enum MTButtonSize { case lg, md, sm }

    private var bg: Color {
        switch variant {
        case .primary: return .mtText
        case .coral:   return .mtPrimary
        case .violet:  return .mtViolet
        case .ghost:   return .clear
        case .outline: return .mtCard
        case .danger:  return .mtDangerBg
        case .soft:    return .mtBg2
        }
    }
    private var fg: Color {
        switch variant {
        case .primary: return .mtCard
        case .coral, .violet: return .white
        case .ghost:   return .mtPrimary
        case .outline: return .mtText
        case .danger:  return .mtDanger
        case .soft:    return .mtText
        }
    }
    private var padding: EdgeInsets {
        switch size {
        case .lg: return EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20)
        case .md: return EdgeInsets(top: 11, leading: 16, bottom: 11, trailing: 16)
        case .sm: return EdgeInsets(top: 7, leading: 12, bottom: 7, trailing: 12)
        }
    }
    private var fontSize: CGFloat { size == .sm ? 13 : size == .md ? 15 : 17 }
    private var radius: CGFloat { size == .sm ? 10 : 14 }

    var body: some View {
        Button(action: action) {
            Text(label)
                .mtFont(fontSize, weight: .semibold)
                .tracking(-0.1)
                .foregroundStyle(fg)
                .frame(maxWidth: .infinity)
                .padding(padding)
                .background(bg)
                .cornerRadius(radius)
                .overlay(
                    variant == .outline
                    ? RoundedRectangle(cornerRadius: radius).stroke(Color.mtCardLine, lineWidth: 1)
                    : nil
                )
        }
        .disabled(disabled)
        .opacity(disabled ? 0.45 : 1)
    }
}

// Label + icon variant
struct MTButtonIcon: View {
    let icon: MTIcon
    let label: String
    var variant: MTButtonVariant = .coral
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon.rawValue)
                    .mtFont(17, weight: .medium)
                Text(label)
                    .mtFont(17, weight: .semibold)
            }
            .foregroundStyle(Color.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(variant == .violet ? Color.mtViolet : Color.mtPrimary)
            .cornerRadius(14)
        }
    }
}
