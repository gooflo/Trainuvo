import Foundation
import SwiftData

@MainActor
enum TrainingCSVImport {
    enum Status: Equatable {
        case new, duplicate, conflict

        var title: String {
            switch self {
            case .new: "Neues Training"
            case .duplicate: "Identisch vorhanden – wird übersprungen"
            case .conflict: "Weiteres Training am selben Tag – bitte prüfen"
            }
        }
    }

    struct PreviewRow: Identifiable {
        let row: TrainingCSV.Row
        let status: Status
        var id: Int { row.id }
    }

    struct Result {
        let imported: Int
        let duplicates: Int
        let omitted: Int
    }

    private struct Signature: Hashable {
        let day: Date
        let prescription: String
        let weight: Double
        let effort: String?
    }

    static func preview(_ rows: [TrainingCSV.Row], entries: [TrainingEntry], calendar: Calendar = .current) -> [PreviewRow] {
        var occupiedDays = Set(entries.map { calendar.startOfDay(for: $0.date) })
        var signatures = Set(entries.compactMap { entry -> Signature? in
            guard entry.activityType == .strength, let group = entry.workingGroup else { return nil }
            // Match the working group even when the existing training also has warm-up groups.
            return Signature(day: calendar.startOfDay(for: entry.date),
                             prescription: TrainingCSV.normalizedPrescription(group.prescription),
                             weight: group.weight, effort: entry.effort?.symbol)
        })
        return rows.map { row in
            let day = calendar.startOfDay(for: row.date)
            let signature = Signature(day: day, prescription: row.prescription, weight: row.weight, effort: row.effortSymbol)
            let status: Status = signatures.contains(signature) ? .duplicate : (occupiedDays.contains(day) ? .conflict : .new)
            signatures.insert(signature)
            occupiedDays.insert(day)
            return PreviewRow(row: row, status: status)
        }
    }

    /// A separate context keeps cancellation/failures from saving or rolling back unrelated UI edits.
    static func save(_ document: TrainingCSV.Document, selected: Set<Int>, approvedConflicts: Set<Int>,
                     exerciseID: UUID, container: ModelContainer, calendar: Calendar = .current) throws -> Result {
        guard document.issues.isEmpty, !selected.isEmpty else {
            throw TrainingCSV.CSVError.message("Bitte zuerst alle Dateifehler korrigieren und mindestens ein Training auswählen.")
        }
        let context = ModelContext(container)
        context.autosaveEnabled = false
        var descriptor = FetchDescriptor<Exercise>(predicate: #Predicate { $0.id == exerciseID })
        descriptor.fetchLimit = 1
        guard let exercise = try context.fetch(descriptor).first, exercise.activityType == .strength else {
            throw TrainingCSV.CSVError.message("Die Kraftübung ist nicht mehr verfügbar. Bitte den Import neu öffnen.")
        }
        let current = preview(document.rows, entries: exercise.trainingEntries, calendar: calendar)
        // Check every selection before inserting anything; an iCloud change may have added a conflict.
        guard !current.contains(where: { selected.contains($0.id) && $0.status == .conflict && !approvedConflicts.contains($0.id) }) else {
            throw TrainingCSV.CSVError.message("Die Trainings haben sich seit der Vorschau geändert. Wähle die Datei erneut und prüfe die Vorschau.")
        }
        let toInsert = current.filter { selected.contains($0.id) && $0.status != .duplicate }
        var imported = 0
        do {
            for item in toInsert {
                let row = item.row
                let entry = TrainingEntry(date: row.date, exercise: exercise)
                entry.effort = TrainingEffort.allCases.first { $0.symbol == row.effortSymbol }
                context.insert(entry)
                let group = SetGroup(position: 0, prescription: row.prescription, weight: row.weight, isWorking: true)
                context.insert(group)
                entry.setGroups.append(group)
                imported += 1
            }
            try context.save()
            return Result(imported: imported, duplicates: current.filter { $0.status == .duplicate }.count,
                          omitted: current.filter { $0.status != .duplicate && !selected.contains($0.id) }.count)
        } catch {
            context.rollback()
            throw error
        }
    }
}
