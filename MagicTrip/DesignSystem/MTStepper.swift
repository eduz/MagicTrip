import SwiftUI

struct MTStepper: View {
    @Binding var value: Int
    var min: Int = 0
    var max: Int = 99

    var body: some View {
        HStack(spacing: 0) {
            Button {
                if value > min { value -= 1 }
            } label: {
                Text("−")
                    .mtFont(22)
                    .foregroundStyle(value <= min ? Color.mtText3 : Color.mtText)
                    .frame(width: 38, height: 32)
            }
            .buttonStyle(.plain)
            .disabled(value <= min)

            Divider().frame(height: 18)

            Text("\(value)")
                .mtFont(15, weight: .semibold).monospacedDigit()
                .frame(minWidth: 30)
                .multilineTextAlignment(.center)

            Divider().frame(height: 18)

            Button {
                if value < max { value += 1 }
            } label: {
                Text("+")
                    .mtFont(22)
                    .foregroundStyle(value >= max ? Color.mtText3 : Color.mtText)
                    .frame(width: 38, height: 32)
            }
            .buttonStyle(.plain)
            .disabled(value >= max)
        }
        .background(Color.mtBg2)
        .cornerRadius(10)
        .frame(height: 32)
    }
}
