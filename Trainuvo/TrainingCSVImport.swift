import Foundation
import SwiftData

@MainActor
enum TrainingCSVImport {
    enum Destination: Hashable {
        case unassigned
        case existing(UUID)
        case create(String)
    }
    enum Status: Equatable {
        case new, duplicate, conflict, unassigned
        var title: String {
            switch self {
            case .new: "Neues Training"
            case .duplicate: "Identisch vorhanden – wird übersprungen"
            case .conflict: "Abweichendes oder weiteres Training – bitte prüfen"
            case .unassigned: "Übung zuerst zuordnen"
            }
        }
    }
    struct PreviewRow: Identifiable {
        let training: TrainingCSV.Training
        let status: Status
        var id: Int { training.id }
    }
    struct Result { let imported: Int; let duplicates: Int; let omitted: Int; let exercisesCreated: Int }
    private struct Signature: Hashable {
        let destination: Destination
        let day: Date
        let groups: [TrainingCSV.Group]
        let effort: String?
    }
    private struct Day: Hashable { let destination: Destination; let date: Date }

    static func nameKey(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines).folding(options: [.caseInsensitive], locale: Locale(identifier: "de_DE"))
    }

    static func initialDestinations(_ document: TrainingCSV.Document, exercises: [Exercise], fixedExerciseID: UUID?) -> [String: Destination] {
        var result: [String: Destination] = [:]
        for training in document.trainings {
            let name = training.exerciseName ?? ""
            if let fixedExerciseID { result[name] = .existing(fixedExerciseID) }
            else {
                let matches = exercises.filter { $0.activityType == .strength && nameKey($0.name) == nameKey(name) }
                result[name] = matches.count == 1 ? .existing(matches[0].id) : .unassigned
            }
        }
        return result
    }

    static func preview(_ document: TrainingCSV.Document, destinations: [String: Destination],
                        exercises: [Exercise], calendar: Calendar = .current) -> [PreviewRow] {
        var signatures = Set<Signature>()
        var occupiedDays = Set<Day>()
        var byID: [UUID: (Signature, Bool)] = [:]
        for exercise in exercises {
            let destination = Destination.existing(exercise.id)
            for entry in exercise.trainingEntries {
                let day = calendar.startOfDay(for: entry.date)
                occupiedDays.insert(Day(destination: destination, date: day))
                let groups = entry.sortedGroups.map {
                    TrainingCSV.Group(prescription: TrainingCSV.normalizedPrescription($0.prescription), weight: $0.weight, isWorking: $0.isWorking)
                }
                let signature = Signature(destination: destination, day: day, groups: groups, effort: entry.effort?.symbol)
                if entry.activityType == .strength { signatures.insert(signature) }
                byID[entry.id] = (signature, entry.activityType == .strength)
            }
        }
        return document.trainings.map { training in
            var destination = destinations[training.exerciseName ?? ""] ?? .unassigned
            if case .create(let name) = destination { destination = .create(nameKey(name)) }
            guard destination != .unassigned else { return PreviewRow(training: training, status: .unassigned) }
            let day = calendar.startOfDay(for: training.date)
            let signature = Signature(destination: destination, day: day, groups: training.groups, effort: training.effortSymbol)
            let sourceUUID = training.sourceID.flatMap(UUID.init(uuidString:))
            let status: Status
            if let sourceUUID, let existing = byID[sourceUUID] {
                status = existing.1 && existing.0 == signature ? .duplicate : .conflict
            } else if sourceUUID == nil && signatures.contains(signature) {
                status = .duplicate
            } else {
                status = occupiedDays.contains(Day(destination: destination, date: day)) ? .conflict : .new
            }
            // UUIDs distinguish legitimate identical trainings; non-UUID source IDs use content matching.
            signatures.insert(signature)
            occupiedDays.insert(Day(destination: destination, date: day))
            return PreviewRow(training: training, status: status)
        }
    }

    static func save(_ document: TrainingCSV.Document, selected: Set<Int>, approvedConflicts: Set<Int>,
                     destinations: [String: Destination], fixedExerciseID: UUID? = nil, allowNameMismatch: Bool = false,
                     container: ModelContainer, calendar: Calendar = .current) throws -> Result {
        guard document.issues.isEmpty, !selected.isEmpty else {
            throw TrainingCSV.CSVError.message("Bitte Dateifehler korrigieren und Trainings auswählen.")
        }
        let context = ModelContext(container)
        context.autosaveEnabled = false
        var exercises = try context.fetch(FetchDescriptor<Exercise>())
        if let fixedExerciseID {
            guard let fixed = exercises.first(where: { $0.id == fixedExerciseID }), fixed.activityType == .strength else {
                throw TrainingCSV.CSVError.message("Die Kraftübung ist nicht mehr verfügbar.")
            }
            let names = Set(document.trainings.compactMap(\.exerciseName))
            guard names.count <= 1 else { throw TrainingCSV.CSVError.message("Diese Datei enthält mehrere Übungen. Bitte den Gesamtimport in Einstellungen verwenden.") }
            guard destinations.values.allSatisfy({ $0 == .existing(fixedExerciseID) }) else {
                throw TrainingCSV.CSVError.message("Die Zuordnung zur geöffneten Übung wurde verändert.")
            }
            guard allowNameMismatch || names.allSatisfy({ nameKey($0) == nameKey(fixed.name) }) else {
                throw TrainingCSV.CSVError.message("Den abweichenden Übungsnamen bitte ausdrücklich bestätigen.")
            }
        }
        let current = preview(document, destinations: destinations, exercises: exercises, calendar: calendar)
        guard !current.contains(where: { selected.contains($0.id) && ($0.status == .unassigned || ($0.status == .conflict && !approvedConflicts.contains($0.id))) }) else {
            throw TrainingCSV.CSVError.message("Übungszuordnung oder Trainings haben sich geändert. Bitte Vorschau aktualisieren und erneut prüfen.")
        }
        let toInsert = current.filter { selected.contains($0.id) && $0.status != .duplicate }
        var idsInUse = Set(try context.fetch(FetchDescriptor<TrainingEntry>()).map(\.id))
        var created: [String: Exercise] = [:]
        var imported = 0
        do {
            for item in toInsert {
                let training = item.training
                let destination = destinations[training.exerciseName ?? ""] ?? .unassigned
                let exercise: Exercise
                switch destination {
                case .existing(let id):
                    guard let found = exercises.first(where: { $0.id == id }), found.activityType == .strength else {
                        throw TrainingCSV.CSVError.message("Eine zugeordnete Kraftübung ist nicht mehr verfügbar.")
                    }
                    exercise = found
                case .create(let name):
                    let key = nameKey(name)
                    if let found = created[key] { exercise = found }
                    else {
                        guard !key.isEmpty, !exercises.contains(where: { $0.activityType == .strength && nameKey($0.name) == key }) else {
                            throw TrainingCSV.CSVError.message("Eine gleichnamige Kraftübung ist inzwischen vorhanden. Bitte Vorschau aktualisieren und zuordnen.")
                        }
                        exercise = Exercise(name: name, targetWeight: nil)
                        exercise.sortOrder = (exercises.map(\.sortOrder).max() ?? -1) + 1
                        context.insert(exercise)
                        exercises.append(exercise); created[key] = exercise
                    }
                case .unassigned: throw TrainingCSV.CSVError.message("Übungszuordnung fehlt.")
                }
                let entry = TrainingEntry(date: training.date, exercise: exercise)
                if let sourceID = training.sourceID.flatMap(UUID.init(uuidString:)), !idsInUse.contains(sourceID) { entry.id = sourceID }
                idsInUse.insert(entry.id)
                entry.effort = TrainingEffort.allCases.first { $0.symbol == training.effortSymbol }
                context.insert(entry)
                for (position, group) in training.groups.enumerated() {
                    let set = SetGroup(position: position, prescription: group.prescription, weight: group.weight, isWorking: group.isWorking)
                    context.insert(set); entry.setGroups.append(set)
                }
                imported += 1
            }
            try context.save()
            return Result(imported: imported, duplicates: current.filter { $0.status == .duplicate }.count,
                          omitted: current.filter { $0.status != .duplicate && !selected.contains($0.id) }.count,
                          exercisesCreated: created.count)
        } catch { context.rollback(); throw error }
    }
}
