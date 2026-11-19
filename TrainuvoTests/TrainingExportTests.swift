import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif
import Testing
@testable import Trainuvo

@MainActor
struct TrainingExportTests {
    private func calendar() throws -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try #require(TimeZone(identifier: "Europe/Berlin"))
        return calendar
    }

    @Test func inclusiveDateRangeHandlesDaylightSavingAndEmptyRanges() throws {
        let cal = try calendar()
        let start = try #require(cal.date(from: DateComponents(year: 2026, month: 10, day: 25)))
        let end = try #require(cal.date(byAdding: .day, value: 1, to: start))
        #expect(end.timeIntervalSince(start) == 25 * 3600)
        let exercise = Exercise(name: "Test", targetWeight: nil)
        let first = TrainingEntry(date: start, exercise: exercise)
        let late = TrainingEntry(date: end.addingTimeInterval(-1), exercise: exercise)
        let next = TrainingEntry(date: end, exercise: exercise)
        let before = TrainingEntry(date: start.addingTimeInterval(-1), exercise: exercise)
        #expect(TrainingExport.selected([next, late, before, first], from: start, to: start, calendar: cal).map(\.id) == [first.id, late.id])
        #expect(TrainingExport.selected([first], from: end, to: start, calendar: cal).isEmpty)
        #expect(TrainingExport.selected([], from: start, to: start, calendar: cal).isEmpty)
    }

    @Test func oneNoteKeepsOneLinePerDayAndOnlyWorkingSets() throws {
        let cal = try calendar()
        let date = try #require(cal.date(from: DateComponents(year: 2026, month: 11, day: 17, hour: 12)))
        let press = Exercise(name: "Press", targetWeight: 40)
        let cardio = Exercise(name: "Ergometer", targetWeight: nil, activityType: .other)
        cardio.sortOrder = 1
        let training = TrainingEntry(date: date, exercise: press)
        training.effort = .easy
        training.groups = [
            SetGroup(position: 0, prescription: "1×5", weight: 40, isWorking: false),
            SetGroup(position: 1, prescription: "3×5", weight: 52, isWorking: true)
        ]
        let other = TrainingEntry(date: date, exercise: cardio)
        other.effort = .okay
        other.groups = [
            SetGroup(position: 0, prescription: "200 W\nlocker", weight: 0, isWorking: false, detailText: "30 min"),
            SetGroup(position: 1, prescription: "", weight: 0, isWorking: false, detailText: "5 min Pause")
        ]
        let earlier = TrainingEntry(date: date.addingTimeInterval(-86400), exercise: press)
        earlier.groups = [SetGroup(position: 0, prescription: "1×5", weight: 50, isWorking: true)]
        let text = TrainingExport.text([other, training, earlier], calendar: cal)
        #expect(text == "16.11.2026 | Press 1×5 @ 50 kg\n17.11.2026 | Press + 3×5 @ 52 kg | Ergometer o 200 W locker / 30 min; 5 min Pause")
        #expect(text.components(separatedBy: "\n").count == 2)
        #expect(!text.contains("40 kg"))
        #expect(TrainingExport.text([]).isEmpty)
    }

    @Test func jsonPreservesIDsAllGroupsAndFreeFields() throws {
        let exercise = Exercise(name: "Klimmzüge", targetWeight: nil, activityType: .sets)
        exercise.targetDescription = "ohne Hilfe"
        let entry = TrainingEntry(date: Date(), exercise: exercise)
        entry.effort = .veryEasy
        entry.groups = [
            SetGroup(position: 0, prescription: "1×3", weight: 0, isWorking: false, detailText: "mit Band"),
            SetGroup(position: 1, prescription: "3×5", weight: 0, isWorking: true, detailText: "ohne Hilfe")
        ]
        let bytes = try TrainingExport.json([entry], from: entry.date, to: entry.date)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let document = try decoder.decode(TrainingExport.Document.self, from: bytes)
        let saved = try #require(document.entries.first)
        #expect(document.schemaVersion == 1)
        #expect(saved.id == entry.id)
        #expect(saved.exerciseID == exercise.id)
        #expect(saved.type == "sets")
        #expect(saved.effort == "veryEasy")
        #expect(saved.targetDescription == "ohne Hilfe")
        #expect(saved.groups.map(\.id) == entry.sortedGroups.map(\.id))
        #expect(saved.groups.map(\.detailText) == ["mit Band", "ohne Hilfe"])
        #expect(saved.groups.allSatisfy { $0.weight == nil })
    }

    @Test func excelContainsValidXMLAndLiteralUserText() throws {
        let exercise = Exercise(name: "=1+1 & <Test>", targetWeight: 100)
        let entry = TrainingEntry(date: Date(), exercise: exercise)
        entry.groups = [
            SetGroup(position: 0, prescription: "1×5", weight: 40, isWorking: false),
            SetGroup(position: 1, prescription: "3×5", weight: 60.5, isWorking: true)
        ]
        let url = try TrainingExportExcel.create(entries: [entry], from: entry.date, to: entry.date)
        defer { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }
        #expect(url.pathExtension == "xlsx")
        #expect(url.lastPathComponent.hasPrefix("Trainuvo_Export_"))
        let parts = try storedParts(Data(contentsOf: url))
        #expect(parts.count == 5)
        for (_, bytes) in parts { #expect(XMLParser(data: bytes).parse()) }
        let sheet = try #require(parts["xl/worksheets/sheet1.xml"])
        let xml = String(decoding: sheet, as: UTF8.self)
        #expect(xml.contains("=1+1 &amp; &lt;Test&gt;"))
        #expect(!xml.contains("<f>"))
        #expect(xml.contains("<v>40.0</v>") || xml.contains("<v>40</v>"))
        #expect(xml.contains("<v>60.5</v>"))
        #expect(xml.components(separatedBy: "<row>").count == 4)
        #expect(xml.contains("Ja"))
        #expect(xml.contains("Nein"))
    }

    // Read stored ZIP entries independently of the writer and check their CRCs.
    private func storedParts(_ data: Data) throws -> [String: Data] {
        let bytes = Array(data)
        func uint(_ offset: Int, _ count: Int) throws -> UInt32 {
            #expect(offset >= 0 && offset + count <= bytes.count)
            guard offset >= 0, offset + count <= bytes.count else { throw CocoaError(.fileReadCorruptFile) }
            return (0..<count).reduce(UInt32(0)) { $0 | UInt32(bytes[offset + $1]) << ($1 * 8) }
        }
        var offset = 0
        var parts: [String: Data] = [:]
        while try uint(offset, 4) == 0x04034B50 {
            #expect(try uint(offset + 8, 2) == 0)
            let checksum = try uint(offset + 14, 4)
            let size = Int(try uint(offset + 18, 4))
            let nameLength = Int(try uint(offset + 26, 2))
            let extra = Int(try uint(offset + 28, 2))
            let start = offset + 30 + nameLength + extra
            guard start + size <= bytes.count else { throw CocoaError(.fileReadCorruptFile) }
            let name = String(decoding: bytes[(offset + 30)..<(offset + 30 + nameLength)], as: UTF8.self)
            let payload = Data(bytes[start..<(start + size)])
            var crc = UInt32.max
            for byte in payload {
                crc ^= UInt32(byte)
                for _ in 0..<8 { crc = (crc >> 1) ^ (crc & 1 == 0 ? 0 : 0xEDB88320) }
            }
            #expect(~crc == checksum)
            parts[name] = payload
            offset = start + size
        }
        #expect(try uint(offset, 4) == 0x02014B50)
        return parts
    }
}
