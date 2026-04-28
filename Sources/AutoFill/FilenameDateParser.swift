import Foundation

/// Pure: parses a date out of a filename using a list of built-in patterns
/// (and, in Task 4, an optional user-supplied custom format).
public enum FilenameDateParser {

    public static func parse(_ filename: String,
                             config: FilenamePatternConfig,
                             referenceTimeZone: TimeZone) -> Date? {
        if let custom = config.customFormat,
           let d = matchCustom(filename: filename, format: custom, in: referenceTimeZone) {
            return d
        }
        for pattern in builtIn {
            if let d = pattern.match(filename, in: referenceTimeZone) {
                return d
            }
        }
        return nil
    }

    /// Translates a token-style format ("Scan_yyyyMMdd_HHmmss_*") into a regex
    /// with capture groups for year/month/day/hour/minute/second.
    static func matchCustom(filename: String, format: String, in tz: TimeZone) -> Date? {
        // Token list — order matters: 4-digit year before 2-digit, etc.
        let tokens: [(String, String, String)] = [
            ("yyyy", "(?<y>\\d{4})", "y"),
            ("MM",   "(?<mo>\\d{2})", "mo"),
            ("dd",   "(?<d>\\d{2})",  "d"),
            ("HH",   "(?<h>\\d{2})",  "h"),
            ("mm",   "(?<mi>\\d{2})", "mi"),
            ("ss",   "(?<se>\\d{2})", "se"),
        ]
        var regexBody = ""
        var i = format.startIndex
        outer: while i < format.endIndex {
            for (token, replacement, _) in tokens {
                if format[i...].hasPrefix(token) {
                    regexBody += replacement
                    i = format.index(i, offsetBy: token.count)
                    continue outer
                }
            }
            let ch = format[i]
            if ch == "*" {
                regexBody += ".*?"
            } else {
                regexBody += NSRegularExpression.escapedPattern(for: String(ch))
            }
            i = format.index(after: i)
        }
        guard let re = try? NSRegularExpression(pattern: regexBody) else { return nil }
        let range = NSRange(filename.startIndex..., in: filename)
        guard let m = re.firstMatch(in: filename, range: range) else { return nil }
        func group(_ name: String) -> Int? {
            let nr = m.range(withName: name)
            guard nr.location != NSNotFound, let r = Range(nr, in: filename) else { return nil }
            return Int(filename[r])
        }
        var dc = DateComponents()
        dc.year = group("y"); dc.month = group("mo"); dc.day = group("d")
        dc.hour = group("h") ?? 0; dc.minute = group("mi") ?? 0; dc.second = group("se") ?? 0
        guard dc.year != nil, dc.month != nil, dc.day != nil else { return nil }
        var cal = Calendar(identifier: .gregorian); cal.timeZone = tz
        return cal.date(from: dc)
    }

    static let builtIn: [BuiltInPattern] = [
        // Most cameras: IMG_20210315_142030 anywhere.
        .init(regex: #"(?<![\d])IMG[_-](\d{4})(\d{2})(\d{2})[_-](\d{2})(\d{2})(\d{2})"#, hasTime: true),
        // Older Nikons: DSC_20210315_142030 anywhere.
        .init(regex: #"(?<![\d])DSC[_-](\d{4})(\d{2})(\d{2})[_-](\d{2})(\d{2})(\d{2})"#, hasTime: true),
        // WhatsApp: IMG-20210609-WA0042 (date only, no time).
        .init(regex: #"(?<![\d])IMG-(\d{4})(\d{2})(\d{2})-WA\d+"#, hasTime: false),
        // iOS Photos export: 2021-03-15 14.20.30
        .init(regex: #"(?<![\d])(\d{4})-(\d{2})-(\d{2})[ _](\d{2})\.(\d{2})\.(\d{2})"#, hasTime: true),
        // Date-only fallback: yyyymmdd.
        .init(regex: #"(?<![\d])(\d{4})(\d{2})(\d{2})(?![\d])"#, hasTime: false),
    ]

    struct BuiltInPattern {
        let regex: String
        let hasTime: Bool

        func match(_ s: String, in tz: TimeZone) -> Date? {
            guard let r = try? NSRegularExpression(pattern: regex) else { return nil }
            let range = NSRange(s.startIndex..., in: s)
            guard let m = r.firstMatch(in: s, range: range) else { return nil }
            func group(_ i: Int) -> Int? {
                guard m.numberOfRanges > i, let r = Range(m.range(at: i), in: s) else { return nil }
                return Int(s[r])
            }
            guard let y = group(1), let mo = group(2), let d = group(3) else { return nil }
            var dc = DateComponents()
            dc.year = y; dc.month = mo; dc.day = d
            if hasTime, let h = group(4), let mi = group(5), let se = group(6) {
                dc.hour = h; dc.minute = mi; dc.second = se
            } else {
                dc.hour = 0; dc.minute = 0; dc.second = 0
            }
            var cal = Calendar(identifier: .gregorian); cal.timeZone = tz
            return cal.date(from: dc)
        }
    }
}
