//
//  OutlineParser.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2024. 10. 14..
//

import Logging
import SwiftSoup

/// A parser that extracts heading elements (`<h1>` to `<h6>`) from HTML and converts them into a structured outline.
public struct OutlineParser {

    /// The heading levels (e.g., `[1, 2, 3]` for `<h1>`, `<h2>`, and `<h3>`) to include in the outline.
    public var levels: [Int]

    /// Logger instance
    public var logger: Logger

    // MARK: - Lifecycle

    /// Initializes an `OutlineParser` with optional levels and a logger.
    ///
    /// - Parameters:
    ///   - levels: Heading levels to extract from the HTML. Must be between 1 and 6. Defaults to all (`[1, 2, 3, 4, 5, 6]`).
    ///   - logger: A `Logger` instance for capturing logs. Defaults to a logger labeled "OutlineParser".
    public init(
        levels: [Int] = [1, 2, 3, 4, 5, 6],
        logger: Logger = .init(label: "OutlineParser")
    ) {
        // Ensure levels are within the valid range of HTML headings.
        precondition(
            levels.allSatisfy { 1...6 ~= $0 },
            "Values must be between 1 and 6."
        )

        self.levels = levels
        self.logger = logger
    }

    /// Converts a single SwiftSoup element into an `Outline` if it corresponds to a valid heading.
    ///
    /// - Parameter element: A SwiftSoup `Element` representing a heading node.
    /// - Returns: An `Outline` instance if the element is a valid heading, otherwise `nil`.
    /// - Throws: An error if parsing the element fails.
    func createToC(
        from element: SwiftSoup.Element
    ) throws -> Outline? {
        let text = try element.text()

        let nodeName = element.nodeName()
        guard
            nodeName.count > 1,
            let rawLevel = nodeName.last,
            let level = Int(String(rawLevel)),
            (1...6).contains(level)
        else {
            return nil
        }

        var fragment: String?
        let id = try element.attr("id")
        if !id.isEmpty {
            fragment = id
        }

        return .init(
            level: level,
            text: text,
            fragment: fragment
        )
    }

    /// Parses the given HTML string and returns a flat list of `Outline` items corresponding to the specified heading levels.
    ///
    /// - Parameter html: A string of HTML content.
    /// - Returns: An array of `Outline` instances representing the headings found.
    public func parseHTML(
        _ html: String
    ) -> [Outline] {
        do {
            // Parse HTML content into a SwiftSoup document.
            let document = try SwiftSoup.parse(html)

            // Build a CSS selector for the specified heading levels (e.g., "h1, h2, h3").
            let tagSelector = levels.map { "h\($0)" }.joined(separator: ", ")

            // Select and process matching heading elements.
            let headings = try document.select(tagSelector)
            return try headings.compactMap { try createToC(from: $0) }
        }
        catch let Exception.Error(type, message) {
            logger.error("\(type) - \(message)")
            return []
        }
        catch {
            logger.error("\(error.localizedDescription)")
            return []
        }
    }
}
