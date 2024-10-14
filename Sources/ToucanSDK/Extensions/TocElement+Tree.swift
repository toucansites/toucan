//
//  File.swift
//  toucan
//
//  Created by Viasz-Kádi Ferenc on 2024. 10. 14..
//

import Foundation

extension [TocElement] {

    /// Builds a tree of Table of Content (ToC) nodes based on the hierarchy levels of the elements.
    ///
    /// - Returns: An array of `ToCNode` objects representing the hierarchical structure of the ToC.
    func buildToCTree() -> [ToCNode] {
        var result: [ToCNode] = []
        var stack: [ToCNode] = []

        for element in self {
            let newNode = ToCNode(
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
