//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 02. 19..
//

public struct MarkdownBlockDirective: Codable, Equatable {

    public struct Parameter: Codable, Equatable {

        public var label: String
        public var `required`: Bool?
        public var `default`: String?

        public init(
            label: String,
            `required`: Bool? = nil,
            `default`: String? = nil
        ) {
            self.label = label
            self.`required` = `required`
            self.`default` = `default`
        }
    }

    public struct Attribute: Codable, Equatable {
        public var name: String
        public var value: String

        public init(
            name: String,
            value: String
        ) {
            self.name = name
            self.value = value
        }
    }

    public var name: String
    public var parameters: [Parameter]?
    public var requiresParentDirective: String?
    public var removesChildParagraph: Bool?
    public var tag: String?
    public var attributes: [Attribute]?
    public var output: String?

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
