//
//  File.swift
//
//
//  Created by Tibor Bodecs on 03/05/2024.
//

import Markdown

struct MarkupHeadingVisitor: MarkupVisitor {

    typealias Result = [TocElement]

    let levels: [Int]

    init(levels: [Int] = [2, 3]) {
        self.levels = levels
    }

    // MARK: - visitor functions

    mutating func defaultVisit(_ markup: any Markup) -> Result {
        markup.children.flatMap { visit($0) }
    }

    // MARK: - elements

    mutating func visitHeading(_ heading: Heading) -> Result {
        guard levels.contains(heading.level) else {
            return []
        }
        return [
            TocElement(heading)
        ]
    }
}
