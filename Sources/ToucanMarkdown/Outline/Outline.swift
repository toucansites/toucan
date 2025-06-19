//
//  Outline.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 04. 17..
//

/// A hierarchical representation of an outline element, used for
/// structuring headings or sections in a document or interface.
public struct Outline: Equatable, Codable {

    /// The depth level of the outline node (e.g., 1 for top-level, 2 for a subheading, etc.).
    public var level: Int

    /// The display text of the outline entry, such as a heading title.
    public var text: String

    /// An optional fragment identifier that can be used for navigation (e.g., URL anchors).
    public var fragment: String?

    /// A list of child outlines, representing nested structure under this node.
    public var children: [Outline]

    // MARK: - Lifecycle

    /// Initializes a new `Outline` instance.
    ///
    /// - Parameters:
    ///   - level: The heading level of the outline (e.g., 1 for `h1`, 2 for `h2`, etc.).
    ///   - text: The display text for this outline item.
    ///   - fragment: An optional anchor or link target associated with this item.
    ///   - children: A list of nested `Outline` elements under this item.
    public init(
        level: Int,
        text: String,
        fragment: String? = nil,
        children: [Outline] = []
    ) {
        self.level = level
        self.text = text
        self.fragment = fragment
        self.children = children
    }
}
