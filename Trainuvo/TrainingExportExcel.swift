import Foundation

enum TrainingExportExcel {
    static func create(entries: [TrainingEntry], notes: [TrainingDayNote] = [], from: Date, to: Date) throws -> URL {
        let headers = ["Datum", "Übung", "Typ", "Bewertung", "Satzgruppe / Einheit", "Angabe links", "Gewicht (kg)", "Angabe rechts", "Arbeitsgruppe", "Training-ID", "Tageskommentar"]
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        var rows = "<row>" + headers.map(textCell).joined() + "</row>"
        let days = TrainingDaySummary.grouped(entries, notes: notes)
        for day in days {
            if day.entries.isEmpty {
                rows += "<row>" + ([formatter.string(from: day.date)] + Array(repeating: "", count: 9) + [day.noteText]).map(textCell).joined() + "</row>"
            }
            for entry in day.entries {
                let groups: [TrainingExport.Group?] = entry.sortedGroups.isEmpty ? [nil] : TrainingExport.snapshot([entry])[0].groups.map { Optional($0) }
                for group in groups {
                    let left = [formatter.string(from: entry.date), entry.exercise?.name ?? "Unbekannte Übung",
                                entry.activityType.title, entry.effort?.symbol ?? "",
                                group.map { String($0.position + 1) } ?? "", group?.prescription ?? ""]
                    rows += "<row>" + left.map(textCell).joined()
                    rows += group?.weight.map { "<c><v>\($0)</v></c>" } ?? textCell("")
                    rows += [group?.detailText ?? "", group.map { $0.isWorking ? "Ja" : "Nein" } ?? "", entry.id.uuidString, day.noteText].map(textCell).joined()
                    rows += "</row>"
                }
            }
        }
        let files = [
            ("[Content_Types].xml", """
            <Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/><Default Extension="xml" ContentType="application/xml"/><Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/><Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/></Types>
            """),
            ("_rels/.rels", """
            <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/></Relationships>
            """),
            ("xl/workbook.xml", """
            <workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><sheets><sheet name="Trainings" sheetId="1" r:id="rId1"/></sheets></workbook>
            """),
            ("xl/_rels/workbook.xml.rels", """
            <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/></Relationships>
            """),
            ("xl/worksheets/sheet1.xml", """
            <worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><sheetViews><sheetView workbookViewId="0"><pane ySplit="1" topLeftCell="A2" activePane="bottomLeft" state="frozen"/></sheetView></sheetViews><cols><col min="1" max="1" width="14" customWidth="1"/><col min="2" max="11" width="24" customWidth="1"/></cols><sheetData>\(rows)</sheetData></worksheet>
            """)
        ]
        let url = try TrainingExport.fileURL(from: from, to: to, extension: "xlsx")
        try archive(files).write(to: url, options: .atomic)
        return url
    }

    nonisolated private static func textCell(_ value: String) -> String {
        "<c t=\"inlineStr\"><is><t xml:space=\"preserve\">\(xmlText(value))</t></is></c>"
    }

    nonisolated private static func xmlText(_ value: String) -> String {
        let valid = String(String.UnicodeScalarView(value.unicodeScalars.filter {
            switch $0.value {
            case 9, 10, 13, 32...0xD7FF, 0xE000...0xFFFD, 0x10000...0x10FFFF: true
            default: false
            }
        }))
        return valid
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
    }

    // XLSX is a ZIP of XML parts. These entries use the uncompressed ZIP method.
    private static func archive(_ files: [(String, String)]) throws -> Data {
        var archive = Data()
        var directory = Data()

        for (path, xml) in files {
            let name = Data(path.utf8)
            let bytes = Data(xml.utf8)
            guard let size = UInt32(exactly: bytes.count),
                  let offset = UInt32(exactly: archive.count) else {
                throw ExportError.fileTooLarge
            }
            let checksum = crc32(bytes)
            let nameLength = UInt16(name.count)

            archive.appendLE(UInt32(0x04034B50))
            appendEntryFields(to: &archive, checksum: checksum, size: size, nameLength: nameLength)
            archive.append(name)
            archive.append(bytes)

            directory.appendLE(UInt32(0x02014B50))
            directory.appendLE(UInt16(20))
            appendEntryFields(to: &directory, checksum: checksum, size: size, nameLength: nameLength)
            directory.appendLE(UInt16(0)) // Comment length
            directory.appendLE(UInt16(0)) // Disk number
            directory.appendLE(UInt16(0)) // Internal attributes
            directory.appendLE(UInt32(0)) // External attributes
            directory.appendLE(offset)
            directory.append(name)
        }

        guard let directorySize = UInt32(exactly: directory.count),
              let directoryOffset = UInt32(exactly: archive.count) else {
            throw ExportError.fileTooLarge
        }
        archive.append(directory)
        archive.appendLE(UInt32(0x06054B50))
        archive.appendLE(UInt16(0))
        archive.appendLE(UInt16(0))
        archive.appendLE(UInt16(files.count))
        archive.appendLE(UInt16(files.count))
        archive.appendLE(directorySize)
        archive.appendLE(directoryOffset)
        archive.appendLE(UInt16(0))
        return archive
    }

    private static func appendEntryFields(
        to data: inout Data, checksum: UInt32, size: UInt32, nameLength: UInt16
    ) {
        data.appendLE(UInt16(20)) // Minimum ZIP version
        data.appendLE(UInt16(0)) // Flags
        data.appendLE(UInt16(0)) // Stored compression method
        data.appendLE(UInt16(0)) // DOS time
        data.appendLE(UInt16(33)) // DOS date: 1980-01-01
        data.appendLE(checksum)
        data.appendLE(size)
        data.appendLE(size)
        data.appendLE(nameLength)
        data.appendLE(UInt16(0)) // Extra field length
    }

    private static func crc32(_ data: Data) -> UInt32 {
        var crc = UInt32.max
        for byte in data {
            crc ^= UInt32(byte)
            for _ in 0..<8 {
                crc = (crc >> 1) ^ (crc & 1 == 0 ? 0 : 0xEDB88320)
            }
        }
        return ~crc
    }

    private enum ExportError: LocalizedError {
        case fileTooLarge

        var errorDescription: String? {
            String(localized: "Excel-Datei konnte nicht erstellt werden.")
        }
    }
}

private extension Data {
    mutating func appendLE<T: FixedWidthInteger>(_ value: T) {
        var littleEndian = value.littleEndian
        Swift.withUnsafeBytes(of: &littleEndian) { append(contentsOf: $0) }
    }
}
