import SwiftUI
import SwiftData

@main
struct TrainuvoApp: App {
    private let container: ModelContainer?
    private let startupError: String?

    init() {
        do {
            // Keep Item so data from the Xcode starter app remains readable.
            let schema = Schema([Item.self, Exercise.self, TrainingEntry.self, SetGroup.self, ExerciseSetTemplate.self])
            let configuration = ModelConfiguration(
                schema: schema, isStoredInMemoryOnly: false, cloudKitDatabase: .none
            )
            container = try ModelContainer(for: schema, configurations: [configuration])
            startupError = nil
        } catch {
            container = nil
            startupError = error.localizedDescription
        }
    }

    var body: some Scene {
        WindowGroup {
            if let container {
                ContentView()
                    .modelContainer(container)
            } else {
                ContentUnavailableView {
                    Label("Daten konnten nicht geöffnet werden", systemImage: "externaldrive.badge.exclamationmark")
                } description: {
                    Text(startupError ?? "Bitte starte Trainuvo erneut.")
                }
            }
        }
    }
}
