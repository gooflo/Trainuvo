import Foundation
import SwiftData

@Model
final class TrainingDayNote {
    var id: UUID = UUID()
    var dayKey: String = ""
    var text: String = ""

    init(date: Date, text: String, calendar: Calendar = .current) {
        self.dayKey = Self.key(for: date, calendar: calendar)
        self.text = text
    }

    static func key(for date: Date, calendar: Calendar = .current) -> String {
        formatter(calendar).string(from: date)
    }

    func date(calendar: Calendar = .current) -> Date? {
        Self.formatter(calendar).date(from: dayKey)
    }

    private static func formatter(_ calendar: Calendar) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = calendar.timeZone
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }

    static func combined(_ notes: [TrainingDayNote]) -> String {
        notes.sorted { $0.id.uuidString < $1.id.uuidString }
            .map(\.text).filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .joined(separator: "\n\n")
    }

    static func save(text: String, date: Date, in context: ModelContext, calendar: Calendar = .current) throws {
        let dayKey = Self.key(for: date, calendar: calendar)
        let matching = try context.fetch(FetchDescriptor<TrainingDayNote>()).filter { $0.dayKey == dayKey }
            .sorted { $0.id.uuidString < $1.id.uuidString }
        let clean = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if clean.isEmpty {
            for note in matching { context.delete(note) }
        } else if let first = matching.first {
            first.text = clean
            for note in matching.dropFirst() { context.delete(note) }
        } else {
            context.insert(TrainingDayNote(date: date, text: clean, calendar: calendar))
        }
        do { try context.save() } catch { context.rollback(); throw error }
    }
}
