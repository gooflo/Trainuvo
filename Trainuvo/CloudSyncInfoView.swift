import SwiftUI
import CloudKit

struct CloudSyncInfoView: View {
    @Environment(\.scenePhase) private var phase
    @State private var accountInfo = "iCloud wird geprüft …"

    var body: some View {
        Section {
            LabeledContent("iCloud", value: accountInfo)
            Button("Accountstatus prüfen", systemImage: "arrow.clockwise") {
                Task { await refresh() }
            }
        } header: {
            Text("Synchronisierung")
        } footer: {
            Text("Übungen, Ziele, Vorlagen, Trainings und Tageskommentare werden mit deinen Geräten desselben Apple-Accounts abgeglichen. Offline kannst du weiterarbeiten. Änderungen werden zeitversetzt übertragen, nicht sofort. Der Accountstatus bestätigt noch keinen abgeschlossenen Datenabgleich.")
        }
        .task { await refresh() }
        .onChange(of: phase) { _, value in
            if value == .active { Task { await refresh() } }
        }
    }

    private func refresh() async {
        do {
            let status = try await CKContainer(identifier: "iCloud.com.vogtapps.Trainuvo").accountStatus()
            switch status {
            case .available: accountInfo = "Angemeldet"
            case .noAccount: accountInfo = "Nicht angemeldet"
            case .restricted: accountInfo = "Eingeschränkt"
            case .couldNotDetermine, .temporarilyUnavailable: accountInfo = "Vorübergehend nicht verfügbar"
            @unknown default: accountInfo = "Status unbekannt"
            }
        } catch {
            accountInfo = "Nicht verfügbar: \(error.localizedDescription)"
        }
    }
}
