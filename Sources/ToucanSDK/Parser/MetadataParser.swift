import Foundation
import Ink
import Splash

struct MetadataParser {

    var parser: MarkdownParser

    init() {
        let parser = MarkdownParser()
        self.parser = parser
    }

    func parse(at url: URL) throws -> [String: String] {
        let rawMarkdown = try String(contentsOf: url)
        let markdown = parser.parse(rawMarkdown)
        return markdown.metadata
    }
}
