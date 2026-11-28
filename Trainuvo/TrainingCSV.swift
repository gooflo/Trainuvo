import Foundation

/// Shared interchange format for strength trainings; no database writes.
enum TrainingCSV {
    static let maximumBytes = 2_000_000
    static let maximumRows = 10_000
    static let header = "Training-ID;Übung;Datum;Satzgruppe;Sätze;Gewicht;Arbeitsgruppe;Bewertung"
    static let legacyHeader = "Datum;Sätze;Gewicht;Bewertung"

    struct Row: Identifiable, Equatable {
        let line: Int
        let date: Date
        let prescription: String
        let weight: Double
        let effortSymbol: String?
        var trainingID: String? = nil
        var exerciseName: String? = nil
        var position: Int = 1
        var isWorking: Bool = true
        var id: Int { line }
    }

    struct Group: Hashable {
        let prescription: String
        let weight: Double
        let isWorking: Bool
    }

    struct Training: Identifiable {
        let id: Int
        let sourceID: String?
        let exerciseName: String?
        let date: Date
        let groups: [Group]
        let effortSymbol: String?
    }

    struct Issue: Identifiable, Equatable {
        let line: Int
        let message: String
        var id: Int { line }
    }

    struct Document {
        var rows: [Row] = []
        var issues: [Issue] = []
        var isLegacy = false

        var trainings: [Training] {
            var order: [String] = []
            var grouped: [String: [Row]] = [:]
            for row in rows {
                let key = row.trainingID ?? "legacy-\(row.line)"
                if grouped[key] == nil { order.append(key) }
                grouped[key, default: []].append(row)
            }
            return order.compactMap { key in
                guard let rows = grouped[key], let first = rows.first else { return nil }
                return Training(id: first.line, sourceID: first.trainingID, exerciseName: first.exerciseName,
                                date: first.date, groups: rows.sorted { $0.position < $1.position }.map {
                                    Group(prescription: $0.prescription, weight: $0.weight, isWorking: $0.isWorking)
                                }, effortSymbol: first.effortSymbol)
            }
        }
    }

    enum CSVError: LocalizedError {
        case message(String)
        var errorDescription: String? {
            switch self { case .message(let message): message }
        }
    }

    static func decode(_ data: Data) throws -> String {
        guard data.count <= maximumBytes else { throw CSVError.message("Die Datei ist zu groß (maximal 2 MB).") }
        let text: String?
        if data.starts(with: [0xFF, 0xFE]) || data.starts(with: [0xFE, 0xFF]) {
            text = String(data: data, encoding: .utf16)
        } else { text = String(data: data, encoding: .utf8) }
        guard let text else { throw CSVError.message("Bitte die CSV-Datei als UTF-8 speichern.") }
        return text
    }

    static func parse(_ text: String, calendar: Calendar = .current) throws -> Document {
        guard text.utf8.count <= maximumBytes else { throw CSVError.message("Die Datei ist zu groß (maximal 2 MB).") }
        let records = try records(text.hasPrefix("\u{FEFF}") ? String(text.dropFirst()) : text)
        guard let first = records.first else { throw CSVError.message("Die Datei ist leer.") }
        let headings = first.fields.map { $0.lowercased() }
        let legacy = headings == legacyHeader.lowercased().components(separatedBy: ";")
        guard legacy || headings == header.lowercased().components(separatedBy: ";") else {
            throw CSVError.message("Unbekannte Kopfzeile. Erwartet: \(header). Auch das bisherige Vier-Spalten-Format ist erlaubt.")
        }
        guard records.count > 1 else { throw CSVError.message("Die Datei enthält keine Trainings.") }
        guard records.count <= maximumRows + 1 else { throw CSVError.message("Maximal 10.000 Satzgruppen pro Datei sind erlaubt.") }
        var result = Document(isLegacy: legacy)
        for record in records.dropFirst() {
            let values = record.fields
            func issue(_ message: String) { result.issues.append(Issue(line: record.line, message: message)) }
            guard values.count == (legacy ? 4 : 8) else { issue("Falsche Spaltenzahl."); continue }
            let dateText = values[legacy ? 0 : 2]
            let prescription = values[legacy ? 1 : 4]
            let weightText = values[legacy ? 2 : 5]
            let rating = values[legacy ? 3 : 7]
            guard let date = parseDate(dateText, calendar: calendar) else { issue("Ungültiges Datum. Erwartet: TT.MM.JJJJ."); continue }
            guard !prescription.isEmpty, prescription.count <= 200 else { issue("Satzvorgabe fehlt oder überschreitet 200 Zeichen."); continue }
            guard weightText.range(of: #"^[0-9]+([.,][0-9]+)?$"#, options: .regularExpression) != nil,
                  let weight = Double(weightText.replacingOccurrences(of: ",", with: ".")),
                  weight.isFinite, weight <= 100_000 else { issue("Gewicht muss zwischen 0 und 100000 liegen, ohne kg."); continue }
            guard ["", "--", "-", "o", "+", "++"].contains(rating) else { issue("Bewertung muss leer oder --, -, o, +, ++ sein."); continue }
            var row = Row(line: record.line, date: date, prescription: normalizedPrescription(prescription),
                          weight: weight, effortSymbol: rating.isEmpty ? nil : rating)
            if !legacy {
                guard !values[0].isEmpty, values[0].count <= 100,
                      !values[1].isEmpty, values[1].count <= 200 else { issue("Training-ID oder Übungsname fehlt oder ist zu lang."); continue }
                guard let position = Int(values[3]), (1...maximumRows).contains(position),
                      ["ja", "nein"].contains(values[6].lowercased()) else { issue("Satzgruppe muss eine positive Nummer sein, Arbeitsgruppe ja oder nein."); continue }
                row.trainingID = UUID(uuidString: values[0])?.uuidString ?? values[0]; row.exerciseName = values[1]
                row.position = position; row.isWorking = values[6].lowercased() == "ja"
            }
            result.rows.append(row)
        }
        if !legacy {
            let grouped = Dictionary(grouping: result.rows) { $0.trainingID! }
            for rows in grouped.values {
                guard let first = rows.first else { continue }
                let consistent = rows.allSatisfy { $0.exerciseName == first.exerciseName && $0.date == first.date && $0.effortSymbol == first.effortSymbol }
                let ordered = rows.map(\.position).sorted() == Array(1...rows.count)
                if !consistent || !ordered || rows.filter(\.isWorking).count != 1 {
                    // Add at most one error per physical row, preserving stable SwiftUI identities.
                    result.issues.append(Issue(line: first.line, message: "Training \(first.trainingID ?? ""): Name, Datum und Bewertung müssen gleich sein; Satzgruppen lückenlos ab 1, genau eine Arbeitsgruppe."))
                }
            }
        }
        result.issues.sort { $0.line < $1.line }
        return result
    }

    static func normalizedPrescription(_ text: String) -> String {
        let compact = text.lowercased().replacingOccurrences(of: "×", with: "x").filter { !$0.isWhitespace }
        if compact.range(of: #"^[1-9][0-9]*x[1-9][0-9]*$"#, options: .regularExpression) != nil {
            return compact.replacingOccurrences(of: "x", with: " × ")
        }
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func dateText(_ date: Date, calendar: Calendar = .current) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = calendar.timeZone
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: date)
    }

