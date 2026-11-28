import Foundation
import Testing
@testable import Trainuvo

@MainActor
struct BodyweightGoalCalculatorTests {
    @Test func calculatesAllFourAgreedTargets() throws {
        let goals = try #require(BodyweightGoalCalculator.goals(for: "80"))
        #expect(goals.map(\.name) == ["Kniebeuge", "Press", "Kreuzheben", "Bankdrücken"])
        #expect(goals.map(\.percentage) == [100, 40, 130, 75])
        #expect(goals.map(\.weight) == [80, 32, 104, 60])
    }

    @Test func acceptsDecimalCommaAndPointWithoutRoundingToPlates() throws {
        let comma = try #require(BodyweightGoalCalculator.goals(for: " 82,5 "))
        let point = try #require(BodyweightGoalCalculator.goals(for: "82.5"))
        #expect(comma.map(\.weight) == point.map(\.weight))
        #expect(comma.map(\.weight) == [82.5, 33, 107.25, 61.875])
    }

    @Test(arguments: ["", " ", "0", "-80", "abc", "NaN", "inf", "100001"])
    func invalidInputProducesNoTargets(_ text: String) {
        #expect(BodyweightGoalCalculator.goals(for: text) == nil)
    }
}
