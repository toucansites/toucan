//
//  File.swift
//  toucan
//
//  Created by Viasz-Kádi Ferenc on 2024. 10. 14..
//

import Logging
import SwiftSoup

public struct HTMLToCParser {

    public var levels: [Int]
    public var logger: Logger

    public init(
        levels: [Int] = [1, 2, 3, 4, 5, 6],
        logger: Logger = .init(label: "HTMLToCParser")
    ) {
        precondition(
            levels.allSatisfy { 1...6 ~= $0 },
            "Values must be between 1 and 6."
        )

        self.levels = levels
        self.logger = logger
    }

    public func parse(
        _ html: String
    ) -> [ToC] {
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
    ) throws -> ToC? {
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

    func buildTree(_ elements: [ToC]) -> [ToC] {
        var result: [ToC] = []
        var stack: [ToC] = []

        for element in elements {
            let newNode = ToC(
                level: element.level,
                text: element.text,
                fragment: element.fragment
            )

            // Find the correct parent for the current node
            while let last = stack.last, last.level >= element.level {
                stack.removeLast()
            }

            if let parent = stack.last {
                // Append new node as a child of the last node in the stack
                var updatedParent = parent
                updatedParent.children.append(newNode)
                stack[stack.count - 1] = updatedParent
                if let index = result.firstIndex(where: {
                    $0.fragment == parent.fragment && $0.level == parent.level
                }) {
                    result[index] = updatedParent
                }
            }
            else {
                // Add the new node to the result if it has no parent
                result.append(newNode)
            }

            // Add the new node to the stack
            stack.append(newNode)
        }

        return result
    }
}
