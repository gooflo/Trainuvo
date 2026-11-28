import Foundation
import SwiftData
import Testing
@testable import Trainuvo

@MainActor
struct TrainingCSVImportTests {
    private var calendar: Calendar {
        var value = Calendar(identifier: .gregorian)
        value.timeZone = TimeZone(identifier: "Europe/Berlin")!
        return value
    }
    private let header = TrainingCSV.header + "\n"
    private let legacy = TrainingCSV.legacyHeader + "\n"

    @Test func parsesLegacyAndCompleteTrainingsWithZeroWarmups() throws {
        let old = try TrainingCSV.parse("\u{FEFF}" + legacy + "18.11.2026;3X5;52,5;++\r\n")
        #expect(old.isLegacy)
        #expect(old.trainings.count == 1)
        #expect(old.trainings[0].groups == [TrainingCSV.Group(prescription: "3 × 5", weight: 52.5, isWorking: true)])
        let full = try TrainingCSV.parse(header +
            "a;Testübung;18.11.2026;3;3x5;90;ja;o\n" +
            "a;Testübung;18.11.2026;1;1x5;0;nein;o\n" +
            "a;Testübung;18.11.2026;2;1x5;52;nein;o", calendar: calendar)
        #expect(full.issues.isEmpty)
        #expect(full.trainings.count == 1)
        #expect(full.trainings[0].groups.map(\.weight) == [0, 52, 90])
        #expect(full.trainings[0].groups.map(\.isWorking) == [false, false, true])
        #expect(calendar.component(.hour, from: full.trainings[0].date) == 12)
    }

    @Test func handlesQuotedMultilineFieldsBOMAndUTF16() throws {
        let text = "\u{FEFF}" + header + "a;\"Test; \"\"Name\"\"\";18.11.2026;1;\"5/5\n/4\";52.5;ja;--\r\n"
        let parsed = try TrainingCSV.parse(text)
        #expect(parsed.issues.isEmpty)
        #expect(parsed.trainings[0].exerciseName == "Test; \"Name\"")
        #expect(parsed.trainings[0].groups[0].prescription == "5/5\n/4")
        let encoded = try #require(text.data(using: .utf16))
        #expect(try TrainingCSV.parse(TrainingCSV.decode(encoded)).trainings.count == 1)
        #expect(throws: TrainingCSV.CSVError.self) { try TrainingCSV.parse(header + "\"unfinished") }
    }

    @Test func weightSerializationKeepsSmallValues() throws {
        for weight in [0.0, 52.5, 100000, 0.0000001, 1e-200] {
            let text = TrainingCSV.weightText(weight)
            #expect(!text.contains("e"))
            #expect(Double(text) == weight)
            let document = try TrainingCSV.parse(legacy + "18.11.2026;3x5;\(text);o")
            #expect(document.issues.isEmpty)
        }
    }

