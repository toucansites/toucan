//
//  Block.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 17..
//

/// A representation of a custom block directive in Markdown, used for extending Markdown syntax with special tags or behaviors.
public struct Block: Codable, Equatable {

    /// The name of the directive.
    public var name: String

    /// If specified, this directive must appear within another directive of the given name.
    public var requiredParentBlock: String?

    /// Indicates whether child paragraphs should be removed from the HTML output. Defaults to `nil`.
    public var removeChildParagraph: Bool?

    /// Resolves the content as an asset URL if true.
    public var resolveContentAsAssset: Bool?

    /// A map of property names to their type definitions.
    public var properties: [String: Property]

    /// Custom output HTML string that overrides default rendering behavior, if provided.
    public var view: String

    /// Initializes a `Block`.
    ///
    /// - Parameters:
    ///   - name: The directive's name.
    ///   - requiredParentBlock: Name of a parent directive this one must reside within.
    ///   - removeChildParagraph: Whether to exclude child `<p>` tags during rendering.
    ///   - resolveContentAsAssset: Resolves the content as an asset URL if true.
    ///   - properties: A map of property names to their type definitions.
    ///   - view: The view (Mustache template as a string) for the block
    public init(
        name: String,
        requiredParentBlock: String? = nil,
        removeChildParagraph: Bool? = nil,
        resolveContentAsAssset: Bool? = nil,
        properties: [String: Property] = [:],
        view: String
    ) {
        self.name = name

        self.requiredParentBlock = requiredParentBlock
        self.removeChildParagraph = removeChildParagraph
        self.resolveContentAsAssset = resolveContentAsAssset

        self.properties = properties
        self.view = view
    }
}
