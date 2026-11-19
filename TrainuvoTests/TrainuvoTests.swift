import Foundation
import SwiftData
import Testing
@testable import Trainuvo

@MainActor
struct TrainuvoTests {
    @Test func acceptsGermanAndEnglishWeights() {
        #expect(TrainingFormat.parseWeight(" 72,5 ") == 72.5)
        #expect(TrainingFormat.parseWeight("72.5") == 72.5)
        #expect(TrainingFormat.parseWeight("0") == 0)
        #expect(TrainingFormat.parseWeight("-1") == nil)
        #expect(TrainingFormat.parseWeight("NaN") == nil)
        #expect(TrainingFormat.parseWeight("inf") == nil)
        #expect(TrainingFormat.parseWeight("") == nil)
    }

    @Test func latestTrainingUsesMarkedWorkingWeight() {
        let exercise = Exercise(name: "Kreuzheben", targetWeight: 100)
        let older = TrainingEntry(date: Date(timeIntervalSince1970: 100), exercise: exercise)
        older.groups = [SetGroup(position: 0, prescription: "3 × 5", weight: 90, isWorking: true)]
        let latest = TrainingEntry(date: Date(timeIntervalSince1970: 200), exercise: exercise)
        latest.groups = [
            SetGroup(position: 0, prescription: "1 × 5", weight: 50, isWorking: false),
            SetGroup(position: 1, prescription: "3 × 5", weight: 60, isWorking: true)
        ]
        exercise.entries = [latest, older]
        #expect(exercise.progress == 0.6)
        exercise.targetWeight = 50
        #expect(exercise.progress == 1.2)
        exercise.targetWeight = nil
        #expect(exercise.progress == nil)
    }

    @Test func relationshipAndCascadePersistInStore() throws {
        let schema = Schema([Item.self, Exercise.self, TrainingEntry.self, SetGroup.self, ExerciseSetTemplate.self, TrainingDayNote.self])
        let container = try ModelContainer(
            for: schema,
            configurations: [ModelConfiguration(schema: schema, isStoredInMemoryOnly: true, cloudKitDatabase: .none)]
        )
        let context = ModelContext(container)
        let exercise = Exercise(name: "Bankdrücken", targetWeight: 100)
        context.insert(exercise)
        let training = TrainingEntry(date: Date(), exercise: exercise)
        training.effort = .easy
        context.insert(training)
        let group = SetGroup(position: 0, prescription: "3 × 5", weight: 60, isWorking: true)
        context.insert(group)
        training.groups.append(group)
        try context.save()

        let template = ExerciseSetTemplate(position: 0, prescription: "1 × 3", isWorking: true)
        context.insert(template)
        exercise.setTemplates.append(template)
        try context.save()

        let reader = ModelContext(container)
        let saved = try #require(reader.fetch(FetchDescriptor<Exercise>()).first)
        #expect(saved.entries.count == 1)
        #expect(saved.latestEntry?.groups.count == 1)
        #expect(saved.progress == 0.6)
        #expect(saved.latestEntry?.effort == .easy)
        #expect(saved.latestEntry?.effortRawValue == "easy")
        #expect(saved.sortedSetTemplates.map(\.prescription) == ["1 × 3"])
        #expect(saved.latestEntry?.sortedGroups.first?.prescription == "3 × 5")

        reader.delete(saved)
        try reader.save()
        #expect(try reader.fetchCount(FetchDescriptor<TrainingEntry>()) == 0)
        #expect(try reader.fetchCount(FetchDescriptor<SetGroup>()) == 0)
        #expect(try reader.fetchCount(FetchDescriptor<ExerciseSetTemplate>()) == 0)
    }

