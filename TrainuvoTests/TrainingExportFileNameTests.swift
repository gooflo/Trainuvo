import Foundation
import Testing
@testable import Trainuvo

@MainActor
struct TrainingExportFileNameTests {
    @Test func namesKeepUnicodeAndAvoidDuplicateExtension() {
        #expect(TrainingExportFileName.baseName(" Trainuvo_Export ", extension: "txt") == "Trainuvo_Export")
        #expect(TrainingExportFileName.baseName("Training November.json", extension: "json") == "Training November")
        #expect(TrainingExportFileName.baseName("Übungen.XLSX", extension: "xlsx") == "Übungen")
    }

    @Test(arguments: ["", " ", ".", "..", ".json", "a/b", "a\\b", "a:b", "a\nb", "a\tb"])
    func invalidNamesAreRejected(_ name: String) {
        #expect(TrainingExportFileName.baseName(name, extension: "json") == nil)
    }

    @Test func allFormatsHaveSimpleDefaultAndSeparateDirectories() throws {
        var folders = Set<URL>()
        defer { for folder in folders { try? FileManager.default.removeItem(at: folder) } }
        for suffix in ["txt", "xlsx", "json"] {
            let url = try TrainingExport.fileURL(from: Date(), to: Date(), extension: suffix)
            #expect(url.lastPathComponent == "Trainuvo_Export.\(suffix)")
            #expect(folders.insert(url.deletingLastPathComponent()).inserted)
        }
    }
}
