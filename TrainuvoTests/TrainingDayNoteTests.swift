import Foundation
import SwiftData
import Testing
@testable import Trainuvo

@MainActor
struct TrainingDayNoteTests {
    private func container() throws -> ModelContainer {
        let schema = Schema([Item.self, Exercise.self, TrainingEntry.self, SetGroup.self, ExerciseSetTemplate.self, TrainingDayNote.self])
        return try ModelContainer(for: schema, configurations: [ModelConfiguration(schema: schema, isStoredInMemoryOnly: true, cloudKitDatabase: .none)])
    }

    @Test func notesPersistIndependentlyAndCanBeEditedAndDeleted() throws {
        let store = try container()
        let context = ModelContext(store)
        let exercise = Exercise(name: "Press", targetWeight: 40)
        context.insert(exercise)
        let date = Date()
        let training = TrainingEntry(date: date, exercise: exercise)
        context.insert(training)
        try context.save()
        try TrainingDayNote.save(text: " Wenig geschlafen\nTrotzdem gut ", date: date, in: context)
        try TrainingDayNote.save(text: "Geändert", date: date, in: context)
        #expect(try context.fetchCount(FetchDescriptor<TrainingDayNote>()) == 1)
        try training.deleteKeepingExercise(in: context)
        context.delete(exercise)
        try context.save()
        let reader = ModelContext(store)
        let notes = try reader.fetch(FetchDescriptor<TrainingDayNote>())
        #expect(notes.first?.text == "Geändert")
        let days = TrainingDaySummary.grouped([], notes: notes)
        #expect(days.count == 1)
        #expect(days.first?.entries.isEmpty == true)
        #expect(days.first?.noteText == "Geändert")
        try TrainingDayNote.save(text: "", date: date, in: reader)
        #expect(try reader.fetchCount(FetchDescriptor<TrainingDayNote>()) == 0)
    }

    @Test func notesMatchCalendarDayAndExportWithoutTrainings() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try #require(TimeZone(identifier: "Europe/Berlin"))
        let date = try #require(calendar.date(from: DateComponents(year: 2026, month: 11, day: 17, hour: 23)))
        let note = TrainingDayNote(date: date, text: "Gut\nweiter so", calendar: calendar)
        let previous = TrainingDayNote(date: date.addingTimeInterval(-86400), text: "Vorher", calendar: calendar)
        #expect(note.dayKey == "2026-11-17")
        let exercise = Exercise(name: "Press", targetWeight: 40)
        let training = TrainingEntry(date: date, exercise: exercise)
        training.groups = [SetGroup(position: 0, prescription: "1×5", weight: 52, isWorking: true)]
        #expect(TrainingExport.text([training], notes: [note], calendar: calendar) == "17.11.2026 | Press 1×5 @ 52 kg | Notiz: Gut weiter so")
        #expect(TrainingExport.selectedNotes([previous, note], from: date, to: date, calendar: calendar).map(\.id) == [note.id])
        #expect(TrainingExport.text([], notes: [note], calendar: calendar) == "17.11.2026 | Notiz: Gut weiter so")
        let bytes = try TrainingExport.json([], notes: [note], from: date, to: date, calendar: calendar)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let result = try decoder.decode(TrainingExport.Document.self, from: bytes)
        #expect(result.schemaVersion == 2)
        #expect(result.entries.isEmpty)
        #expect(result.dayNotes.first?.text == "Gut\nweiter so")
        #expect(result.dayNotes.first?.day == "2026-11-17")
        let url = try TrainingExportExcel.create(entries: [], notes: [note], from: date, to: date)
        defer { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }
        let archive = try Data(contentsOf: url)
        #expect(archive.range(of: Data("Tageskommentar".utf8)) != nil)
        #expect(archive.range(of: Data("Gut\nweiter so".utf8)) != nil)
    }

    @Test func allDeleteRemovesNotesAndDuplicateDayNotesConsolidate() throws {
        let store = try container()
        let context = ModelContext(store)
        let date = Date()
        context.insert(TrainingDayNote(date: date, text: "Erste"))
        context.insert(TrainingDayNote(date: date, text: "Zweite"))
        try context.save()
        let notes = try context.fetch(FetchDescriptor<TrainingDayNote>())
        let combined = TrainingDayNote.combined(notes)
        #expect(combined.contains("Erste") && combined.contains("Zweite"))
        try TrainingDayNote.save(text: combined, date: date, in: context)
        #expect(try context.fetchCount(FetchDescriptor<TrainingDayNote>()) == 1)
        try TrainingDataOperations.deleteAll(in: context)
        #expect(try context.fetchCount(FetchDescriptor<TrainingDayNote>()) == 0)
    }
}
