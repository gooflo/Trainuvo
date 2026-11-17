import SwiftUI
import SwiftData

struct ExerciseOrderEditor: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: [SortDescriptor(\Exercise.sortOrder), SortDescriptor(\Exercise.name)])
    private var exercises: [Exercise]
    @State private var orderedIDs: [UUID]
    @State private var errorMessage: String?

    init(exercises: [Exercise]) {
        _orderedIDs = State(initialValue: exercises.map(\.id))
    }

    private var orderedExercises: [Exercise] {
        let byID = Dictionary(uniqueKeysWithValues: exercises.map { ($0.id, $0) })
        let ordered = orderedIDs.compactMap { byID[$0] }
        let knownIDs = Set(orderedIDs)
        return ordered + exercises.filter { !knownIDs.contains($0.id) }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(orderedExercises) { exercise in
                    Text(exercise.name)
                }
                .onMove { offsets, destination in
                    var ids = orderedExercises.map(\.id)
                    ids.move(fromOffsets: offsets, toOffset: destination)
                    orderedIDs = ids
                }
            }
            .environment(\.editMode, .constant(.active))
            .navigationTitle("Übungen sortieren")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") { save() }
                }
            }
            .alert("Speichern fehlgeschlagen", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK") { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    private func save() {
        for (position, exercise) in orderedExercises.enumerated() {
            exercise.sortOrder = position
        }
        do {
            try modelContext.save()
            dismiss()
        } catch {
            modelContext.rollback()
            errorMessage = error.localizedDescription
        }
    }
}
