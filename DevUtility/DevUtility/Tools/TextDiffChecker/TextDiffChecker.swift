import Foundation

struct TextDiffRow: Identifiable, Sendable {
    enum Kind: String, Sendable {
        case unchanged
        case added
        case removed
    }

    let id: Int
    let kind: Kind
    let originalLineNumber: Int?
    let modifiedLineNumber: Int?
    let originalText: String?
    let modifiedText: String?
}

struct TextDiffResult: Sendable {
    let rows: [TextDiffRow]
    let originalLineCount: Int
    let modifiedLineCount: Int
    let hasChanges: Bool
    let unifiedDiff: String
}

enum TextDiffChecker {
    static func diff(
        original: String,
        modified: String
    ) -> TextDiffResult {
        let originalLines =
            original.split(
                whereSeparator: { $0 == "\n" }
            )
            .map(String.init)

        let modifiedLines =
            modified.split(
                whereSeparator: { $0 == "\n" }
            )
            .map(String.init)

        let originalCount = originalLines.count
        let modifiedCount = modifiedLines.count

        var lcsTable = Array(
            repeating: Array(repeating: 0, count: modifiedCount + 1),
            count: originalCount + 1
        )

        if originalCount > 0, modifiedCount > 0 {
            for originalIndex in stride(from: originalCount - 1, through: 0, by: -1) {
                for modifiedIndex in stride(from: modifiedCount - 1, through: 0, by: -1) {
                    if originalLines[originalIndex] == modifiedLines[modifiedIndex] {
                        lcsTable[originalIndex][modifiedIndex] =
                            lcsTable[originalIndex + 1][modifiedIndex + 1] + 1
                    } else {
                        lcsTable[originalIndex][modifiedIndex] = max(
                            lcsTable[originalIndex + 1][modifiedIndex],
                            lcsTable[originalIndex][modifiedIndex + 1]
                        )
                    }
                }
            }
        }

        var rows: [TextDiffRow] = []
        rows.reserveCapacity(max(originalCount, modifiedCount))

        var originalIndex = 0
        var modifiedIndex = 0
        var originalLineNumber = 1
        var modifiedLineNumber = 1
        var rowIdentifier = 0

        func appendRow(
            kind: TextDiffRow.Kind,
            originalText: String?,
            modifiedText: String?,
            originalNumber: Int?,
            modifiedNumber: Int?
        ) {
            let row = TextDiffRow(
                id: rowIdentifier,
                kind: kind,
                originalLineNumber: originalNumber,
                modifiedLineNumber: modifiedNumber,
                originalText: originalText,
                modifiedText: modifiedText
            )
            rows.append(row)
            rowIdentifier += 1
        }

        while originalIndex < originalCount || modifiedIndex < modifiedCount {
            if originalIndex < originalCount,
                modifiedIndex < modifiedCount,
                originalLines[originalIndex] == modifiedLines[modifiedIndex]
            {
                appendRow(
                    kind: .unchanged,
                    originalText: originalLines[originalIndex],
                    modifiedText: modifiedLines[modifiedIndex],
                    originalNumber: originalLineNumber,
                    modifiedNumber: modifiedLineNumber
                )

                originalIndex += 1
                modifiedIndex += 1
                originalLineNumber += 1
                modifiedLineNumber += 1
            } else if modifiedIndex < modifiedCount,
                originalIndex == originalCount
                    || lcsTable[originalIndex][modifiedIndex + 1]
                        >= lcsTable[originalIndex + 1][modifiedIndex]
            {
                appendRow(
                    kind: .added,
                    originalText: nil,
                    modifiedText: modifiedLines[modifiedIndex],
                    originalNumber: nil,
                    modifiedNumber: modifiedLineNumber
                )

                modifiedIndex += 1
                modifiedLineNumber += 1
            } else if originalIndex < originalCount {
                appendRow(
                    kind: .removed,
                    originalText: originalLines[originalIndex],
                    modifiedText: nil,
                    originalNumber: originalLineNumber,
                    modifiedNumber: nil
                )

                originalIndex += 1
                originalLineNumber += 1
            }
        }

        let hasChanges = rows.contains { row in
            row.kind != .unchanged
        }

        let unifiedLines: [String] = rows.map { row in
            switch row.kind {
            case .unchanged:
                let content = row.originalText ?? row.modifiedText ?? ""
                return "  \(content)"
            case .removed:
                let content = row.originalText ?? ""
                return "- \(content)"
            case .added:
                let content = row.modifiedText ?? ""
                return "+ \(content)"
            }
        }

        let unifiedDiff = unifiedLines.joined(separator: "\n")

        return TextDiffResult(
            rows: rows,
            originalLineCount: originalCount,
            modifiedLineCount: modifiedCount,
            hasChanges: hasChanges,
            unifiedDiff: unifiedDiff
        )
    }
}
