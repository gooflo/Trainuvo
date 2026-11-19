import SwiftUI
import SwiftData

struct TrainingDayNoteEditor: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    let date: Date
    @Query private var notes: [TrainingDayNote]
    @State private var text = ""
    @State private var loaded = false
    @State private var confirmingDelete = false
    @State private var error: String?
    @FocusState private var focused: Bool

    private var existing: [TrainingDayNote] {
        notes.filter { $0.dayKey == TrainingDayNote.key(for: date) }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text(date, format: .dateTime.day().month(.wide).year())
                    TextField("Kommentar zu diesem Trainingstag", text: $text, axis: .vertical)
                        .lineLimit(5...12)
                        .focused($focused)
                }
                if !existing.isEmpty {
                    Section {
                        Button("Kommentar löschen", role: .destructive) { confirmingDelete = true }
                    }
                }
            }
            .navigationTitle("Tageskommentar")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Abbrechen") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("Speichern") { save(text) }.disabled(!loaded) }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Fertig") { focused = false }
                }
            }
            .onAppear {
                guard !loaded else { return }
                text = TrainingDayNote.combined(existing)
                loaded = true
            }
            .confirmationDialog("Kommentar löschen?", isPresented: $confirmingDelete, titleVisibility: .visible) {
                Button("Kommentar löschen", role: .destructive) { save("") }
                Button("Abbrechen", role: .cancel) {}
            } message: { Text("Die Trainings dieses Tages bleiben erhalten.") }
            .alert("Speichern fehlgeschlagen", isPresented: Binding(get: { error != nil }, set: { if !$0 { error = nil } })) {
                Button("OK") { error = nil }
            } message: { Text(error ?? "") }
        }
    }

    private func save(_ value: String) {
        do {
            try TrainingDayNote.save(text: value, date: date, in: context)
            dismiss()
        } catch { self.error = error.localizedDescription }
    }
}