    @Test func validatesGroupingDatesWeightsAndRatings() throws {
        let badGroups = [
            "a;Test;18.11.2026;2;3x5;60;ja;o", // gap
            "a;Test;18.11.2026;1;3x5;60;nein;o", // no working group
            "a;Test;18.11.2026;1;3x5;60;ja;o\na;Test;18.11.2026;1;1x5;20;ja;o", // duplicate order/two working groups
            "a;Test;18.11.2026;1;1x5;20;nein;o\na;Other;18.11.2026;2;3x5;60;ja;o",
            "a;Test;18.11.2026;1;1x5;20;nein;o\na;Test;17.11.2026;2;3x5;60;ja;o",
            "a;Test;18.11.2026;1;1x5;20;nein;o\na;Test;18.11.2026;2;3x5;60;ja;+"
        ]
        for rows in badGroups { #expect(try !TrainingCSV.parse(header + rows).issues.isEmpty) }
        for row in ["31.02.2026;3x5;60;o", "29.02.2025;3x5;60;o", "1.11.2026;3x5;60;o",
                    "18.11.2026;3x5;-1;o", "18.11.2026;3x5;NaN;o", "18.11.2026;3x5;100001;o",
                    "18.11.2026;3x5;1,2.3;o", "18.11.2026;3x5;60;ok+"] {
            #expect(try !TrainingCSV.parse(legacy + row).issues.isEmpty)
        }
        #expect(try TrainingCSV.parse(legacy + "29.02.2024;3x5;60;o").issues.isEmpty)
        #expect(throws: TrainingCSV.CSVError.self) { try TrainingCSV.parse("") }
        #expect(throws: TrainingCSV.CSVError.self) { try TrainingCSV.parse(header) }
        #expect(throws: TrainingCSV.CSVError.self) { try TrainingCSV.parse(String(repeating: "x", count: TrainingCSV.maximumBytes + 1)) }
    }

    @Test func completeRoundTripPreservesTrainingIDsGroupsRatingsAndDifferentExercises() throws {
        let source = try container()
        let context = ModelContext(source)
        let press = Exercise(name: "Test Press", targetWeight: 80)
        let squat = Exercise(name: "Test Kniebeuge", targetWeight: 100)
        press.hiddenFromHome = true
        context.insert(press); context.insert(squat)
        let date = try #require(calendar.date(from: DateComponents(year: 2026, month: 11, day: 18, hour: 16)))
        let first = addTraining(to: press, date: date, weights: [0, 40, 52.5], context: context)
        first.effort = .veryEasy
        let second = addTraining(to: squat, date: date.addingTimeInterval(-86400), weights: [0, 52, 90], context: context)
        second.effort = .hard
        // Two truly identical trainings can exist and have distinct UUIDs.
        let third = addTraining(to: press, date: date, weights: [0, 40, 52.5], context: context)
        third.effort = .veryEasy
        try context.save()
        let text = try TrainingCSVExport.text([second, third, first], calendar: calendar)
        let document = try TrainingCSV.parse(text, calendar: calendar)
        #expect(document.issues.isEmpty)
        #expect(document.trainings.count == 3)
        #expect(document.rows.count == 9)
        #expect(document.trainings.first?.date == calendar.date(bySettingHour: 12, minute: 0, second: 0, of: date))
        let target = try container()
        let routes: [String: TrainingCSVImport.Destination] = ["Test Press": .create("Test Press"), "Test Kniebeuge": .create("Test Kniebeuge")]
        let preview = TrainingCSVImport.preview(document, destinations: routes, exercises: [], calendar: calendar)
        #expect(preview.filter { $0.status == .conflict }.count == 1)
        let result = try TrainingCSVImport.save(document, selected: Set(preview.map(\.id)),
            approvedConflicts: Set(preview.filter { $0.status == .conflict }.map(\.id)), destinations: routes,
            container: target, calendar: calendar)
        #expect(result.imported == 3)
        #expect(result.exercisesCreated == 2)
        let check = ModelContext(target)
        let imported = try check.fetch(FetchDescriptor<TrainingEntry>())
        #expect(Set(imported.map(\.id)) == Set([first.id, second.id, third.id]))
        let saved = try #require(imported.first { $0.id == first.id })
        #expect(saved.sortedGroups.map(\.weight) == [0, 40, 52.5])
        #expect(saved.sortedGroups.map(\.prescription) == ["1 × 5", "1 × 5", "3 × 5"])
        #expect(saved.sortedGroups.map(\.isWorking) == [false, false, true])
        #expect(saved.effort == .veryEasy)
        let exercises = try check.fetch(FetchDescriptor<Exercise>())
        #expect(exercises.allSatisfy { $0.targetWeight == nil && $0.templates.isEmpty })
        let existingRoutes = TrainingCSVImport.initialDestinations(document, exercises: exercises, fixedExerciseID: nil)
        let repeated = TrainingCSVImport.preview(document, destinations: existingRoutes, exercises: exercises, calendar: calendar)
        #expect(repeated.allSatisfy { $0.status == .duplicate })
        let repeatResult = try TrainingCSVImport.save(document, selected: Set(repeated.map(\.id)), approvedConflicts: [],
            destinations: existingRoutes, container: target, calendar: calendar)
        #expect(repeatResult.imported == 0)
        #expect(try ModelContext(target).fetchCount(FetchDescriptor<TrainingEntry>()) == 3)
        let oneExercise = try TrainingCSV.parse(TrainingCSVExport.text(imported.filter { $0.exercise?.name == "Test Press" }))
        #expect(oneExercise.trainings.count == 2)
        #expect(oneExercise.trainings.allSatisfy { $0.exerciseName == "Test Press" })
    }

    @Test func legacyDuplicatesRequireCompleteGroupEquality() throws {
        let target = try container()
        let context = ModelContext(target)
        let exercise = Exercise(name: "Test", targetWeight: 100)
        context.insert(exercise)
        let document = try TrainingCSV.parse(legacy + "18.11.2026;3x5;60;o\n18.11.2026;3x5;60;o", calendar: calendar)
        let routes: [String: TrainingCSVImport.Destination] = ["": .existing(exercise.id)]
        let preview = TrainingCSVImport.preview(document, destinations: routes, exercises: [exercise], calendar: calendar)
        #expect(preview.map(\.status) == [.new, .duplicate])
        _ = addTraining(to: exercise, date: document.trainings[0].date, weights: [0, 40, 60], context: context)
        try context.save()
        let complete = TrainingCSVImport.preview(document, destinations: routes, exercises: [exercise], calendar: calendar)
        #expect(complete.map(\.status) == [.conflict, .duplicate])
    }

    @Test func changedWarmupAndChangedSourceIDAreConflictsAndNeverOverwrite() throws {
        let target = try container()
        let context = ModelContext(target)
        let exercise = Exercise(name: "Test", targetWeight: 100)
        context.insert(exercise)
        let date = try #require(calendar.date(from: DateComponents(year: 2026, month: 11, day: 18, hour: 12)))
        let entry = addTraining(to: exercise, date: date, weights: [0, 40, 60], context: context)
        entry.effort = .okay
        try context.save()
        let original = try TrainingCSVExport.text([entry], calendar: calendar)
        let changed = try TrainingCSV.parse(original.replacingOccurrences(of: "\"40.0\"", with: "\"42.0\""), calendar: calendar)
        let routes: [String: TrainingCSVImport.Destination] = ["Test": .existing(exercise.id)]
        let preview = TrainingCSVImport.preview(changed, destinations: routes, exercises: [exercise], calendar: calendar)
        #expect(preview[0].status == .conflict)
        #expect(throws: TrainingCSV.CSVError.self) {
            try TrainingCSVImport.save(changed, selected: Set(preview.map(\.id)), approvedConflicts: [], destinations: routes, container: target, calendar: calendar)
        }
        #expect(try ModelContext(target).fetchCount(FetchDescriptor<TrainingEntry>()) == 1)
        _ = try TrainingCSVImport.save(changed, selected: Set(preview.map(\.id)), approvedConflicts: Set(preview.map(\.id)), destinations: routes, container: target, calendar: calendar)
        let saved = try ModelContext(target).fetch(FetchDescriptor<TrainingEntry>())
        #expect(saved.count == 2)
        #expect(saved.first { $0.id == entry.id }?.sortedGroups.map(\.weight) == [0, 40, 60])
        #expect(saved.first { $0.id != entry.id }?.sortedGroups.map(\.weight) == [0, 42, 60])
    }

