import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var activeAlert: SettingsAlert?

    var body: some View {
        NavigationStack {
            Form {
                CloudSyncInfoView()
                Section {
                    NavigationLink {
                        BodyweightGoalCalculatorView()
                    } label: {
                        Label("Zielgewichte berechnen", systemImage: "calculator")
                    }
                }
                Section {
                    Button("Beispieldaten anlegen", systemImage: "dumbbell") { createExamples() }
                } footer: {
                    Text("Vier Übungen mit Standardsätzen und Trainings vom 14. und 17.11.2026. Gleichnamige Übungen werden wiederverwendet, fehlende Beispieltrainings ergänzt.")
                }
                Section {
                    Button("Alles löschen", systemImage: "trash", role: .destructive) {
                        activeAlert = .confirmDelete
                    }
                } footer: {
                    Text("Löscht alle Übungen, Trainings, Standardsätze und Tageskommentare auf diesem Gerät und nach iCloud-Abgleich auf deinen anderen Geräten nach Bestätigung.")
                }
            }
            .navigationTitle("Einstellungen")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fertig") { dismiss() }
                }
            }
            .alert(activeAlert?.title ?? "", isPresented: Binding(
                get: { activeAlert != nil },
                set: { if !$0 { activeAlert = nil } }
            ), presenting: activeAlert) { alert in
                switch alert {
                case .confirmDelete:
                    Button("Abbrechen", role: .cancel) {}
                    Button("Alles endgültig löschen", role: .destructive) { deleteAll() }
                case .result, .error:
                    Button("OK", role: .cancel) {}
                }
            } message: { alert in
                Text(alert.message)
            }
        }
    }

    private enum SettingsAlert {
        case confirmDelete
        case result(String)
        case error(String)

        var title: String {
            switch self {
            case .confirmDelete: "Alle Daten löschen?"
            case .result: "Fertig"
            case .error: "Aktion fehlgeschlagen"
            }
        }

        var message: String {
            switch self {
            case .confirmDelete: "Alle Übungen, Trainings, Standardsätze und Tageskommentare werden dauerhaft gelöscht, auch auf deinen anderen synchronisierten Geräten."
            case .result(let message), .error(let message): message
            }
        }
    }

    private func createExamples() {
        do {
            let result = try TrainingDataOperations.createExamples(in: modelContext)
            activeAlert = .result("\(result.exercisesCreated) Übungen und \(result.trainingsCreated) Beispieltrainings angelegt.")
        } catch {
            activeAlert = .error(error.localizedDescription)
        }
    }

    private func deleteAll() {
        do {
            try TrainingDataOperations.deleteAll(in: modelContext)
        } catch {
            activeAlert = .error(error.localizedDescription)
        }
    }
}
