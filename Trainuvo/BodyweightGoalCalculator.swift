import Foundation

enum BodyweightGoalCalculator {
    struct Goal: Identifiable, Equatable {
        let name: String
        let percentage: Int
        let weight: Double
        var id: String { name }
    }

    struct Factor: Identifiable {
        let name: String
        let percentage: Int
        var id: String { name }
    }

    static let factors: [Factor] = [
        Factor(name: "Kniebeuge", percentage: 100),
        Factor(name: "Press", percentage: 40),
        Factor(name: "Kreuzheben", percentage: 130),
        Factor(name: "Bankdrücken", percentage: 75)
    ]

    static func goals(for text: String) -> [Goal]? {
        guard let bodyweight = TrainingFormat.parseWeight(text), bodyweight > 0 else { return nil }
        return factors.map { Goal(name: $0.name, percentage: $0.percentage,
                                  weight: bodyweight * Double($0.percentage) / 100) }
    }
}