    @Test func templatesRetainOrderAndDoNotChangeTraining() {
        let exercise = Exercise(name: "Kreuzheben", targetWeight: 130)
        exercise.setTemplates = [
            ExerciseSetTemplate(position: 3, prescription: "1 × 5", isWorking: false),
            ExerciseSetTemplate(position: 1, prescription: "1 × 5", isWorking: false),
            ExerciseSetTemplate(position: 0, prescription: "1 × 5", isWorking: false),
            ExerciseSetTemplate(position: 2, prescription: "3 × 5", isWorking: true)
        ]
        #expect(exercise.sortedSetTemplates.map(\.prescription) == ["1 × 5", "1 × 5", "3 × 5", "1 × 5"])
        #expect(exercise.sortedSetTemplates.first(where: \.isWorking)?.position == 2)
        let training = TrainingEntry(date: Date(), exercise: exercise)
        training.groups = [SetGroup(position: 0, prescription: "3 × 3", weight: 60, isWorking: true)]
        exercise.entries = [training]
        exercise.setTemplates[0].prescription = "1 × 3"
        #expect(training.sortedGroups.first?.prescription == "3 × 3")
        #expect(training.workingWeight == 60)
        #expect(TrainingFormat.prescriptions.contains("1 × 3"))
        #expect(TrainingFormat.prescriptions.contains("1 × 5"))
    }

    @Test func exerciseOrderPersistsAndOverridesAlphabeticalOrder() throws {
        let schema = Schema([Item.self, Exercise.self, TrainingEntry.self, SetGroup.self, ExerciseSetTemplate.self, TrainingDayNote.self])
        let container = try ModelContainer(
            for: schema,
            configurations: [ModelConfiguration(schema: schema, isStoredInMemoryOnly: true, cloudKitDatabase: .none)]
        )
        let context = ModelContext(container)
        let bench = Exercise(name: "Bankdrücken", targetWeight: 100)
        let deadlift = Exercise(name: "Kreuzheben", targetWeight: 130)
        #expect(bench.sortOrder == 0)
        #expect(deadlift.sortOrder == 0)
        context.insert(bench)
        context.insert(deadlift)
        try context.save()
        let descriptor = FetchDescriptor<Exercise>(
            sortBy: [SortDescriptor(\Exercise.sortOrder), SortDescriptor(\Exercise.name)]
        )
        #expect(try context.fetch(descriptor).map(\.id) == [bench.id, deadlift.id])
        deadlift.sortOrder = 0
        bench.sortOrder = 1
        try context.save()
        let reader = ModelContext(container)
        #expect(try reader.fetch(descriptor).map(\.id) == [deadlift.id, bench.id])
        bench.name = "Armtraining"
        try context.save()
        let renamedReader = ModelContext(container)
        #expect(try renamedReader.fetch(descriptor).map(\.id) == [deadlift.id, bench.id])
    }

    @Test func effortUsesAllFiveSymbolsAndCanBeCleared() {
        #expect(TrainingEffort.allCases.map(\.symbol) == ["--", "-", "o", "+", "++"])
        let exercise = Exercise(name: "Kreuzheben", targetWeight: 130)
        let training = TrainingEntry(date: Date(), exercise: exercise)
        #expect(training.effort == nil)
        #expect(training.effortRawValue == nil)
        for effort in TrainingEffort.allCases {
            training.effort = effort
            #expect(training.effort == effort)
            #expect(training.effortRawValue == effort.rawValue)
        }
        training.effort = nil
        #expect(training.effortRawValue == nil)
        training.effortRawValue = "future-value"
        #expect(training.effort == nil)
    }

