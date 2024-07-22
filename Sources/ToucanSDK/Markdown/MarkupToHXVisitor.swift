//
//  File.swift
//
//
//  Created by Tibor Bodecs on 03/05/2024.
//

import Markdown

struct MarkupToHXVisitor: MarkupVisitor {

    struct HX {
        let level: Int
        let text: String
        let fragment: String

        init(
            level: Int,
            text: String,
            fragment: String
        ) {
            self.level = level
            self.text = text
            self.fragment = fragment
        }
    }

    typealias Result = [HX]

    let levels: [Int]

    init(levels: [Int] = [2, 3]) {
        self.levels = levels
    }

    // MARK: - visitor functions

    mutating func defaultVisit(
        _ markup: any Markup
    ) -> Result {
        var result: [HX] = []
        for child in markup.children {
            result += visit(child)
        }
        return result
    }

    // MARK: - elements

    mutating func visitHeading(
        _ heading: Heading
    ) -> Result {
        guard levels.contains(heading.level) else {
            return []
        }
        let fragment = heading.plainText.lowercased().slugify()
        return [
            .init(
                level: heading.level,
                text: heading.plainText,
                fragment: fragment
            )
        ]
    }
}
