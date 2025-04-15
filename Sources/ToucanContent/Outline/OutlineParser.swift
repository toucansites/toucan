//
//  OutlineParser.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2024. 10. 14..
//

import Logging
import SwiftSoup

public struct OutlineParser {

    public var levels: [Int]
    public var logger: Logger

    public init(
        levels: [Int] = [1, 2, 3, 4, 5, 6],
        logger: Logger = .init(label: "OutlineParser")
    ) {
        precondition(
            levels.allSatisfy { 1...6 ~= $0 },
            "Values must be between 1 and 6."
        )

        self.levels = levels
        self.logger = logger
    }

    public func parseHTML(
        _ html: String
    ) -> [Outline] {
        do {
            let document = try SwiftSoup.parse(html)

            let tagSelector = levels.map { "h\($0)" }.joined(separator: ", ")

            let headings = try document.select(tagSelector)
            return try headings.compactMap { try createToC(from: $0) }
        }
        catch Exception.Error(let type, let message) {
            logger.error("\(type) - \(message)")
            return []
        }
        catch {
            logger.error("\(error.localizedDescription)")
            return []
        }
    }

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

}
