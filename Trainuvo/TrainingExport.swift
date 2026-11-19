import Foundation

enum TrainingExport {
    struct Group: Codable {
        let id: UUID
        let position: Int
        let prescription: String
        let weight: Double?
        let detailText: String?
        let isWorking: Bool
    }
    struct Entry: Codable {
        let id: UUID
        let date: Date
        let createdAt: Date
        let exerciseID: UUID?
        let exerciseName: String
        let type: String
        let storedType: String?
        let effort: String?
        let targetWeight: Double?
        let targetDescription: String?
        let groups: [Group]
    }
    struct DayNote: Codable {
        let day: String
        let text: String
    }
    struct Document: Codable {
        let schemaVersion: Int
        let from: Date
        let to: Date
        let timeZone: String
        let entries: [Entry]
        let dayNotes: [DayNote]
    }

    static func selected(_ entries: [TrainingEntry], from: Date, to: Date, calendar: Calendar = .current) -> [TrainingEntry] {
        guard from <= to, let end = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: to)) else { return [] }
        let start = calendar.startOfDay(for: from)
        let filtered = entries.filter { $0.date >= start && $0.date < end }
        return TrainingDaySummary.grouped(filtered, calendar: calendar).flatMap(\.entries)
    }

    static func selectedNotes(_ notes: [TrainingDayNote], from: Date, to: Date, calendar: Calendar = .current) -> [TrainingDayNote] {
        guard from <= to else { return [] }
        let start = calendar.startOfDay(for: from)
        let end = calendar.startOfDay(for: to)
        return notes.filter {
            guard let date = $0.date(calendar: calendar) else { return false }
            return date >= start && date <= end && !$0.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }.sorted { $0.dayKey > $1.dayKey }
    }

    static func snapshot(_ entries: [TrainingEntry]) -> [Entry] {
        entries.map { entry in
            Entry(id: entry.id, date: entry.date, createdAt: entry.createdAt,
                  exerciseID: entry.exercise?.id, exerciseName: entry.exercise?.name ?? "Unbekannte Übung",
                  type: entry.activityType.rawValue, storedType: entry.activityTypeRawValue,
                  effort: entry.effortRawValue, targetWeight: entry.exercise?.targetWeight,
                  targetDescription: entry.exercise?.targetDescription,
                  groups: entry.sortedGroups.map {
                      Group(id: $0.id, position: $0.position, prescription: $0.prescription,
                            weight: entry.activityType.usesWeights ? $0.weight : nil,
                            detailText: $0.detailText, isWorking: $0.isWorking)
                  })
        }
    }

    static func oneLine(_ text: String) -> String {
        text.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.joined(separator: " ")
    }

    static func text(_ entries: [TrainingEntry], notes: [TrainingDayNote] = [], calendar: Calendar = .current) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.timeZone = calendar.timeZone
        formatter.locale = Locale(identifier: "de_DE")
        formatter.dateFormat = "dd.MM.yyyy"
        return TrainingDaySummary.grouped(entries, notes: notes, calendar: calendar).map { day in
            let parts = day.entries.map { entry in
                let name = oneLine(entry.exercise?.name ?? "Unbekannte Übung")
                let rating = entry.effort.map { $0.symbol + " " } ?? ""
                let content: String
                if entry.activityType.usesSets {
                    content = entry.workingGroup.map { oneLine($0.summary(for: entry.activityType)) } ?? "Keine Arbeitsgruppe"
                } else {
                    content = entry.sortedGroups.map { group in
                        [oneLine(group.prescription), oneLine(group.detailText ?? "")]
                            .filter { !$0.isEmpty }.joined(separator: " / ")
                    }.joined(separator: "; ")
                }
                return "\(name) \(rating)\(content)"
            }
            let comment = day.noteText.isEmpty ? [] : ["Notiz: " + oneLine(day.noteText)]
            return ([formatter.string(from: day.date)] + parts + comment).joined(separator: " | ")
        }.joined(separator: "\n")
    }

    static func json(_ entries: [TrainingEntry], notes: [TrainingDayNote] = [], from: Date, to: Date, calendar: Calendar = .current) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(Document(schemaVersion: 2, from: calendar.startOfDay(for: from),
                                           to: calendar.startOfDay(for: to), timeZone: calendar.timeZone.identifier,
                                           entries: snapshot(entries), dayNotes: selectedNotes(notes, from: from, to: to, calendar: calendar).map { DayNote(day: $0.dayKey, text: $0.text) }))
    }

    static func fileURL(from: Date, to: Date, extension suffix: String) throws -> URL {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyyMMdd"
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder.appendingPathComponent("Trainuvo_Export_\(formatter.string(from: from))_\(formatter.string(from: to)).\(suffix)")
    }
}
