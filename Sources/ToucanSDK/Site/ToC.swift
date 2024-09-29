//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 22/07/2024.
//

import Foundation

/// Represents a Table of Contents object
public struct ToC {
    /// The level of the ToC
    public let level: Int
    /// The of the ToC.
    public let text: String
    /// The fragment link for the ToC
    public let fragment: String
    /// Child elements for the ToC.
    public var children: [ToC]

    /// Initializes a new instance of `ToC`.
    ///
    /// - Parameters:
    ///   - level: The hierarchical level of the ToC entry.
    ///   - text: The text content of the ToC entry.
    ///   - fragment: The fragment identifier for linking to the ToC entry.
    ///   - children: An optional array of child ToC entries. Defaults to an empty array.
    public init(
        level: Int,
        text: String,
        fragment: String,
        children: [ToC] = []
    ) {
        self.level = level
        self.text = text
        self.fragment = fragment
        self.children = children
    }
}
