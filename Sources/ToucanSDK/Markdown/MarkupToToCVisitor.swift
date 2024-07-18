//
//  File.swift
//
//
//  Created by Tibor Bodecs on 03/05/2024.
//

import Markdown

/// NOTE: https://www.markdownguide.org/basic-syntax/

private extension Markup {

    var isInsideList: Bool {
        self is ListItemContainer || parent?.isInsideList == true
    }
}

public struct ToC {

    public let level: Int
    public let text: String
    public let fragment: String
    
    public init(
        level: Int,
        text: String,
        fragment: String
    ) {
        self.level = level
        self.text = text
        self.fragment = fragment
    }
}

public struct ToCTree {
    public let level: Int
    public let text: String
    public let fragment: String
    public var children: [ToCTree]

    public init(
        level: Int,
        text: String,
        fragment: String,
        children: [ToCTree] = []
    ) {
        self.level = level
        self.text = text
        self.fragment = fragment
        self.children = children
    }
    
    static func buildToCTree(from tocList: [ToC]) -> [ToCTree] {
        var result: [ToCTree] = []
        var stack: [ToCTree] = []
        
//        print(tocList)
        
        for toc in tocList {
            let newNode = ToCTree(level: toc.level, text: toc.text, fragment: toc.fragment)
            
            // Find the correct parent for the current node
            while let last = stack.last, last.level >= toc.level {
                stack.removeLast()
            }
            
            if let parent = stack.last {
                // Append new node as a child of the last node in the stack
                var updatedParent = parent
                updatedParent.children.append(newNode)
                stack[stack.count - 1] = updatedParent
                if let index = result.firstIndex(where: { $0.fragment == parent.fragment && $0.level == parent.level }) {
                    result[index] = updatedParent
                }
            } else {
                // Add the new node to the result if it has no parent
                result.append(newNode)
            }
            
            // Add the new node to the stack
            stack.append(newNode)
        }
        
        return result
    }
}

struct MarkupToToCVisitor: MarkupVisitor {
    
    typealias Result = [ToC]
    
    // MARK: - visitor functions
    
    mutating func defaultVisit(_ markup: any Markup) -> Result {
        var result: [ToC] = []
        for child in markup.children {
            result += visit(child)
        }
        return result
    }
    
    // MARK: - elements
    
    mutating func visitHeading(
        _ heading: Heading
    ) -> Result {
        guard [2, 3].contains(heading.level) else {
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
