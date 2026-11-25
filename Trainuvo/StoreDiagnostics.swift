import Foundation
import CoreData
import SwiftData

struct StoreOpenFailure: Error {
    let message: String
    let report: String
}

@MainActor
enum StoreDiagnostics {
    // Diagnostic only: never instantiate a container, migrate, repair or write metadata here.
    static func report(error: Error, storeURL: URL) -> String {
        let bundle = Bundle.main
        let version = bundle.object(forInfoDictionaryKey: "TrainuvoInternalVersion") as? String ?? "0.14.3"
        let external = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?"
        let build = bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "?"
        var lines = [
            "Trainuvo – Speicherdiagnose 1",
            "Intern: \(version); extern: \(external) (\(build))",
            "System: \(ProcessInfo.processInfo.operatingSystemVersionString)",
            "Fehlertyp: \(String(reflecting: type(of: error)))",
            "Datenbank vorhanden: \(FileManager.default.fileExists(atPath: storeURL.path))",
            "Keine Trainingsinhalte, Accountkennungen oder Dateipfade enthalten.",
            ""
        ]
        lines += errorCodes(error)
        var metadata: [String: Any]?
        if FileManager.default.fileExists(atPath: storeURL.path) {
            do {
                metadata = try metadataFromTemporaryCopy(of: storeURL)
                if let metadata {
                    lines += ["", "Gespeicherte Modellversionen: \(identifiers(metadata[NSStoreModelVersionIdentifiersKey]))"]
                    let checksum = metadata["NSStoreModelVersionChecksumKey"] as? String ?? "nicht verfügbar"
                    lines.append("Gespeicherte Modell-Prüfsumme: \(checksum)")
                    let hashes = metadata[NSStoreModelVersionHashesKey] as? [String: Data] ?? [:]
                    lines += hashLines(hashes, label: "Store")
                }
            } catch {
                lines += ["", "Metadaten konnten nicht gelesen werden."] + errorCodes(error)
            }
        }
        let versions: [(String, Schema, [any PersistentModel.Type])] = [
            ("Vor Tageskommentaren (5 Modelle)", Schema(TrainuvoSchemaBeforeDayNotes.models), TrainuvoSchemaBeforeDayNotes.models),
            ("V1 (Build 3, unversioniert)", Schema(TrainuvoSchemaV1.models), TrainuvoSchemaV1.models),
            ("V1 (versioniert)", Schema(versionedSchema: TrainuvoSchemaV1.self), TrainuvoSchemaV1.models),
            ("V2 (Build 4–7)", Schema(versionedSchema: TrainuvoSchemaV2.self), TrainuvoSchemaV2.models),
            ("V3 (Sichtbarkeit)", Schema(versionedSchema: TrainuvoSchemaV3.self), TrainuvoSchemaV3.models),
            ("V4 (Satz-Checkboxen)", Schema(versionedSchema: TrainuvoSchemaV4.self), TrainuvoSchemaV4.models)
        ]
        for (name, schema, types) in versions {
            lines += ["", name]
            let referenceModel: NSManagedObjectModel?
            if #available(iOS 26, *) {
                referenceModel = NSManagedObjectModel.makeManagedObjectModel(for: schema)
            } else {
                referenceModel = NSManagedObjectModel.makeManagedObjectModel(for: types)
                lines.append("Referenz über Modelltypen (System vor iOS 26)")
            }
            guard let model = referenceModel else {
                lines.append("Referenzmodell nicht verfügbar.")
                continue
            }
            lines.append("Modell-Prüfsumme: \(model.versionChecksum)")
            lines += hashLines(model.entityVersionHashesByName, label: "Referenz")
            if let metadata {
                lines.append("Kompatibel: \(model.isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata))")
                let stored = metadata[NSStoreModelVersionHashesKey] as? [String: Data] ?? [:]
                let reference = model.entityVersionHashesByName
                let names = Set(stored.keys).union(reference.keys).sorted()
                lines.append("Abweichende Entitäten: " + names.filter { stored[$0] != reference[$0] }.joined(separator: ", "))
            }
        }
        return lines.joined(separator: "\n")
    }


    private static func metadataFromTemporaryCopy(of storeURL: URL) throws -> [String: Any] {
        let manager = FileManager.default
        let directory = manager.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try manager.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? manager.removeItem(at: directory) }
        let copyURL = directory.appendingPathComponent("diagnostic.store")

        // Never pass the original URL to Core Data. Even metadata access can
        // cause SQLite housekeeping/checkpointing. Include uncheckpointed data.
        // Do not copy -shm; SQLite must rebuild its transient index in the copy.
        for suffix in ["", "-wal", "-journal"] {
            let source = URL(fileURLWithPath: storeURL.path + suffix)
            if manager.fileExists(atPath: source.path) {
                try manager.copyItem(at: source, to: URL(fileURLWithPath: copyURL.path + suffix))
            }
        }
        return try NSPersistentStoreCoordinator.metadataForPersistentStore(
            ofType: NSSQLiteStoreType,
            at: copyURL,
            options: [NSReadOnlyPersistentStoreOption: true]
        )
    }

    private static func hashLines(_ hashes: [String: Data], label: String) -> [String] {
        hashes.keys.sorted().map { "\(label) \($0): \(hashes[$0]!.base64EncodedString())" }
    }

    private static func identifiers(_ value: Any?) -> String {
        if let values = value as? [String] { return values.sorted().joined(separator: ", ") }
        if let values = value as? Set<String> { return values.sorted().joined(separator: ", ") }
        return "nicht verfügbar"
    }

    private static func errorCodes(_ error: Error, depth: Int = 0) -> [String] {
        let value = error as NSError
        var lines = ["Fehler[\(depth)]: \(value.domain) / \(value.code)"]
        // Deliberately omit localizedDescription and arbitrary userInfo: validation
        // messages can contain training text or a complete private store path.
        if depth < 3, let underlying = value.userInfo[NSUnderlyingErrorKey] as? NSError {
            lines += errorCodes(underlying, depth: depth + 1)
        }
        return lines
    }
}
