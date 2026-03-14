import Foundation

struct LoremIpsumGenerator {
    struct Configuration: Sendable {
        let paragraphCount: Int
        let includeClassicOpening: Bool

        init(
            paragraphCount: Int = 3,
            includeClassicOpening: Bool = true
        ) {
            self.paragraphCount = max(1, paragraphCount)
            self.includeClassicOpening = includeClassicOpening
        }
    }

    private static let classicOpening =
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."

    private static let additionalSentences: [String] = [
        "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
        "Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.",
        "Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
        "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium.",
        "Totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.",
        "Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit.",
        "Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit.",
        "Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam.",
        "Nisi ut aliquid ex ea commodi consequatur?",
        "Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur.",
    ]

    static func generate(configuration: Configuration) -> String {
        let paragraphCount = max(1, configuration.paragraphCount)

        var paragraphs: [String] = []
        var sentenceIndex = 0

        for paragraph in 0 ..< paragraphCount {
            var sentences: [String] = []

            if paragraph == 0, configuration.includeClassicOpening {
                sentences.append(classicOpening)
            }

            let targetSentenceCount = configuration.includeClassicOpening && paragraph == 0 ? 4 : 5

            while sentences.count < targetSentenceCount {
                let sentence = additionalSentences[sentenceIndex % additionalSentences.count]
                sentences.append(sentence)
                sentenceIndex += 1
            }

            paragraphs.append(sentences.joined(separator: " "))
        }

        return paragraphs.joined(separator: "\n\n")
    }
}
