//
//  MarkdownBlockDirective.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 02. 19..
//

/// A representation of a custom block directive in Markdown, used for extending Markdown syntax with special tags or behaviors.
public struct MarkdownBlockDirective: Codable, Equatable {

    /// Defines a configurable parameter for a directive, which may be required and have a default value.
    public struct Parameter: Codable, Equatable {

        /// The label of the parameter.
        public var label: String

        /// Indicates whether the parameter is required. Defaults to `nil` (optional).
        public var `required`: Bool?

        /// A default value for the parameter, used if it is not explicitly specified in the directive.
        public var `default`: String?

        /// Initializes a `Parameter` for a directive.
        ///
        /// - Parameters:
        ///   - label: The name of the parameter.
        ///   - isRequired: Indicates if the parameter must be provided.
        ///   - defaultValue: A fallback value if none is provided.
        public init(
            label: String,
            isRequired: Bool? = nil,
            defaultValue: String? = nil
        ) {
            self.label = label
            self.`required` = isRequired
            self.`default` = defaultValue
        }
    }

    /// Represents a static HTML attribute that will be rendered on the directive's HTML tag.
    public struct Attribute: Codable, Equatable {
        /// The name of the HTML attribute (e.g., `class`, `id`).
        public var name: String

        /// The corresponding value of the attribute.
        public var value: String

        /// Initializes an `Attribute` for the rendered directive HTML tag.
        ///
        /// - Parameters:
        ///   - name: The attribute key.
        ///   - value: The attribute value.
        public init(
            name: String,
            value: String
        ) {
            self.name = name
            self.value = value
        }
    }

    /// The name of the directive (e.g., `"note"`, `"warning"`, `"info"`).
    public var name: String

    /// A list of supported parameters for the directive.
    public var parameters: [Parameter]?

    /// If specified, this directive must appear within another directive of the given name.
    public var requiresParentDirective: String?

    /// Indicates whether child paragraphs should be removed from the HTML output. Defaults to `nil`.
    public var removesChildParagraph: Bool?

    /// The HTML tag to render (e.g., `"div"`, `"section"`, `"aside"`).
    public var tag: String?

    /// Static attributes to apply to the rendered HTML tag.
    public var attributes: [Attribute]?

    /// Custom output HTML string that overrides default rendering behavior, if provided.
    public var output: String?

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
