import SwiftUI
import UIKit

// MARK: - Dynamic color helper
private func mtDynamic(_ light: UIColor, _ dark: UIColor) -> Color {
    Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark ? dark : light
    })
}

private func rgb(_ r: Double, _ g: Double, _ b: Double) -> UIColor {
    UIColor(red: r, green: g, blue: b, alpha: 1)
}

// MARK: - Color tokens (ported from ui.jsx MT object, with dark-mode variants)
extension Color {
    static let mtBg        = mtDynamic(rgb(0.985, 0.978, 0.965), rgb(0.055, 0.055, 0.060))
    static let mtBg2       = mtDynamic(rgb(0.964, 0.956, 0.940), rgb(0.105, 0.105, 0.115))
    static let mtCard      = mtDynamic(.white,                    rgb(0.118, 0.118, 0.128))
    static let mtCardLine  = mtDynamic(rgb(0.906, 0.903, 0.898), rgb(0.180, 0.180, 0.192))
    static let mtText      = mtDynamic(rgb(0.123, 0.120, 0.132), rgb(0.952, 0.948, 0.960))
    static let mtText2     = mtDynamic(rgb(0.415, 0.408, 0.430), rgb(0.680, 0.672, 0.700))
    static let mtText3     = mtDynamic(rgb(0.485, 0.478, 0.498), rgb(0.595, 0.588, 0.610))
    static let mtDivider   = mtDynamic(rgb(0.890, 0.886, 0.895), rgb(0.200, 0.200, 0.215))

    // Primary — coral/sunset
    static let mtPrimary   = mtDynamic(rgb(0.830, 0.330, 0.180), rgb(0.940, 0.430, 0.270))
    static let mtPrimaryDk = mtDynamic(rgb(0.760, 0.280, 0.130), rgb(0.870, 0.370, 0.210))
    static let mtPrimaryBg = mtDynamic(rgb(0.990, 0.940, 0.920), rgb(0.230, 0.115, 0.075))

    // Violet — savings/celebration
    static let mtViolet    = mtDynamic(rgb(0.430, 0.270, 0.720), rgb(0.620, 0.470, 0.910))
    static let mtVioletBg  = mtDynamic(rgb(0.955, 0.940, 0.990), rgb(0.150, 0.110, 0.235))

    // Semantic
    static let mtSuccess   = mtDynamic(rgb(0.220, 0.620, 0.380), rgb(0.380, 0.780, 0.530))
    static let mtSuccessBg = mtDynamic(rgb(0.920, 0.970, 0.940), rgb(0.075, 0.180, 0.115))
    static let mtAmber     = mtDynamic(rgb(0.780, 0.590, 0.120), rgb(0.960, 0.780, 0.310))
    static let mtAmberBg   = mtDynamic(rgb(0.990, 0.970, 0.920), rgb(0.200, 0.155, 0.060))
    static let mtAmberText = mtDynamic(rgb(0.400, 0.350, 0.100), rgb(0.960, 0.860, 0.560))
    static let mtDanger    = mtDynamic(rgb(0.820, 0.210, 0.140), rgb(0.960, 0.380, 0.310))
    static let mtDangerBg  = mtDynamic(rgb(0.990, 0.925, 0.915), rgb(0.220, 0.080, 0.060))
    static let mtSky       = mtDynamic(rgb(0.230, 0.530, 0.780), rgb(0.430, 0.700, 0.940))
    static let mtSkyBg     = mtDynamic(rgb(0.930, 0.960, 0.995), rgb(0.080, 0.140, 0.235))

    // Semantic aliases
    static let mtBgSecondary = mtBg2
    static let mtBorder      = mtCardLine
}

// MARK: - Scalable font modifier (respects Dynamic Type)
struct MTScaledFont: ViewModifier {
    @ScaledMetric private var size: CGFloat
    private let weight: Font.Weight
    private let design: Font.Design

    init(size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default, relativeTo style: Font.TextStyle = .body) {
        self._size = ScaledMetric(wrappedValue: size, relativeTo: style)
        self.weight = weight
        self.design = design
    }

    func body(content: Content) -> some View {
        content.font(.system(size: size, weight: weight, design: design))
    }
}

extension View {
    func mtFont(_ size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default, relativeTo style: Font.TextStyle = .body) -> some View {
        modifier(MTScaledFont(size: size, weight: weight, design: design, relativeTo: style))
    }
}

// MARK: - Typography modifiers
extension View {
    func mtLargeTitle() -> some View {
        self.mtFont(32, weight: .bold, relativeTo: .largeTitle).tracking(-0.8)
    }
    func mtTitle() -> some View {
        self.mtFont(24, weight: .bold, relativeTo: .title).tracking(-0.5)
    }
    func mtHeadline() -> some View {
        self.mtFont(17, weight: .semibold, relativeTo: .headline).tracking(-0.1)
    }
    func mtBody() -> some View {
        self.mtFont(15.5, relativeTo: .body).tracking(-0.1)
    }
    func mtCaption() -> some View {
        self.mtFont(13, weight: .medium, relativeTo: .footnote)
    }
    func mtLabel() -> some View {
        self.mtFont(11, weight: .semibold, relativeTo: .caption2).textCase(.uppercase).tracking(0.4)
    }
}

// MARK: - Corner radius constants
extension CGFloat {
    static let mtCard: CGFloat = 14
    static let mtCardLg: CGFloat = 18
    static let mtBtn: CGFloat = 14
}

// MARK: - Shadow style
struct MTCardShadow: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(color: Color.mtCardLine, radius: 0, x: 0, y: 1)
    }
}
extension View {
    func mtCardShadow() -> some View { modifier(MTCardShadow()) }
}

// MARK: - Appearance mode (light / dark / system)
enum AppearanceMode: String, CaseIterable, Identifiable {
    case system, light, dark
    var id: String { rawValue }

    var label: String {
        switch self {
        case .system: return String(localized: "Sistema")
        case .light:  return String(localized: "Claro")
        case .dark:   return String(localized: "Escuro")
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }
}

// MARK: - Keyboard dismiss toolbar
extension View {
    func mtKeyboardDoneToolbar() -> some View {
        toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button(String(localized: "Concluído")) {
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder),
                        to: nil, from: nil, for: nil
                    )
                }
                .foregroundStyle(Color.mtPrimary)
                .fontWeight(.semibold)
            }
        }
    }
}
