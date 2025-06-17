//
//  Block.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 17..
//

/// A representation of a custom block directive in Markdown, used for extending Markdown syntax with special tags or behaviors.
public struct Block: Sendable, Codable, Equatable {
    // MARK: - Properties

    /// The name of the directive.
    public var name: String

    /// A list of supported parameters for the directive.
    public var parameters: [Parameter]?

    /// If specified, this directive must appear within another directive of the given name.
    public var requiresParentDirective: String?

    /// Indicates whether child paragraphs should be removed from the HTML output. Defaults to `nil`.
    public var removesChildParagraph: Bool?

    /// The HTML tag to render (e.g., `"div"`, `"section"`).
    public var tag: String?

    /// Static attributes to apply to the rendered HTML tag.
    public var attributes: [Attribute]?

    /// Custom output HTML string that overrides default rendering behavior, if provided.
    public var output: String?

    // MARK: - Lifecycle

    /// Initializes a `MarkdownBlockDirective`.
    ///
    /// - Parameters:
    ///   - name: The directive's name.
    ///   - parameters: Optional list of accepted parameters.
    ///   - requiresParentDirective: Name of a parent directive this one must reside within.
    ///   - removesChildParagraph: Whether to exclude child `<p>` tags during rendering.
    ///   - tag: HTML tag to be generated.
    ///   - attributes: HTML attributes to apply.
    ///   - output: Optional custom HTML output template.
    public init(
        name: String,
        parameters: [Parameter]? = nil,
        requiresParentDirective: String? = nil,
        removesChildParagraph: Bool? = nil,
        tag: String? = nil,
        attributes: [Attribute]? = nil,
        output: String? = nil
    ) {
        self.name = name
        self.parameters = parameters
        self.requiresParentDirective = requiresParentDirective
        self.removesChildParagraph = removesChildParagraph
        self.tag = tag
        self.attributes = attributes
        self.output = output
    }
}
