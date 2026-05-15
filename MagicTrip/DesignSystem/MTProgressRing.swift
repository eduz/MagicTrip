import SwiftUI

struct MTProgressRing: View {
    var pct: Double          // 0.0 – 1.0
    var size: CGFloat = 64
    var strokeWidth: CGFloat = 6
    var color: Color = .mtPrimary
    var label: String? = nil

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.mtBg2, lineWidth: strokeWidth)
            Circle()
                .trim(from: 0, to: CGFloat(pct))
                .stroke(color, style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: pct)
            if let lbl = label {
                Text(lbl)
                    .mtFont(size > 60 ? 16 : 13, weight: .bold).monospacedDigit()
                    .foregroundStyle(Color.mtText)
            }
        }
        .frame(width: size, height: size)
    }
}
