import Foundation

enum TrainingExportFileName {
    static func baseName(_ name: String, extension suffix: String) -> String? {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.rangeOfCharacter(from: CharacterSet(charactersIn: "/:\\").union(.controlCharacters)) == nil else { return nil }
        let ending = "." + suffix
        let base = trimmed.lowercased().hasSuffix(ending.lowercased())
            ? String(trimmed.dropLast(ending.count)).trimmingCharacters(in: .whitespacesAndNewlines)
            : trimmed
        guard !base.isEmpty, base != ".", base != ".." else { return nil }
        return base
    }
}
