import SwiftUI
import UIKit

struct StoreFailureView: View {
    let error: Error
    @State private var copied = false

    private var failure: StoreOpenFailure? { error as? StoreOpenFailure }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Label("Daten konnten nicht geöffnet werden", systemImage: "externaldrive.badge.exclamationmark")
                        .font(.title2.bold())
                    Text("Deine vorhandenen Daten werden bei diesem Fehler nicht gelöscht. Bitte die App installiert lassen.")
                    Text(failure?.message ?? error.localizedDescription)
                        .foregroundStyle(.secondary)
                    if let report = failure?.report {
                        Button(copied ? "Diagnose kopiert" : "Diagnose kopieren", systemImage: copied ? "checkmark" : "doc.on.doc") {
                            UIPasteboard.general.string = report
                            copied = true
                        }
                        .buttonStyle(.borderedProminent)
                        ShareLink(item: report) {
                            Label("Diagnose teilen", systemImage: "square.and.arrow.up")
                        }
                        Text("Die Diagnose enthält Modellkennungen und Fehlercodes, keine Trainingsinhalte. Sie verändert deine Datenbank nicht.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        DisclosureGroup("Technische Details") {
                            Text(report)
                                .font(.caption.monospaced())
                                .textSelection(.enabled)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Trainuvo")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
