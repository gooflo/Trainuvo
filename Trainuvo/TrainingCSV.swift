import Foundation

/// One row represents one training with a single working set group.
enum TrainingCSV {
    static let maximumBytes = 2_000_000
    static let maximumRows = 10_000

    struct Row: Identifiable, Equatable {
        let line: Int
        let date: Date
        let prescription: String
        let weight: Double
        let effortSymbol: String?
        var id: Int { line }
    }

    struct Issue: Identifiable, Equatable {
        let line: Int
        let message: String
        var id: Int { line }
    }

    struct Document {
        var rows: [Row] = []
        var issues: [Issue] = []
    }

    enum CSVError: LocalizedError {
        case message(String)
        var errorDescription: String? {
            switch self { case .message(let message): message }
        }
    }

    static func decode(_ data: Data) throws -> String {
        guard data.count <= maximumBytes else {
            throw CSVError.message("Die Datei ist zu groß. Erlaubt sind höchstens 2 MB.")
        }
        let text: String?
        if data.starts(with: [0xFF, 0xFE]) || data.starts(with: [0xFE, 0xFF]) {
            text = String(data: data, encoding: .utf16)
        } else {
            text = String(data: data, encoding: .utf8)
        }
        guard let text else {
            throw CSVError.message("Die Textkodierung wird nicht unterstützt. Speichere die CSV-Datei als UTF-8.")
        }
        return text
    }

    static func parse(_ text: String, calendar: Calendar = .current) throws -> Document {
        guard text.utf8.count <= maximumBytes else {
            throw CSVError.message("Die Datei ist zu groß. Erlaubt sind höchstens 2 MB.")
        }
        let text = text.hasPrefix("\u{FEFF}") ? String(text.dropFirst()) : text
        let lines = text.replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n").components(separatedBy: "\n")
        let nonempty = lines.enumerated().filter { !$0.element.trimmingCharacters(in: .whitespaces).isEmpty }
        guard let header = nonempty.first else { throw CSVError.message("Die Datei ist leer.") }
        guard nonempty.count <= maximumRows + 1 else {
            throw CSVError.message("Erlaubt sind höchstens 10.000 Trainings pro Datei.")
        }
        guard let headings = fields(header.element),
              headings.map({ $0.lowercased() }) == ["datum", "sätze", "gewicht", "bewertung"] else {
            throw CSVError.message("Die Kopfzeile muss lauten: Datum;Sätze;Gewicht;Bewertung")
        }
        var result = Document()
        for (offset, line) in nonempty.dropFirst() {
            let number = offset + 1
            guard let values = fields(line), values.count == 4 else {
                result.issues.append(Issue(line: number, message: "Vier mit Semikolon getrennte Felder erwartet. Anführungszeichen prüfen."))
                continue
            }
            guard let date = parseDate(values[0], calendar: calendar) else {
                result.issues.append(Issue(line: number, message: "Ungültiges Datum. Erwartet: TT.MM.JJJJ, zum Beispiel 18.11.2026."))
                continue
            }
            guard !values[1].isEmpty, values[1].count <= 200 else {
                result.issues.append(Issue(line: number, message: "Satzvorgabe fehlt oder ist zu lang (maximal 200 Zeichen)."))
                continue
            }
            guard values[2].range(of: #"^[0-9]+([.,][0-9]+)?$"#, options: .regularExpression) != nil,
                  let weight = Double(values[2].replacingOccurrences(of: ",", with: ".")),
                  weight.isFinite, weight <= 100_000 else {
                result.issues.append(Issue(line: number, message: "Gewicht muss zwischen 0 und 100000 liegen, ohne kg. Komma oder Punkt sind erlaubt."))
                continue
            }
            guard ["", "--", "-", "o", "+", "++"].contains(values[3]) else {
                result.issues.append(Issue(line: number, message: "Bewertung muss leer oder --, -, o, +, ++ sein."))
                continue
            }
            result.rows.append(Row(line: number, date: date, prescription: normalizedPrescription(values[1]),
                                   weight: weight, effortSymbol: values[3].isEmpty ? nil : values[3]))
        }
        guard !result.rows.isEmpty || !result.issues.isEmpty else {
            throw CSVError.message("Die Datei enthält nur eine Kopfzeile, aber keine Trainings.")
        }
        return result
    }

    static func normalizedPrescription(_ text: String) -> String {
        let compact = text.lowercased().replacingOccurrences(of: "×", with: "x")
            .filter { !$0.isWhitespace }
        if compact.range(of: #"^[1-9][0-9]*x[1-9][0-9]*$"#, options: .regularExpression) != nil {
            return compact.replacingOccurrences(of: "x", with: " × ")
        }
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
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

    /// Deliberately one physical line per training; supports quoted fields and escaped quotes.
    private static func fields(_ line: String) -> [String]? {
        var result: [String] = []
        var field = ""
        var quoted = false
        var closedQuote = false
        var characters = line.makeIterator()
        while let character = characters.next() {
            if quoted {
                if character == "\"" { quoted = false; closedQuote = true }
                else { field.append(character) }
            } else if closedQuote {
                if character == "\"" { field.append(character); quoted = true; closedQuote = false }
                else if character == ";" {
                    result.append(field.trimmingCharacters(in: .whitespaces)); field = ""; closedQuote = false
                } else if !character.isWhitespace { return nil }
            } else if character == ";" {
                result.append(field.trimmingCharacters(in: .whitespaces)); field = ""
            } else if character == "\"" {
                guard field.trimmingCharacters(in: .whitespaces).isEmpty else { return nil }
                field = ""; quoted = true
            } else { field.append(character) }
        }
        guard !quoted else { return nil }
        result.append(field.trimmingCharacters(in: .whitespaces))
        return result
    }
}