    @Test(arguments: ExerciseType.allCases)
    func clearingEffortIsPersistedForEveryType(_ type: ExerciseType) throws {
        let schema = Schema([Item.self, Exercise.self, TrainingEntry.self, SetGroup.self, ExerciseSetTemplate.self, TrainingDayNote.self])
        let container = try ModelContainer(
            for: schema,
            configurations: [ModelConfiguration(schema: schema, isStoredInMemoryOnly: true, cloudKitDatabase: .none)]
        )
        let context = ModelContext(container)
        let exercise = Exercise(name: "Bewertung", targetWeight: nil, activityType: type)
        context.insert(exercise)
        let training = TrainingEntry(date: Date(), exercise: exercise)
        training.effort = .veryHard
        context.insert(training)
        try context.save()

        let reader = ModelContext(container)
        let saved = try #require(reader.fetch(FetchDescriptor<TrainingEntry>()).first)
        #expect(saved.effort?.symbol == "--")
        saved.effort = nil
        try reader.save()
        let refreshedReader = ModelContext(container)
        let cleared = try #require(refreshedReader.fetch(FetchDescriptor<TrainingEntry>()).first)
        #expect(cleared.effort == nil)
        #expect(cleared.effortRawValue == nil)
    }

    @Test(arguments: [1, 2])
    func deletingTrainingsKeepsExerciseAndTemplates(_ numberOfTrainings: Int) throws {
        let schema = Schema([Item.self, Exercise.self, TrainingEntry.self, SetGroup.self, ExerciseSetTemplate.self, TrainingDayNote.self])
        let container = try ModelContainer(
            for: schema,
            configurations: [ModelConfiguration(schema: schema, isStoredInMemoryOnly: true, cloudKitDatabase: .none)]
        )
        let context = ModelContext(container)
        let exercise = Exercise(name: "Kniebeuge", targetWeight: 100)
        exercise.sortOrder = 3
        let exerciseID = exercise.id
        context.insert(exercise)
        let template = ExerciseSetTemplate(position: 0, prescription: "3 × 5", isWorking: true)
        context.insert(template)
        exercise.setTemplates.append(template)
        var trainings: [TrainingEntry] = []
        for offset in 0..<numberOfTrainings {
            let training = TrainingEntry(date: Date(timeIntervalSince1970: Double(offset)), exercise: exercise)
            context.insert(training)
            let group = SetGroup(position: 0, prescription: "3 × 5", weight: 60, isWorking: true)
            context.insert(group)
            training.groups.append(group)
            trainings.append(training)
        }
        try context.save()

        for (index, training) in trainings.enumerated() {
            try training.deleteKeepingExercise(in: context)
            let reader = ModelContext(container)
            let exercises = try reader.fetch(FetchDescriptor<Exercise>())
            let saved = try #require(exercises.first)
            #expect(exercises.count == 1)
            #expect(saved.id == exerciseID)
            #expect(saved.name == "Kniebeuge")
            #expect(saved.targetWeight == 100)
            #expect(saved.sortOrder == 3)
            #expect(saved.sortedSetTemplates.map(\.prescription) == ["3 × 5"])
            #expect(saved.entries.count == numberOfTrainings - index - 1)
            #expect(try reader.fetchCount(FetchDescriptor<TrainingEntry>()) == numberOfTrainings - index - 1)
            #expect(try reader.fetchCount(FetchDescriptor<SetGroup>()) == numberOfTrainings - index - 1)
        }
    }

