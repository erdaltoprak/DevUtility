import Foundation

struct UnixTimestampConversionResult: Sendable {
    enum InputKind: String, Sendable {
        case seconds
        case milliseconds
        case iso8601
        case automatic

        var description: String {
            switch self {
            case .seconds:
                "Unix timestamp (seconds since epoch)"
            case .milliseconds:
                "Unix timestamp (milliseconds since epoch)"
            case .iso8601:
                "ISO 8601 date‑time string"
            case .automatic:
                "Automatically detected"
            }
        }
    }

    let input: String
    let inputKind: InputKind
    let date: Date
    let localDateTime: String
    let iso8601String: String
    let relativeDescription: String
    let unixSeconds: Int64
    let unixMilliseconds: Int64
    let dayOfWeek: String
    let weekOfYear: Int
    let isLeapYear: Bool
}

enum UnixTimestampConversionError: Error, LocalizedError, Sendable {
    case emptyInput
    case invalidInput

    var errorDescription: String? {
        switch self {
        case .emptyInput:
            "Enter a Unix timestamp or ISO 8601 date to convert."
        case .invalidInput:
            "The value could not be parsed as a Unix timestamp or ISO 8601 date."
        }
    }
}

struct UnixTimestampConverter {
    enum InputMode: String, CaseIterable, Identifiable, Sendable {
        case automatic
        case seconds
        case milliseconds
        case iso8601

        var id: String { rawValue }

        var title: String {
            switch self {
            case .automatic:
                "Auto"
            case .seconds:
                "Sec"
            case .milliseconds:
                "Millis"
            case .iso8601:
                "ISO"
            }
        }
    }

    static func convert(
        _ rawInput: String,
        mode: InputMode,
        now: Date = .init()
    ) throws -> UnixTimestampConversionResult {
        let trimmed = rawInput.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            throw UnixTimestampConversionError.emptyInput
        }

        let date: Date
        let inputKind: UnixTimestampConversionResult.InputKind

        switch mode {
        case .seconds:
            (date, inputKind) = try parseSeconds(trimmed)
        case .milliseconds:
            (date, inputKind) = try parseMilliseconds(trimmed)
        case .iso8601:
            (date, inputKind) = try parseISO8601(trimmed)
        case .automatic:
            (date, inputKind) = try parseAutomatic(trimmed)
        }

        let unixSeconds = Int64(date.timeIntervalSince1970.rounded())
        let unixMilliseconds = Int64((date.timeIntervalSince1970 * 1_000).rounded())

        let localDateTime = date.formatted(date: .long, time: .standard)
        let iso8601String = date.ISO8601Format()

        let relativeFormatter = RelativeDateTimeFormatter()
        relativeFormatter.unitsStyle = .full
        let relativeDescription = relativeFormatter.localizedString(for: date, relativeTo: now)

        let weekday = date.formatted(.dateTime.weekday(.wide))
        let calendar = Calendar.current
        let weekOfYear = calendar.component(.weekOfYear, from: date)
        let isLeapYear = calendar.range(of: .day, in: .year, for: date)?.count == 366

        return UnixTimestampConversionResult(
            input: trimmed,
            inputKind: inputKind,
            date: date,
            localDateTime: localDateTime,
            iso8601String: iso8601String,
            relativeDescription: relativeDescription,
            unixSeconds: unixSeconds,
            unixMilliseconds: unixMilliseconds,
            dayOfWeek: weekday,
            weekOfYear: weekOfYear,
            isLeapYear: isLeapYear
        )
    }

    // MARK: - Parsing

    private static func parseSeconds(_ input: String) throws -> (Date, UnixTimestampConversionResult.InputKind) {
        guard let value = Double(input) else {
            throw UnixTimestampConversionError.invalidInput
        }

        let date = Date(timeIntervalSince1970: value)
        return (date, .seconds)
    }

    private static func parseMilliseconds(_ input: String) throws -> (Date, UnixTimestampConversionResult.InputKind) {
        guard let value = Double(input) else {
            throw UnixTimestampConversionError.invalidInput
        }

        let seconds = value / 1_000
        let date = Date(timeIntervalSince1970: seconds)
        return (date, .milliseconds)
    }

    private static func parseISO8601(_ input: String) throws -> (Date, UnixTimestampConversionResult.InputKind) {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds,
        ]

        if let date = formatter.date(from: input) {
            return (date, .iso8601)
        }

        formatter.formatOptions = [.withInternetDateTime]

        if let date = formatter.date(from: input) {
            return (date, .iso8601)
        }

        throw UnixTimestampConversionError.invalidInput
    }

    private static func parseAutomatic(_ input: String) throws -> (Date, UnixTimestampConversionResult.InputKind) {
        // If the input contains non‑numeric characters (besides leading '-'),
        // fall back to ISO 8601 parsing.
        let numericCharacterSet = CharacterSet(charactersIn: "-0123456789")
        let hasOnlyNumericCharacters = input.unicodeScalars.allSatisfy { numericCharacterSet.contains($0) }

        if hasOnlyNumericCharacters {
            guard let value = Double(input) else {
                throw UnixTimestampConversionError.invalidInput
            }

            // Heuristic: treat values with magnitude >= 10^12 as milliseconds.
            // This comfortably covers current ranges of Unix time in seconds.
            let absoluteValue = abs(value)
            if absoluteValue >= 1_000_000_000_000 {
                let seconds = value / 1_000
                let date = Date(timeIntervalSince1970: seconds)
                return (date, .milliseconds)
            } else {
                let date = Date(timeIntervalSince1970: value)
                return (date, .seconds)
            }
        } else {
            return try parseISO8601(input)
        }
    }
}
