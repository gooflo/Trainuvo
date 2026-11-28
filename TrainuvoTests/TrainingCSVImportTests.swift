import Foundation
import SwiftData
import Testing
@testable import Trainuvo

@MainActor
struct TrainingCSVImportTests {
    private let header = "Datum;Sätze;Gewicht;Bewertung\n"

    private var calendar: Calendar {
        var value = Calendar(identifier: .gregorian)
        value.timeZone = TimeZone(identifier: "Europe/Berlin")!
        return value
    }

    @Test func parsesBOMQuotesDecimalsAndAllEfforts() throws {
        let text = "\u{FEFF}Datum;Sätze;Gewicht;Bewertung\r\n" +
            "18.11.2026;\"3x5\";\"52,5\";--\r\n" +
            "17.11.2026;1 × 5;52.5;-\r\n" +
            "16.11.2026;3X5;50;o\r\n" +
            "15.11.2026;5/5/4;48;+\r\n" +
            "14.11.2026;1x5;46;++\r\n" +
            "13.11.2026;1x5;0;\r\n\r\n"
        let document = try TrainingCSV.parse(text, calendar: calendar)
        #expect(document.issues.isEmpty)
        #expect(document.rows.count == 6)
        #expect(document.rows[0].weight == 52.5)
        #expect(document.rows[0].prescription == "3 × 5")
        #expect(document.rows[2].prescription == "3 × 5")
        #expect(document.rows[3].prescription == "5/5/4")
        #expect(document.rows.map(\.effortSymbol) == ["--", "-", "o", "+", "++", nil])
        #expect(calendar.component(.hour, from: document.rows[0].date) == 12)
        #expect(calendar.component(.day, from: document.rows[0].date) == 18)
    }

    @Test func quotedSemicolonsAndEscapedQuotes() throws {
        let document = try TrainingCSV.parse(header + "18.11.2026;\"5;5;\"\"4\"\"\";50;o")
        #expect(document.issues.isEmpty)
        #expect(document.rows.first?.prescription == "5;5;\"4\"")
    }

    @Test func rejectsInvalidDatesNumbersAndRatingsWithLineNumbers() throws {
        let rows = [
            "31.02.2026;3x5;50;o", "29.02.2025;3x5;50;o", "1.11.2026;3x5;50;o",
            "18.11.2026;;50;o", "18.11.2026;3x5;-2;o", "18.11.2026;3x5;NaN;o",
            "18.11.2026;3x5;inf;o", "18.11.2026;3x5;100001;o",
            "18.11.2026;3x5;1,2.3;o", "18.11.2026;3x5;50;ok+",
            "18.11.2026;3x5;50", "18.11.2026;\"3x5;50;o"
        ]
        let document = try TrainingCSV.parse(header + rows.joined(separator: "\n"))
        #expect(document.rows.isEmpty)
        #expect(document.issues.map(\.line) == Array(2...(rows.count + 1)))
        #expect(try TrainingCSV.parse(header + "29.02.2024;3x5;50;o").issues.isEmpty)
    }

    @Test func rejectsWrongHeaderEmptyOrOversizedFilesAndDecodesUTF16() throws {
        for text in ["", header, "Datum,Sätze,Gewicht,Bewertung\n18.11.2026,3x5,50,o",
                     String(repeating: "x", count: TrainingCSV.maximumBytes + 1)] {
            #expect(throws: TrainingCSV.CSVError.self) { try TrainingCSV.parse(text) }
        }
        let tooMany = header + String(repeating: "18.11.2026;3x5;50;o\n", count: TrainingCSV.maximumRows + 1)
        #expect(throws: TrainingCSV.CSVError.self) { try TrainingCSV.parse(tooMany) }
        #expect(throws: TrainingCSV.CSVError.self) { try TrainingCSV.decode(Data([0xFF])) }
        let utf16 = try #require((header + "18.11.2026;3x5;50;o").data(using: .utf16))
        #expect(try TrainingCSV.parse(TrainingCSV.decode(utf16)).rows.count == 1)
    }