    @Test func examplesAreExactAndRepeatableAndGroupedByDay() throws {
        let schema = Schema([Item.self, Exercise.self, TrainingEntry.self, SetGroup.self, ExerciseSetTemplate.self, TrainingDayNote.self])
        let container = try ModelContainer(
            for: schema,
            configurations: [ModelConfiguration(schema: schema, isStoredInMemoryOnly: true, cloudKitDatabase: .none)]
        )
        let context = ModelContext(container)
        let result = try TrainingDataOperations.createExamples(in: context)
        #expect(result.exercisesCreated == 4)
        #expect(result.trainingsCreated == 8)
        let again = try TrainingDataOperations.createExamples(in: context)
        #expect(again.exercisesCreated == 0)
        #expect(again.trainingsCreated == 0)

        let reader = ModelContext(container)
        let exercises = try reader.fetch(FetchDescriptor<Exercise>(sortBy: [SortDescriptor(\Exercise.sortOrder)]))
        #expect(exercises.map(\.name) == ["Press", "Kniebeuge", "Bankdrücken", "Kreuzheben"])
        #expect(exercises.compactMap(\.targetWeight) == [40, 100, 80, 130])
        #expect(exercises.map { $0.sortedSetTemplates.map(\.prescription) } == [
            ["1 × 5", "1 × 5"], ["1 × 5", "3 × 5"], ["1 × 5", "3 × 3"], ["1 × 5", "1 × 5", "3 × 5"]
        ])
        let trainings = try reader.fetch(FetchDescriptor<TrainingEntry>())
        #expect(trainings.count == 8)
        #expect(try reader.fetchCount(FetchDescriptor<SetGroup>()) == 18)
        #expect(trainings.allSatisfy { $0.effort == nil })
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        let days = TrainingDaySummary.grouped(trainings, calendar: calendar)
        let day = try #require(days.first)
        #expect(days.count == 2)
        let dateParts = calendar.dateComponents([.year, .month, .day], from: day.date)
        #expect(dateParts.year == 2026)
        #expect(dateParts.month == 11)
        #expect(dateParts.day == 17)
        #expect(day.entries.map { $0.exercise?.name ?? "" } == ["Press", "Kniebeuge", "Bankdrücken", "Kreuzheben"])
        #expect(day.entries.compactMap(\.workingWeight) == [52, 90, 85, 100])
        #expect(day.entries.compactMap { $0.workingGroup?.prescription } == ["1 × 5", "3 × 5", "3 × 3", "3 × 5"])
        let earlier = days[1]
        #expect(calendar.component(.day, from: earlier.date) == 14)
        #expect(earlier.entries.compactMap(\.workingWeight) == [50, 88, 83, 98])
        #expect(earlier.entries.map { $0.sortedGroups.dropLast().map(\.weight) } == [
            [40], [52], [50], [50, 70]
        ])

        // Simulate an installation that already has only the original November 17 examples.
        for entry in try context.fetch(FetchDescriptor<TrainingEntry>()) {
            if calendar.component(.day, from: entry.date) == 14 {
                try entry.deleteKeepingExercise(in: context)
            }
        }
        let supplemented = try TrainingDataOperations.createExamples(in: context)
        #expect(supplemented.exercisesCreated == 0)
        #expect(supplemented.trainingsCreated == 4)
        #expect(try context.fetchCount(FetchDescriptor<TrainingEntry>()) == 8)
    }

    @Test func groupedDaysKeepSeparateEntriesAndUseLocalDayBoundaries() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try #require(TimeZone(secondsFromGMT: 3600))
        let firstDate = try #require(calendar.date(from: DateComponents(year: 2026, month: 11, day: 17, hour: 0, minute: 5)))
        let lateDate = try #require(calendar.date(from: DateComponents(year: 2026, month: 11, day: 17, hour: 23, minute: 55)))
        let nextDate = try #require(calendar.date(from: DateComponents(year: 2026, month: 11, day: 18, hour: 0, minute: 5)))
        let exercise = Exercise(name: "Press", targetWeight: 40)
        let first = TrainingEntry(date: firstDate, exercise: exercise)
        let late = TrainingEntry(date: lateDate, exercise: exercise)
        let next = TrainingEntry(date: nextDate, exercise: exercise)
        let days = TrainingDaySummary.grouped([first, next, late], calendar: calendar)
        #expect(days.count == 2)
        #expect(days[0].entries.map(\.id) == [next.id])
        #expect(days[1].entries.map(\.id) == [late.id, first.id])
    }

    @Test func examplesReuseExistingExerciseAndDeleteAllClearsEveryModel() throws {
        let schema = Schema([Item.self, Exercise.self, TrainingEntry.self, SetGroup.self, ExerciseSetTemplate.self, TrainingDayNote.self])
        let container = try ModelContainer(
            for: schema,
            configurations: [ModelConfiguration(schema: schema, isStoredInMemoryOnly: true, cloudKitDatabase: .none)]
        )
        let context = ModelContext(container)
        let exercise = Exercise(name: "Press", targetWeight: 55)
        context.insert(exercise)
        let template = ExerciseSetTemplate(position: 0, prescription: "5 × 3", isWorking: true)
        context.insert(template)
        exercise.setTemplates.append(template)
        context.insert(Item(timestamp: Date()))
        try context.save()
        let result = try TrainingDataOperations.createExamples(in: context)
        #expect(result.exercisesCreated == 3)
        #expect(result.trainingsCreated == 8)
        #expect(exercise.targetWeight == 55)
        #expect(exercise.sortedSetTemplates.map(\.prescription) == ["5 × 3"])

        try TrainingDataOperations.deleteAll(in: context)
        let reader = ModelContext(container)
        #expect(try reader.fetchCount(FetchDescriptor<Exercise>()) == 0)
        #expect(try reader.fetchCount(FetchDescriptor<TrainingEntry>()) == 0)
        #expect(try reader.fetchCount(FetchDescriptor<SetGroup>()) == 0)
        #expect(try reader.fetchCount(FetchDescriptor<ExerciseSetTemplate>()) == 0)
        #expect(try reader.fetchCount(FetchDescriptor<Item>()) == 0)
        let recreated = try TrainingDataOperations.createExamples(in: context)
        #expect(recreated.exercisesCreated == 4)
        #expect(recreated.trainingsCreated == 8)
    }

    @Test func legacyTypeValuesRemainStrengthTraining() {
        let exercise = Exercise(name: "Bankdrücken", targetWeight: 80)
        exercise.activityTypeRawValue = nil
        let entry = TrainingEntry(date: Date(), exercise: exercise)
        entry.activityTypeRawValue = nil
        #expect(exercise.activityType == .strength)
        #expect(entry.activityType == .strength)
        exercise.activityType = .other
        #expect(entry.activityType == .strength)
    }

    @Test(arguments: ExerciseType.allCases)
    func allTypesPersistBothFieldsAndEveryRating(_ type: ExerciseType) throws {
        let schema = Schema([Item.self, Exercise.self, TrainingEntry.self, SetGroup.self, ExerciseSetTemplate.self, TrainingDayNote.self])
        let container = try ModelContainer(
            for: schema,
            configurations: [ModelConfiguration(schema: schema, isStoredInMemoryOnly: true, cloudKitDatabase: .none)]
        )
        let context = ModelContext(container)
        let exercise = Exercise(name: type.title, targetWeight: type.usesWeights ? 100 : nil, activityType: type)
        exercise.targetDescription = type == .sets ? "ohne Hilfe" : nil
        context.insert(exercise)
        let template = ExerciseSetTemplate(position: 0, prescription: type.usesSets ? "3 × 5" : "200 W", isWorking: type.usesSets, activityType: type, detailText: type.usesWeights ? nil : "30 min")
        context.insert(template)
        exercise.setTemplates.append(template)
        for effort in TrainingEffort.allCases {
            let entry = TrainingEntry(date: Date(), exercise: exercise)
            context.insert(entry)
            entry.effort = effort
            let group = SetGroup(position: 0, prescription: template.prescription, weight: type.usesWeights ? 60 : 0, isWorking: type.usesSets, detailText: type.usesWeights ? nil : "30 min")
            context.insert(group)
            entry.groups.append(group)
        }
        try context.save()
        let reader = ModelContext(container)
        let saved = try #require(reader.fetch(FetchDescriptor<Exercise>()).first)
        #expect(saved.activityType == type)
        #expect(saved.entries.count == 5)
        #expect(Set(saved.entries.compactMap(\.effortRawValue)) == Set(TrainingEffort.allCases.map(\.rawValue)))
        #expect(saved.sortedSetTemplates.first?.detailText == (type.usesWeights ? nil : "30 min"))
        #expect(saved.targetDescription == (type == .sets ? "ohne Hilfe" : nil))
        for entry in Array(saved.entries) {
            let group = try #require(entry.sortedGroups.first)
            #expect(entry.activityType == type)
            #expect(group.valueText(for: type) == (type.usesWeights ? "60 kg" : "30 min"))
            #expect(entry.workingWeight == (type.usesWeights ? 60 : nil))
            #expect((entry.workingGroup != nil) == type.usesSets)
            try entry.deleteKeepingExercise(in: reader)
        }
        let refreshed = ModelContext(container)
        #expect(try refreshed.fetchCount(FetchDescriptor<Exercise>()) == 1)
        #expect(try refreshed.fetchCount(FetchDescriptor<ExerciseSetTemplate>()) == 1)
        #expect(try refreshed.fetchCount(FetchDescriptor<SetGroup>()) == 0)
    }

    @Test(arguments: ["ergometer", "swimming", "jogging"])
    func retiredTypesKeepDataAsOther(_ rawValue: String) throws {
        let schema = Schema([Item.self, Exercise.self, TrainingEntry.self, SetGroup.self, ExerciseSetTemplate.self, TrainingDayNote.self])
        let container = try ModelContainer(
            for: schema,
            configurations: [ModelConfiguration(schema: schema, isStoredInMemoryOnly: true, cloudKitDatabase: .none)]
        )
        let context = ModelContext(container)
        let exercise = Exercise(name: "Altbestand", targetWeight: nil)
        exercise.activityTypeRawValue = rawValue
        context.insert(exercise)
        let template = ExerciseSetTemplate(position: 0, prescription: "Alte Vorlage", isWorking: false)
        template.activityTypeRawValue = rawValue
        context.insert(template)
        exercise.setTemplates.append(template)
        let entry = TrainingEntry(date: Date(), exercise: exercise)
        entry.activityTypeRawValue = rawValue
        context.insert(entry)
        let group = SetGroup(position: 0, prescription: "Alter Text\nmit Zeilenumbruch", weight: 0, isWorking: false)
        context.insert(group)
        entry.groups.append(group)
        try context.save()
        let reader = ModelContext(container)
        let saved = try #require(reader.fetch(FetchDescriptor<Exercise>()).first)
        #expect(saved.activityType == .other)
        #expect(saved.activityTypeRawValue == rawValue)
        #expect(saved.sortedSetTemplates.first?.prescription == "Alte Vorlage")
        #expect(saved.sortedSetTemplates.first?.activityType == .other)
        #expect(saved.latestEntry?.activityType == .other)
        #expect(saved.latestEntry?.freeTextSummary == "Alter Text\nmit Zeilenumbruch")
        #expect(saved.latestEntry?.sortedGroups.first?.detailText == nil)
        #expect(saved.latestEntry?.effort == nil)
    }

    @Test func unitValidationAndSummariesRespectType() {
        #expect(ExerciseType.allCases.map(\.title) == ["Krafttraining", "Satzübung", "Andere"])
        #expect(TrainingFormat.isValidUnit(prescription: "200 W", value: "", type: .other, isTemplate: true))
        #expect(TrainingFormat.isValidUnit(prescription: "200 W", value: "30 min", type: .other, isTemplate: true))
        #expect(TrainingFormat.isValidUnit(prescription: "", value: "30 min", type: .other))
        #expect(!TrainingFormat.isValidUnit(prescription: " ", value: "\n", type: .other))
        #expect(TrainingFormat.isValidUnit(prescription: "3 × 5", value: "", type: .sets, isTemplate: true))
        #expect(TrainingFormat.isValidUnit(prescription: "3 × 5", value: "ohne Hilfe", type: .sets))
        #expect(!TrainingFormat.isValidUnit(prescription: "3 × 5", value: "", type: .sets))
        #expect(!TrainingFormat.isValidUnit(prescription: "3 × 5", value: "ohne Hilfe", type: .strength))
        let group = SetGroup(position: 0, prescription: "200 W", weight: 0, isWorking: false, detailText: "30 min")
        #expect(group.summary(for: .other) == "200 W – 30 min")
        group.prescription = ""
        #expect(group.summary(for: .other) == "30 min")
        group.prescription = "3 × 5"
        group.detailText = "ohne Hilfe"
        #expect(group.summary(for: .sets) == "3 × 5 @ ohne Hilfe")
    }

    @Test func changingExerciseTypeRetainsEarlierTrainingAndStrengthDefaults() {
        let exercise = Exercise(name: "Training", targetWeight: 100)
        let template = ExerciseSetTemplate(position: 0, prescription: "3 × 5", isWorking: true)
        exercise.setTemplates = [template]
        let strength = TrainingEntry(date: Date(timeIntervalSince1970: 100), exercise: exercise)
        strength.groups = [SetGroup(position: 0, prescription: "3 × 5", weight: 60, isWorking: true)]
        strength.effort = .hard

        exercise.activityType = .other
        let running = TrainingEntry(date: Date(timeIntervalSince1970: 200), exercise: exercise)
        running.groups = [SetGroup(position: 0, prescription: "5 km locker", weight: 0, isWorking: false)]
        exercise.entries = [strength, running]
        #expect(exercise.progress == nil)
        #expect(exercise.latestEntryForCurrentType?.id == running.id)
        #expect(strength.activityType == .strength)
        #expect(strength.workingWeight == 60)
        #expect(strength.effort == .hard)
        #expect(exercise.targetWeight == 100)
        #expect(exercise.setTemplates.first?.id == template.id)

        exercise.activityType = .strength
        #expect(exercise.latestEntryForCurrentType?.id == strength.id)
        #expect(exercise.progress == 0.6)
        #expect(running.activityType == .other)
        #expect(running.freeTextSummary == "5 km locker")
    }

    @Test func strengthExamplesDoNotOverwriteAnExerciseWithAnotherType() throws {
        let schema = Schema([Item.self, Exercise.self, TrainingEntry.self, SetGroup.self, ExerciseSetTemplate.self, TrainingDayNote.self])
        let container = try ModelContainer(
            for: schema,
            configurations: [ModelConfiguration(schema: schema, isStoredInMemoryOnly: true, cloudKitDatabase: .none)]
        )
        let context = ModelContext(container)
        let exercise = Exercise(name: "Press", targetWeight: nil, activityType: .other)
        context.insert(exercise)
        let training = TrainingEntry(date: Date(), exercise: exercise)
        context.insert(training)
        let unit = SetGroup(position: 0, prescription: "Meine freie Einheit", weight: 0, isWorking: false)
        context.insert(unit)
        training.groups.append(unit)
        try context.save()

        let result = try TrainingDataOperations.createExamples(in: context)
        #expect(result.exercisesCreated == 3)
        #expect(result.trainingsCreated == 6)
        #expect(exercise.activityType == .other)
        #expect(exercise.entries.count == 1)
        #expect(exercise.latestEntry?.freeTextSummary == "Meine freie Einheit")
        #expect(exercise.setTemplates.isEmpty)
    }

    @Test func ratingRawValuesRemainCompatible() {
        #expect(TrainingEffort.allCases.map(\.title) == ["Sehr schwer", "Schwer", "Neutral", "Leicht", "Sehr leicht"])
        #expect(TrainingEffort(rawValue: "okay") == .okay)
        #expect(TrainingEffort(rawValue: "easy") == .easy)
        #expect(TrainingEffort.veryEasy.symbol == "++")
    }

    @Test func typedTemplatesPersistAndKeepTrainingIndependent() throws {
        let schema = Schema([Item.self, Exercise.self, TrainingEntry.self, SetGroup.self, ExerciseSetTemplate.self, TrainingDayNote.self])
        let container = try ModelContainer(
            for: schema,
            configurations: [ModelConfiguration(schema: schema, isStoredInMemoryOnly: true, cloudKitDatabase: .none)]
        )
        let context = ModelContext(container)
        let exercise = Exercise(name: "Training", targetWeight: 100, activityType: .other)
        context.insert(exercise)
        let legacy = ExerciseSetTemplate(position: 0, prescription: "3 × 5", isWorking: true)
        legacy.activityTypeRawValue = nil
        let warmup = ExerciseSetTemplate(position: 0, prescription: "5 Minuten locker", isWorking: false, activityType: .other)
        let work = ExerciseSetTemplate(position: 1, prescription: "100 W", isWorking: false, activityType: .other, detailText: "20 min")
        let running = ExerciseSetTemplate(position: 0, prescription: "3 × 5", isWorking: true, activityType: .sets, detailText: "ohne Hilfe")
        for template in [work, legacy, running, warmup] {
            context.insert(template)
            exercise.setTemplates.append(template)
        }
        let training = TrainingEntry(date: Date(), exercise: exercise)
        context.insert(training)
        for template in exercise.sortedSetTemplates {
            let group = SetGroup(position: template.position, prescription: template.prescription, weight: 0, isWorking: false, detailText: template.detailText)
            context.insert(group)
            training.groups.append(group)
        }
        // Updating a default must not alter an already recorded training.
        work.detailText = "25 min"
        try context.save()
        let reader = ModelContext(container)
        let saved = try #require(reader.fetch(FetchDescriptor<Exercise>()).first)
        #expect(saved.sortedSetTemplates.map(\.prescription) == ["5 Minuten locker", "100 W"])
        #expect(saved.sortedSetTemplates.last?.detailText == "25 min")
        #expect(saved.latestEntry?.freeTextSummary == "5 Minuten locker · 100 W – 20 min")
        saved.activityType = .strength
        #expect(saved.sortedSetTemplates.map(\.prescription) == ["3 × 5"])
        #expect(saved.sortedSetTemplates.first?.activityType == .strength)
        #expect(saved.sortedSetTemplates.first?.isWorking == true)
        saved.activityType = .sets
        #expect(saved.sortedSetTemplates.map(\.prescription) == ["3 × 5"])
        #expect(saved.sortedSetTemplates.first?.detailText == "ohne Hilfe")
        saved.activityType = .other
        try reader.save()
        let refreshed = ModelContext(container)
        let restored = try #require(refreshed.fetch(FetchDescriptor<Exercise>()).first)
        #expect(restored.setTemplates.count == 4)
        #expect(restored.sortedSetTemplates.map(\.prescription) == ["5 Minuten locker", "100 W"])
        let savedTraining = try #require(restored.latestEntry)
        try savedTraining.deleteKeepingExercise(in: refreshed)
        let afterDeletion = ModelContext(container)
        #expect(try afterDeletion.fetchCount(FetchDescriptor<ExerciseSetTemplate>()) == 4)
        #expect(try afterDeletion.fetchCount(FetchDescriptor<Exercise>()) == 1)
    }

    @Test func veryEasyRatingPersists() throws {
        let schema = Schema([Item.self, Exercise.self, TrainingEntry.self, SetGroup.self, ExerciseSetTemplate.self, TrainingDayNote.self])
        let container = try ModelContainer(
            for: schema,
            configurations: [ModelConfiguration(schema: schema, isStoredInMemoryOnly: true, cloudKitDatabase: .none)]
        )
        let context = ModelContext(container)
        let exercise = Exercise(name: "Press", targetWeight: 40)
        context.insert(exercise)
        let training = TrainingEntry(date: Date(), exercise: exercise)
        context.insert(training)
        training.effort = .veryEasy
        try context.save()
        let reader = ModelContext(container)
        let saved = try #require(reader.fetch(FetchDescriptor<TrainingEntry>()).first)
        #expect(saved.effort == .veryEasy)
        #expect(saved.effortRawValue == "veryEasy")
    }
}
