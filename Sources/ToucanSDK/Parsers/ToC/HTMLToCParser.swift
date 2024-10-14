//
//  File.swift
//  toucan
//
//  Created by Viasz-Kádi Ferenc on 2024. 10. 14..
//

import Foundation
import Logging
import SwiftSoup

/// A struct that parses HTML content to extract table of contents (ToC) elements from heading tags.
/// This struct conforms to the `ToCElementParser` protocol.
struct HTMLToCParser: ToCElementParser {

    /// Logger instance used to log errors encountered during parsing.
    let logger: Logger

    /// Parses the provided HTML string and extracts table of contents elements from `<h2>` and `<h3>` tags.
    ///
    /// - Parameter value: The HTML string to parse.
    /// - Returns: An array of `TocElement` objects or `nil` if an error occurs during parsing.
    func parse(from value: String) -> [TocElement]? {
        do {
            let document: SwiftSoup.Document = try SwiftSoup.parse(value)
            let headings = try document.select("h2, h3")
            return headings.compactMap { TocElement($0) }
        }
        catch Exception.Error(_, let message) {
            logger.error("\(message)")
            return nil
        }
        catch {
            logger.error("\(error.localizedDescription)")
            return nil
        }
    }
}

extension TocElement {

    /// Initializes a new instance with the provided SwiftSoup.Element.
    /// Attempts to extract text, level, and fragment from the element.
    /// If the fragment attribute is empty or an error occurs during extraction, initialization fails.
    init?(_ element: SwiftSoup.Element) {
        do {
            text = try element.text()
            level = element.nodeName().hasSuffix("2") ? 2 : 3
            fragment = try element.attr("id")

            guard !fragment.isEmpty else {
                return nil
            }
        }
        catch {
            return nil
        }
    }
}
