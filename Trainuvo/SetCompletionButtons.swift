import SwiftUI

struct SetCompletionButtons: View {
    let prescription: String
    @Binding var completed: Set<Int>

    private var count: Int { TrainingSetProgress.count(for: prescription) }

    var body: some View {
        if count > 0 {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(1...count, id: \.self) { number in
                        Button {
                            if completed.contains(number) {
                                completed.remove(number)
                            } else {
                                completed.insert(number)
                            }
                        } label: {
                            Image(systemName: completed.contains(number) ? "checkmark.square.fill" : "square")
                                .foregroundStyle(completed.contains(number) ? Color.blue : Color.secondary)
                                .font(.body)
                                .frame(width: 22, height: 44)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.borderless)
                        .accessibilityLabel("Satz \(number) von \(count)")
                        .accessibilityValue(completed.contains(number) ? "Erledigt" : "Offen")
                        .accessibilityAddTraits(completed.contains(number) ? .isSelected : [])
                    }
                }
            }
            .frame(width: CGFloat(min(count, 5)) * 22, height: 44)
        }
    }
}
