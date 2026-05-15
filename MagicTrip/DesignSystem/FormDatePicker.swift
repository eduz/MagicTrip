import SwiftUI

private let dateFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "dd/MM/yyyy"
    return f
}()

/// DatePicker compacto com formato de data fixo (dd/MM/yyyy).
/// O DatePicker nativo no modo compacto pode alternar entre formatos
/// dependendo do espaço disponível; este componente corrige essa inconsistência.
struct FormDatePicker: View {
    @Binding var selection: Date
    var range: PartialRangeFrom<Date>?

    init(selection: Binding<Date>) {
        self._selection = selection
        self.range = nil
    }

    init(selection: Binding<Date>, in range: PartialRangeFrom<Date>) {
        self._selection = selection
        self.range = range
    }

    var body: some View {
        Text(dateFormatter.string(from: selection))
            .mtFont(16)
            .foregroundStyle(Color.mtPrimary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.mtCard)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay {
                if let range {
                    DatePicker("", selection: $selection, in: range, displayedComponents: .date)
                        .labelsHidden()
                        .blendMode(.destinationOver)
                } else {
                    DatePicker("", selection: $selection, displayedComponents: .date)
                        .labelsHidden()
                        .blendMode(.destinationOver)
                }
            }
    }
}
