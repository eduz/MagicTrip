import SwiftUI

struct DayNoteEditor: View {
    let day: TripDay
    var onClose: () -> Void

    @State private var noteText: String = ""
    private let maxChars = 280

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                TextEditor(text: $noteText)
                    .mtFont(16)
                    .lineSpacing(4)
                    .padding(12)
                    .background(Color.mtCard)
                    .cornerRadius(14)
                    .frame(minHeight: 140)
                    .mtKeyboardDoneToolbar()
                    .onChange(of: noteText) {
                        if noteText.count > maxChars {
                            noteText = String(noteText.prefix(maxChars))
                        }
                    }

                Text("\(noteText.count)/\(maxChars)")
                    .mtFont(12)
                    .foregroundStyle(noteText.count >= maxChars ? Color.mtDanger : Color.mtText3)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(16)
            .background(Color.mtBg)
            .navigationTitle(day.date.tripDayFormatted)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(String(localized: "Cancelar"), action: onClose)
                        .foregroundStyle(Color.mtText2)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(String(localized: "Salvar")) {
                        day.note = noteText.isEmpty ? nil : noteText
                        onClose()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.mtPrimary)
                }
            }
        }
        .onAppear { noteText = day.note ?? "" }
    }
}
