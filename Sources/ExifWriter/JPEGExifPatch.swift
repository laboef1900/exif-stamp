import Foundation

/// Rewrites JPEG APP1 EXIF without touching the entropy-coded scan data.
enum JPEGExifPatch {
    static func writeCaptureDate(_ date: Date, timeZone: TimeZone, at url: URL) throws {
        let formatted = ExifDateFormatter.string(from: date, timeZone: timeZone)
        let offset = ExifWriter.formatOffset(timeZone, for: date)
        let original = try Data(contentsOf: url)
        guard original.count >= 4, original[0] == 0xFF, original[1] == 0xD8 else {
            throw DateOperationError.couldNotReadImage(path: url.path)
        }
        let rebuilt = try patch(original, dateTime: formatted, offsetTime: offset)
        let tempURL = url.deletingLastPathComponent()
            .appendingPathComponent(".c1dp-\(UUID().uuidString).tmp")
        do {
            try rebuilt.write(to: tempURL, options: .atomic)
            _ = try FileManager.default.replaceItemAt(url, withItemAt: tempURL)
        } catch {
            try? FileManager.default.removeItem(at: tempURL)
            throw DateOperationError.writeFailed(path: url.path, underlying: error.localizedDescription)
        }
    }

    static func patch(_ jpeg: Data, dateTime: String, offsetTime: String) throws -> Data {
        let soi = jpeg.prefix(2)
        var pos = 2
        var jfif = Data()
        var others: [Data] = []
        var existingTIFF: Data?
        while pos + 4 <= jpeg.count, jpeg[pos] == 0xFF {
            let marker = jpeg[pos + 1]
            if marker == 0xDA || marker == 0xD9 { break }
            if marker == 0x00 || (marker >= 0xD0 && marker <= 0xD7) {
                throw DateOperationError.writeFailed(path: "", underlying: "Unexpected RST before SOS")
            }
            let length = Int(jpeg[pos + 2]) << 8 | Int(jpeg[pos + 3])
            guard length >= 2, pos + 2 + length <= jpeg.count else {
                throw DateOperationError.writeFailed(path: "", underlying: "Truncated JPEG marker")
            }
            let segment = Data(jpeg[pos ..< (pos + 2 + length)])
            pos += 2 + length
            if marker == 0xE1, segment.count >= 10,
               segment[4..<10].elementsEqual(Data("Exif\0\0".utf8)) {
                existingTIFF = Data(segment.dropFirst(10))
            } else if marker == 0xE0 {
                jfif = segment
            } else {
                others.append(segment)
            }
        }
        let tail = jpeg[pos...]
        let tiff = try TIFFExif.upsert(existing: existingTIFF, dateTime: dateTime, offsetTime: offsetTime)
        var app1 = Data([0xFF, 0xE1, 0x00, 0x00])
        app1.append(contentsOf: "Exif\0\0".utf8)
        app1.append(tiff)
        let app1Len = app1.count - 2
        app1[2] = UInt8((app1Len >> 8) & 0xFF)
        app1[3] = UInt8(app1Len & 0xFF)

        var out = Data()
        out.append(soi)
        out.append(jfif)
        out.append(app1)
        for seg in others { out.append(seg) }
        out.append(tail)
        return out
    }
}

/// Minimal TIFF rewriter for IFD0 + ExifIFD (+ GPS IFD copied through).
private enum TIFFExif {
    static let typeASCII: UInt16 = 2
    static let typeLong: UInt16 = 4
    static let tagDateTime: UInt16 = 0x0132
    static let tagExifIFD: UInt16 = 0x8769
    static let tagGPSIFD: UInt16 = 0x8825
    static let tagDateTimeOriginal: UInt16 = 0x9003
    static let tagDateTimeDigitized: UInt16 = 0x9004
    static let tagOffsetTimeOriginal: UInt16 = 0x9011
    static let tagOffsetTimeDigitized: UInt16 = 0x9012

    struct Entry {
        var tag: UInt16
        var type: UInt16
        var count: UInt32
        var data: Data
    }

    static func upsert(existing: Data?, dateTime: String, offsetTime: String) throws -> Data {
        let dt = asciiData(dateTime)
        let off = asciiData(offsetTime)
        if let existing, existing.count >= 8 {
            return try update(existing, dateTime: dt, offsetTime: off)
        }
        return buildNew(dateTime: dt, offsetTime: off)
    }

    private static func asciiData(_ s: String) -> Data {
        var d = Data(s.utf8)
        d.append(0)
        return d
    }

