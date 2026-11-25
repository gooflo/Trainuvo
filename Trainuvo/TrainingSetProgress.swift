import Foundation

/// One-based set numbers. Only unambiguous prescriptions get checkboxes.
enum TrainingSetProgress {
    static func count(for prescription: String) -> Int {
        let parts = prescription.lowercased()
            .replacingOccurrences(of: "×", with: "x")
            .split(separator: "x", omittingEmptySubsequences: false)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        guard parts.count == 2,
              parts.allSatisfy({ !$0.isEmpty && $0.allSatisfy { "0123456789".contains($0) } }),
              let sets = Int(parts[0]), let repetitions = Int(parts[1]),
              (1...100).contains(sets), repetitions > 0 else { return 0 }
        return sets
    }

    static func valid(_ completed: Set<Int>, for prescription: String) -> Set<Int> {
        let count = count(for: prescription)
        return Set(completed.filter { $0 >= 1 && $0 <= count })
    }
}
