import Foundation

struct Base64EncoderDecoder {
    enum Mode: String, CaseIterable, Identifiable, Sendable {
        case encode
        case decode

        var id: String { rawValue }

        var title: String {
            switch self {
            case .encode:
                "Encode"
            case .decode:
                "Decode"
            }
        }
    }

    enum ConversionError: Error, LocalizedError, Sendable {
        case emptyInput
        case invalidBase64
        case nonUTF8DecodedText

        var errorDescription: String? {
            switch self {
            case .emptyInput:
                "Enter some text to encode or a Base64 string to decode."
            case .invalidBase64:
                "The input is not valid Base64 data."
            case .nonUTF8DecodedText:
                "The Base64 data could not be decoded as UTF‑8 text."
            }
        }
    }

    static func convert(_ rawInput: String, mode: Mode) throws -> String {
        let trimmed = rawInput.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            throw ConversionError.emptyInput
        }

        switch mode {
        case .encode:
            return try encode(trimmed)
        case .decode:
            return try decode(trimmed)
        }
    }

    private static func encode(_ input: String) throws -> String {
        let data = Data(input.utf8)
        return data.base64EncodedString()
    }

    private static func decode(_ input: String) throws -> String {
        guard let data = Data(base64Encoded: input, options: [.ignoreUnknownCharacters]) else {
            throw ConversionError.invalidBase64
        }

        guard let decoded = String(data: data, encoding: .utf8) else {
            throw ConversionError.nonUTF8DecodedText
        }

        return decoded
    }
}