    private static func buildNew(dateTime: Data, offsetTime: Data) -> Data {
        var ifd0 = [
            Entry(tag: tagDateTime, type: typeASCII, count: UInt32(dateTime.count), data: dateTime),
            Entry(tag: tagExifIFD, type: typeLong, count: 1, data: Data(count: 4)),
        ]
        let exif = [
            Entry(tag: tagDateTimeOriginal, type: typeASCII, count: UInt32(dateTime.count), data: dateTime),
            Entry(tag: tagDateTimeDigitized, type: typeASCII, count: UInt32(dateTime.count), data: dateTime),
            Entry(tag: tagOffsetTimeOriginal, type: typeASCII, count: UInt32(offsetTime.count), data: offsetTime),
            Entry(tag: tagOffsetTimeDigitized, type: typeASCII, count: UInt32(offsetTime.count), data: offsetTime),
        ]
        return serialize(ifd0: &ifd0, exif: exif, gps: nil, littleEndian: true)
    }

    private static func update(_ tiff: Data, dateTime: Data, offsetTime: Data) throws -> Data {
        let little = tiff[0] == 0x49
        guard (little && tiff[1] == 0x49) || (!little && tiff[0] == 0x4D && tiff[1] == 0x4D) else {
            throw DateOperationError.writeFailed(path: "", underlying: "Invalid TIFF header in EXIF")
        }
        func u16(_ o: Int) -> UInt16 {
            little ? UInt16(tiff[o]) | UInt16(tiff[o + 1]) << 8
                   : UInt16(tiff[o]) << 8 | UInt16(tiff[o + 1])
        }
        func u32(_ o: Int) -> UInt32 {
            little ? UInt32(tiff[o]) | UInt32(tiff[o + 1]) << 8 | UInt32(tiff[o + 2]) << 16 | UInt32(tiff[o + 3]) << 24
                   : UInt32(tiff[o]) << 24 | UInt32(tiff[o + 1]) << 16 | UInt32(tiff[o + 2]) << 8 | UInt32(tiff[o + 3])
        }
        func typeSize(_ t: UInt16) -> Int {
            switch t {
            case 1, 2, 6, 7: return 1
            case 3, 8: return 2
            case 4, 9, 11: return 4
            case 5, 10, 12: return 8
            default: return 1
            }
        }
        func parseIFD(_ offset: Int) -> [Entry] {
            guard offset + 2 <= tiff.count else { return [] }
            let n = Int(u16(offset))
            var entries: [Entry] = []
            for i in 0..<n {
                let e = offset + 2 + i * 12
                guard e + 12 <= tiff.count else { break }
                let tag = u16(e)
                let type = u16(e + 2)
                let count = u32(e + 4)
                let byteCount = Int(count) * typeSize(type)
                let data: Data
                if byteCount <= 4 {
                    data = Data(tiff[(e + 8) ..< (e + 8 + min(4, tiff.count - (e + 8)))].prefix(byteCount))
                } else {
                    let off = Int(u32(e + 8))
                    guard off + byteCount <= tiff.count else { continue }
                    data = Data(tiff[off ..< (off + byteCount)])
                }
                entries.append(Entry(tag: tag, type: type, count: count, data: data))
            }
            return entries
        }
        func pointer(_ entries: [Entry], tag: UInt16) -> Int? {
            guard let e = entries.first(where: { $0.tag == tag }), e.data.count >= 4 else { return nil }
            let b = [UInt8](e.data)
            if little { return Int(b[0]) | Int(b[1]) << 8 | Int(b[2]) << 16 | Int(b[3]) << 24 }
            return Int(b[0]) << 24 | Int(b[1]) << 16 | Int(b[2]) << 8 | Int(b[3])
        }

        let ifd0off = Int(u32(4))
        var ifd0 = parseIFD(ifd0off)
        var exif = pointer(ifd0, tag: tagExifIFD).map(parseIFD) ?? []
        let gps = pointer(ifd0, tag: tagGPSIFD).map(parseIFD)

        func upsert(_ list: inout [Entry], tag: UInt16, type: UInt16, data: Data) {
            let entry = Entry(tag: tag, type: type, count: UInt32(data.count), data: data)
            if let i = list.firstIndex(where: { $0.tag == tag }) { list[i] = entry }
            else { list.append(entry) }
        }
        upsert(&ifd0, tag: tagDateTime, type: typeASCII, data: dateTime)
        upsert(&exif, tag: tagDateTimeOriginal, type: typeASCII, data: dateTime)
        upsert(&exif, tag: tagDateTimeDigitized, type: typeASCII, data: dateTime)
        upsert(&exif, tag: tagOffsetTimeOriginal, type: typeASCII, data: offsetTime)
        upsert(&exif, tag: tagOffsetTimeDigitized, type: typeASCII, data: offsetTime)
        if ifd0.first(where: { $0.tag == tagExifIFD }) == nil {
            ifd0.append(Entry(tag: tagExifIFD, type: typeLong, count: 1, data: Data(count: 4)))
        }
        return serialize(ifd0: &ifd0, exif: exif, gps: gps, littleEndian: little)
    }