    @Test func previewDetectsWarmupDuplicateAndSameDayConflictWithoutWriting() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        let exercise = Exercise(name: "Testübung", targetWeight: 100)
        context.insert(exercise)
        let document = try TrainingCSV.parse(header +
            "18.11.2026;3x5;60;o\n18.11.2026;3x5;62;+\n17.11.2026;1x5;58;\n17.11.2026;1 × 5;58;", calendar: calendar)
        let entry = TrainingEntry(date: document.rows[0].date, exercise: exercise)
        entry.effort = .okay
        context.insert(entry)
        for (position, weight) in [20.0, 60.0].enumerated() {
            let group = SetGroup(position: position, prescription: position == 0 ? "1x5" : "3 × 5",
                                 weight: weight, isWorking: position == 1)
            context.insert(group)
            entry.setGroups.append(group)
        }
        try context.save()
        let preview = TrainingCSVImport.preview(document.rows, entries: exercise.trainingEntries, calendar: calendar)
        #expect(preview.map(\.status) == [.duplicate, .conflict, .new, .duplicate])
        #expect(try context.fetchCount(FetchDescriptor<TrainingEntry>()) == 1)
        #expect(exercise.progress == 0.6)
    }

    @Test func importsPersistentlyAndRepeatImportIsIdempotent() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        let exercise = Exercise(name: "Testübung", targetWeight: 100)
        let other = Exercise(name: "Andere Kraftübung", targetWeight: 200)
        let template = ExerciseSetTemplate(position: 0, prescription: "5 × 3", isWorking: true)
        context.insert(exercise); context.insert(other); context.insert(template)
        exercise.templates.append(template)
        let note = TrainingDayNote(date: Date(), text: "Testnotiz")
        context.insert(note)
        try context.save()
        let document = try TrainingCSV.parse(header + "18.11.2026;3x5;60;+\n17.11.2026;1x5;58;", calendar: calendar)
        let result = try TrainingCSVImport.save(document, selected: Set(document.rows.map(\.id)),
            approvedConflicts: [], exerciseID: exercise.id, container: container, calendar: calendar)
        #expect(result.imported == 2)
        let check = ModelContext(container)
        let saved = try #require(check.fetch(FetchDescriptor<Exercise>()).first { $0.id == exercise.id })
        #expect(saved.trainingEntries.count == 2)
        #expect(saved.latestEntry?.effort == .easy)
        #expect(saved.latestEntry?.workingWeight == 60)
        #expect(saved.latestEntry?.setGroups.count == 1)
        #expect(saved.latestEntry?.workingGroup?.completedSets.isEmpty == true)
        #expect(saved.progress == 0.6)
        #expect(saved.targetWeight == 100)
        #expect(saved.templates.first?.id == template.id)
        #expect(try check.fetchCount(FetchDescriptor<TrainingDayNote>()) == 1)
        #expect(try check.fetch(FetchDescriptor<Exercise>()).first { $0.id == other.id }?.trainingEntries.isEmpty == true)
        let repeated = try TrainingCSVImport.save(document, selected: Set(document.rows.map(\.id)),
            approvedConflicts: [], exerciseID: exercise.id, container: container, calendar: calendar)
        #expect(repeated.imported == 0)
        #expect(repeated.duplicates == 2)
        #expect(try ModelContext(container).fetchCount(FetchDescriptor<TrainingEntry>()) == 2)
    }

    @Test func conflictsRequireApprovalAndInvalidDocumentsWriteNothing() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        let exercise = Exercise(name: "Testübung", targetWeight: 100)
        context.insert(exercise); try context.save()
        let initial = try TrainingCSV.parse(header + "18.11.2026;3x5;60;o", calendar: calendar)
        _ = try TrainingCSVImport.save(initial, selected: [2], approvedConflicts: [],
            exerciseID: exercise.id, container: container, calendar: calendar)
        let changed = try TrainingCSV.parse(header + "17.11.2026;3x5;58;o\n18.11.2026;3x5;62;+", calendar: calendar)
        #expect(throws: TrainingCSV.CSVError.self) {
            try TrainingCSVImport.save(changed, selected: [2, 3], approvedConflicts: [],
                exerciseID: exercise.id, container: container, calendar: calendar)
        }
        #expect(try ModelContext(container).fetchCount(FetchDescriptor<TrainingEntry>()) == 1)
        let approved = try TrainingCSVImport.save(changed, selected: [3], approvedConflicts: [3],
            exerciseID: exercise.id, container: container, calendar: calendar)
        #expect(approved.imported == 1)
        #expect(approved.omitted == 1)
        let invalid = try TrainingCSV.parse(header + "16.11.2026;3x5;50;o\n31.02.2026;3x5;50;o")
        #expect(throws: TrainingCSV.CSVError.self) {
            try TrainingCSVImport.save(invalid, selected: [2], approvedConflicts: [],
                exerciseID: exercise.id, container: container)
        }
        #expect(try ModelContext(container).fetchCount(FetchDescriptor<TrainingEntry>()) == 2)
    }

    @Test func rejectsOtherExerciseTypesAndPreservesUnrelatedUnsavedEdits() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        context.autosaveEnabled = false
        let strength = Exercise(name: "Kraftübung", targetWeight: 100)
        let sets = Exercise(name: "Satzübung", targetWeight: nil, activityType: .sets)
        context.insert(strength); context.insert(sets); try context.save()
        strength.name = "Noch nicht gespeichert"
        let document = try TrainingCSV.parse(header + "18.11.2026;3x5;60;o")
        #expect(throws: TrainingCSV.CSVError.self) {
            try TrainingCSVImport.save(document, selected: [2], approvedConflicts: [],
                exerciseID: sets.id, container: container)
        }
        _ = try TrainingCSVImport.save(document, selected: [2], approvedConflicts: [],
            exerciseID: strength.id, container: container)
        let persisted = try #require(ModelContext(container).fetch(FetchDescriptor<Exercise>()).first { $0.id == strength.id })
        #expect(persisted.name == "Kraftübung")
        #expect(strength.name == "Noch nicht gespeichert")
    }

    private func makeContainer() throws -> ModelContainer {
        let schema = Schema(versionedSchema: TrainuvoSchemaV4.self)
        return try ModelContainer(for: schema, configurations: [
            ModelConfiguration(schema: schema, isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        ])
    }
}