    static func quoted(_ value: String) -> String {
        "\"" + value.replacingOccurrences(of: "\"", with: "\"\"") + "\""
    }

    /// Expand scientific notation without rounding away small, valid Double values.
    static func weightText(_ value: Double) -> String {
        let raw = String(value)
        let parts = raw.lowercased().split(separator: "e")
        guard parts.count == 2, let exponent = Int(parts[1]) else { return raw }
        let mantissa = parts[0].split(separator: ".")
        let digits = mantissa.joined()
        let point = mantissa[0].count + exponent
        if point <= 0 { return "0." + String(repeating: "0", count: -point) + digits }
        if point >= digits.count { return digits + String(repeating: "0", count: point - digits.count) }
        let split = digits.index(digits.startIndex, offsetBy: point)
        return String(digits[..<split]) + "." + String(digits[split...])
    }

    private static func parseDate(_ text: String, calendar: Calendar) -> Date? {
        guard text.range(of: #"^[0-9]{2}\.[0-9]{2}\.[0-9]{4}$"#, options: .regularExpression) != nil else { return nil }
        let parts = text.split(separator: ".").compactMap { Int($0) }
        guard parts.count == 3, (1900...9999).contains(parts[2]) else { return nil }
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.timeZone = calendar.timeZone
        guard let date = gregorian.date(from: DateComponents(year: parts[2], month: parts[1], day: parts[0], hour: 12)) else { return nil }
        let components = gregorian.dateComponents([.year, .month, .day], from: date)
        guard components.year == parts[2], components.month == parts[1], components.day == parts[0] else { return nil }
        return date
    }

    private struct Record { let line: Int; let fields: [String] }

    /// Semicolon CSV including escaped quotes and embedded newlines in quoted fields.
    private static func records(_ input: String) throws -> [Record] {
        let text = input.replacingOccurrences(of: "\r\n", with: "\n").replacingOccurrences(of: "\r", with: "\n")
        var result: [Record] = []
        var fields: [String] = []
        var field = ""
        var quoted = false
        var closed = false
        var line = 1
        var recordLine = 1
        func finishField() { fields.append(field.trimmingCharacters(in: .whitespacesAndNewlines)); field = ""; closed = false }
        func finishRecord() {
            finishField()
            if fields.count > 1 || fields.first != "" { result.append(Record(line: recordLine, fields: fields)) }
            fields = []
        }
        for character in text {
            if quoted {
                if character == "\"" { quoted = false; closed = true } else { field.append(character) }
            } else if closed {
                if character == "\"" { field.append(character); quoted = true; closed = false }
                else if character == ";" { finishField() }
                else if character == "\n" { finishRecord() }
                else if !character.isWhitespace { throw CSVError.message("Zeile \(line): Ungültiges Zeichen nach Anführungszeichen.") }
            } else if character == "\"" {
                guard field.trimmingCharacters(in: .whitespaces).isEmpty else { throw CSVError.message("Zeile \(line): Anführungszeichen bitte verdoppeln oder Feld vollständig zitieren.") }
                field = ""; quoted = true
            } else if character == ";" { finishField() }
            else if character == "\n" { finishRecord() }
            else { field.append(character) }
            if character == "\n" { line += 1; if !quoted { recordLine = line } }
        }
        guard !quoted else { throw CSVError.message("Zeile \(recordLine): Anführungszeichen nicht geschlossen.") }
        if !field.isEmpty || !fields.isEmpty || closed { finishRecord() }
        return result
    }
}
