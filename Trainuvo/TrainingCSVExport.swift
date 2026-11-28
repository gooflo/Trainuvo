import Foundation

@MainActor
enum TrainingCSVExport {
    static func text(_ entries: [TrainingEntry], calendar: Calendar = .current) throws -> String {
        var lines = [TrainingCSV.header]
        let sorted = TrainingDaySummary.grouped(entries.filter { $0.activityType == .strength }, calendar: calendar).flatMap(\.entries)
        for entry in sorted {
            guard let exercise = entry.exercise, !exercise.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  !entry.setGroups.isEmpty, entry.setGroups.filter(\.isWorking).count == 1 else {
                throw TrainingCSV.CSVError.message("Ein Training hat keinen Übungsnamen, keine Satzgruppen oder keine eindeutige Arbeitsgruppe. Bitte vor dem CSV-Export korrigieren.")
            }
            // Tie-breaking guarantees stable group order even for historical equal positions.
            let groups = entry.setGroups.sorted {
                $0.position == $1.position ? $0.id.uuidString < $1.id.uuidString : $0.position < $1.position
            }
            for (index, group) in groups.enumerated() {
                let fields = [entry.id.uuidString, exercise.name, TrainingCSV.dateText(entry.date, calendar: calendar),
                              String(index + 1), group.prescription, TrainingCSV.weightText(group.weight), group.isWorking ? "ja" : "nein", entry.effort?.symbol ?? ""]
                lines.append(fields.map(TrainingCSV.quoted).joined(separator: ";"))
            }
        }
        let text = lines.joined(separator: "\r\n") + "\r\n"
        // Never create a CSV that our importer would reject (including bounds and limits).
        let check = try TrainingCSV.parse(text, calendar: calendar)
        guard check.issues.isEmpty else { throw TrainingCSV.CSVError.message("Ein Trainingswert ist für das CSV-Format ungültig. Bitte die Satzgruppen prüfen.") }
        return text
    }
}