    private static func serialize(ifd0: inout [Entry], exif: [Entry], gps: [Entry]?, littleEndian: Bool) -> Data {
        let exifSorted = exif.sorted { $0.tag < $1.tag }
        let gpsSorted = gps?.sorted { $0.tag < $1.tag }

        func ifdSize(_ n: Int) -> Int { 2 + 12 * n + 4 }
        func extraSize(_ entries: [Entry]) -> Int {
            entries.reduce(0) { $0 + ($1.data.count > 4 ? ($1.data.count + 1) & ~1 : 0) }
        }

        let header = 8
        let ifd0Size = ifdSize(ifd0.count)
        let ifd0Extra = extraSize(ifd0.filter { $0.tag != tagExifIFD && $0.tag != tagGPSIFD })
        let exifOff = header + ifd0Size + ifd0Extra
        let exifSize = ifdSize(exifSorted.count)
        let exifExtra = extraSize(exifSorted)
        let gpsOff = exifOff + exifSize + exifExtra
        let gpsSize = gpsSorted.map { ifdSize($0.count) } ?? 0
        let gpsExtra = gpsSorted.map(extraSize) ?? 0

        func putU16(_ v: UInt16, into d: inout Data) {
            if littleEndian {
                d.append(UInt8(v & 0xFF)); d.append(UInt8(v >> 8))
            } else {
                d.append(UInt8(v >> 8)); d.append(UInt8(v & 0xFF))
            }
        }
        func putU32(_ v: UInt32, into d: inout Data) {
            if littleEndian {
                d.append(UInt8(v & 0xFF)); d.append(UInt8((v >> 8) & 0xFF))
                d.append(UInt8((v >> 16) & 0xFF)); d.append(UInt8((v >> 24) & 0xFF))
            } else {
                d.append(UInt8((v >> 24) & 0xFF)); d.append(UInt8((v >> 16) & 0xFF))
                d.append(UInt8((v >> 8) & 0xFF)); d.append(UInt8(v & 0xFF))
            }
        }
        func ptrData(_ offset: Int) -> Data {
            var d = Data()
            putU32(UInt32(offset), into: &d)
            return d
        }

        if let i = ifd0.firstIndex(where: { $0.tag == tagExifIFD }) {
            ifd0[i] = Entry(tag: tagExifIFD, type: typeLong, count: 1, data: ptrData(exifOff))
        }
        if let gpsSorted, let i = ifd0.firstIndex(where: { $0.tag == tagGPSIFD }) {
            ifd0[i] = Entry(tag: tagGPSIFD, type: typeLong, count: 1, data: ptrData(gpsOff))
            _ = gpsSorted
        }

        var out = Data()
        if littleEndian { out.append(contentsOf: [0x49, 0x49, 0x2A, 0x00]) }
        else { out.append(contentsOf: [0x4D, 0x4D, 0x00, 0x2A]) }
        putU32(UInt32(header), into: &out)

        func writeIFD(_ entries: [Entry]) {
            putU16(UInt16(entries.count), into: &out)
            var extras = Data()
            var extraOff = out.count + 12 * entries.count + 4
            for e in entries {
                putU16(e.tag, into: &out)
                putU16(e.type, into: &out)
                putU32(e.count, into: &out)
                if e.data.count <= 4 {
                    var inline = e.data
                    while inline.count < 4 { inline.append(0) }
                    out.append(inline.prefix(4))
                } else {
                    putU32(UInt32(extraOff), into: &out)
                    extras.append(e.data)
                    if e.data.count % 2 == 1 { extras.append(0) }
                    extraOff += (e.data.count + 1) & ~1
                }
            }
            putU32(0, into: &out)
            out.append(extras)
        }

        writeIFD(ifd0)
        writeIFD(exifSorted)
        if let gpsSorted { writeIFD(gpsSorted) }
        _ = gpsSize; _ = gpsExtra
        return out
    }
}
