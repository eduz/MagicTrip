import SwiftUI

struct SeasonalityComparator: View {
    let data: [SeasonalityData]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(data) { month in
                    MonthCard(month: month)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
}

private struct MonthCard: View {
    let month: SeasonalityData

    var body: some View {
        VStack(spacing: 6) {
            Text(month.name)
                .mtFont(12, weight: .bold)
                .foregroundStyle(Color.mtText3)

            crowdDots(count: month.crowdCount)

            VStack(spacing: 2) {
                Text(month.priceLabel)
                    .mtFont(11, weight: .semibold)
                    .foregroundStyle(priceColor(month.priceLevel))
                Text(month.crowdLabel)
                    .mtFont(10)
                    .foregroundStyle(Color.mtText3)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .frame(width: 76)
        .background(Color.mtCard)
        .cornerRadius(12)
        .mtCardShadow()
    }

    @ViewBuilder
    private func crowdDots(count: Int) -> some View {
        HStack(spacing: 3) {
            ForEach(0..<5) { i in
                Circle()
                    .fill(i < count ? Color.mtPrimary : Color.mtBorder)
                    .frame(width: 7, height: 7)
            }
        }
    }

    private func priceColor(_ level: PriceLevel) -> Color {
        switch level {
        case .low:    return Color.mtSuccess
        case .medium: return Color.mtAmber
        case .high:   return Color.mtDanger
        }
    }
}
