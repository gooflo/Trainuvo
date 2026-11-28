import SwiftUI

struct BodyweightGoalCalculatorView: View {
    @State private var bodyweight = ""
    @FocusState private var inputFocused: Bool

    private var goals: [BodyweightGoalCalculator.Goal]? {
        BodyweightGoalCalculator.goals(for: bodyweight)
    }

    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Körpergewicht")
                    TextField("Gewicht", text: $bodyweight)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .focused($inputFocused)
                        .accessibilityLabel("Körpergewicht in Kilogramm")
                    Text("kg").foregroundStyle(.secondary)
                }
                if !bodyweight.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && goals == nil {
                    Text("Bitte gib ein gültiges Körpergewicht größer als 0 kg ein.")
                        .foregroundStyle(.red)
                }
            } header: {
                Text("Körpergewicht in kg")
            }
            Section {
                ForEach(BodyweightGoalCalculator.factors) { factor in
                    LabeledContent {
                        if let goal = goals?.first(where: { $0.name == factor.name }) {
                            Text("\(TrainingFormat.number(goal.weight)) kg")
                                .monospacedDigit()
                        } else {
                            Text("–").foregroundStyle(.secondary)
                        }
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(verbatim: factor.name)
                            Text("\(factor.percentage) % des Körpergewichts")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            } header: {
                Text("Zielgewichte")
            } footer: {
                Text("Lege die Übungen selbst an und übernimm die gewünschten Zielgewichte.")
            }
            Section {
                Text("Die verwendeten Zielwerte stammen von Work it Training Hamburg. Wenn du mehr über Training und Krafttraining erfahren möchtest, ist Work it meine persönliche Empfehlung.")
                Text("Empfehlung von Florian, Entwickler von Trainuvo.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                if let url = URL(string: "https://workittraining.de/") {
                    Link(destination: url) {
                        Label("Work it Training Hamburg", systemImage: "arrow.up.right.square")
                    }
                }
            }
        }
        .navigationTitle("Zielgewichte berechnen")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Fertig") { inputFocused = false }
            }
        }
    }
}
