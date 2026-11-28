import SwiftUI
import UIKit

struct TrainingExportFileNameView: View {
    let sourceURL: URL

    @Environment(\.dismiss) private var dismiss
    @State private var fileName: String
    @State private var sharedFile: SharedFile?
    @State private var errorMessage: String?
    @FocusState private var nameFocused: Bool

    private struct SharedFile: Identifiable {
        let id = UUID()
        let url: URL
    }

    init(sourceURL: URL) {
        self.sourceURL = sourceURL
        _fileName = State(initialValue: sourceURL.deletingPathExtension().lastPathComponent)
    }

    private var exportName: String {
        TrainingExportFileName.baseName(fileName, extension: sourceURL.pathExtension) ?? ""
    }

    private var validName: Bool { !exportName.isEmpty }

    var body: some View {
        NavigationStack {
            Form {
                Section("Dateiname") {
                    HStack(spacing: 0) {
                        TextField("Dateiname", text: $fileName)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .focused($nameFocused)
                            .submitLabel(.done)
                            .onSubmit { nameFocused = false }
                        Text("." + sourceURL.pathExtension)
                            .foregroundStyle(.secondary)
                            .fixedSize()
                    }
                }
                if !validName {
                    Text("Gib einen Dateinamen ohne Schrägstrich, Doppelpunkt oder Steuerzeichen ein.")
                        .foregroundStyle(.red)
                }
            }
            .navigationTitle("Datei exportieren")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen / Cancel", role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Teilen", action: shareFile)
                        .disabled(!validName)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Fertig") { nameFocused = false }
                }
            }
            .sheet(item: $sharedFile) { file in
                TrainingActivityShareView(items: [file.url])
            }
            .alert("Export fehlgeschlagen", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    private func shareFile() {
        nameFocused = false
        let suffix = "." + sourceURL.pathExtension
        guard validName else { return }

        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            let destination = directory.appendingPathComponent(exportName + suffix)
            try FileManager.default.copyItem(at: sourceURL, to: destination)
            sharedFile = SharedFile(url: destination)
        } catch {
            try? FileManager.default.removeItem(at: directory)
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - iOS-Teilen-Menü

private struct TrainingActivityShareView: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(
        context: Context
    ) -> UIActivityViewController {
        UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
    }

    func updateUIViewController(
        _ uiViewController: UIActivityViewController,
        context: Context
    ) {}
}

