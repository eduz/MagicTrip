import SwiftUI

// SF Symbol mapping for the MagicTrip icon set (ported from ui.jsx ICONS)
enum MTIcon: String {
    // categories
    case calendar    = "calendar"
    case id          = "person.text.rectangle"
    case dollar      = "dollarsign.circle"
    case bed         = "bed.double"
    case plane       = "airplane"
    case ticket      = "ticket"
    case sun         = "sun.max"
    case bag         = "bag"
    case heart       = "heart"
    case home        = "house"
    // ui
    case check       = "checkmark"
    case chevron     = "chevron.right"
    case chevronL    = "chevron.left"
    case chevronD    = "chevron.down"
    case close       = "xmark"
    case lock        = "lock.fill"
    case share       = "square.and.arrow.up"
    case edit        = "pencil"
    case sparkle     = "sparkles"
    case trip        = "mappin.and.ellipse"
    case rocket      = "arrow.up.right.circle"
    case search      = "magnifyingglass"
    case briefcase   = "person.crop.square"
    case arrowsLR    = "arrow.left.arrow.right"
    case receipt     = "receipt"
    case toolbox     = "wrench.and.screwdriver"
    case bell        = "bell"
    case bookmark    = "bookmark"
    case list        = "list.bullet"
    case drag        = "line.3.horizontal"
    case info        = "info.circle"
    case plus        = "plus"
    case globe       = "globe"
}

struct MTIcon_View: View {
    let icon: MTIcon
    var size: CGFloat = 22
    var color: Color = .primary

    var body: some View {
        Image(systemName: icon.rawValue)
            .mtFont(size, weight: .medium)
            .foregroundStyle(color)
    }
}