    @Test func mappingRequiresExplicitCreationAndSingleExerciseMismatchApproval() throws {
        let target = try container()
        let context = ModelContext(target)
        let exercise = Exercise(name: "Zielübung", targetWeight: 100)
        context.insert(exercise); try context.save()
        let document = try TrainingCSV.parse(header + "a;Quellübung;18.11.2026;1;3x5;60;ja;o")
        let initial = TrainingCSVImport.initialDestinations(document, exercises: [exercise], fixedExerciseID: nil)
        #expect(initial["Quellübung"] == .unassigned)
        #expect(throws: TrainingCSV.CSVError.self) {
            try TrainingCSVImport.save(document, selected: [2], approvedConflicts: [], destinations: initial, container: target)
        }
        let routes: [String: TrainingCSVImport.Destination] = ["Quellübung": .existing(exercise.id)]
        #expect(throws: TrainingCSV.CSVError.self) {
            try TrainingCSVImport.save(document, selected: [2], approvedConflicts: [], destinations: routes,
                fixedExerciseID: exercise.id, container: target)
        }
        _ = try TrainingCSVImport.save(document, selected: [2], approvedConflicts: [], destinations: routes,
            fixedExerciseID: exercise.id, allowNameMismatch: true, container: target)
        #expect(try ModelContext(target).fetchCount(FetchDescriptor<TrainingEntry>()) == 1)
        #expect(try ModelContext(target).fetchCount(FetchDescriptor<Exercise>()) == 1)
    }

    @Test func invalidFileAndOtherTypesCannotWriteAndUnrelatedStateIsPreserved() throws {
        let target = try container()
        let context = ModelContext(target)
        context.autosaveEnabled = false
        let exercise = Exercise(name: "Test", targetWeight: 100)
        let other = Exercise(name: "Satzübung", targetWeight: nil, activityType: .sets)
        let template = ExerciseSetTemplate(position: 0, prescription: "1x5", isWorking: true)
        context.insert(exercise); context.insert(other); context.insert(template)
        exercise.templates.append(template)
        context.insert(TrainingDayNote(date: Date(), text: "Fiktive Notiz"))
        try context.save()
        exercise.name = "Ungespeicherte Änderung"
        let good = try TrainingCSV.parse(legacy + "18.11.2026;3x5;60;o")
        #expect(throws: TrainingCSV.CSVError.self) {
            try TrainingCSVImport.save(good, selected: [2], approvedConflicts: [], destinations: ["": .existing(other.id)], container: target)
        }
        let bad = try TrainingCSV.parse(legacy + "18.11.2026;3x5;60;o\n31.02.2026;3x5;60;o")
        #expect(throws: TrainingCSV.CSVError.self) {
            try TrainingCSVImport.save(bad, selected: [2], approvedConflicts: [], destinations: ["": .existing(exercise.id)], container: target)
        }
        _ = try TrainingCSVImport.save(good, selected: [2], approvedConflicts: [], destinations: ["": .existing(exercise.id)], container: target)
        let check = ModelContext(target)
        let saved = try #require(check.fetch(FetchDescriptor<Exercise>()).first { $0.id == exercise.id })
        #expect(saved.name == "Test")
        #expect(saved.targetWeight == 100)
        #expect(saved.templates.first?.id == template.id)
        #expect(saved.progress == 0.6)
        #expect(exercise.name == "Ungespeicherte Änderung")
        #expect(try check.fetchCount(FetchDescriptor<TrainingDayNote>()) == 1)
        #expect(try check.fetchCount(FetchDescriptor<TrainingEntry>()) == 1)
    }

    private func addTraining(to exercise: Exercise, date: Date, weights: [Double], context: ModelContext) -> TrainingEntry {
        let entry = TrainingEntry(date: date, exercise: exercise)
        context.insert(entry)
        for (index, weight) in weights.enumerated() {
            let group = SetGroup(position: index, prescription: index == weights.count - 1 ? "3 × 5" : "1 × 5",
                                 weight: weight, isWorking: index == weights.count - 1)
            context.insert(group); entry.setGroups.append(group)
        }
        return entry
    }

    private func container() throws -> ModelContainer {
        let schema = Schema(versionedSchema: TrainuvoSchemaV4.self)
        return try ModelContainer(for: schema, configurations: [ModelConfiguration(schema: schema, isStoredInMemoryOnly: true, cloudKitDatabase: .none)])
    }
}
