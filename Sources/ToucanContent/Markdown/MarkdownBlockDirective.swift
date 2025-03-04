//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 02. 19..
//

public struct MarkdownBlockDirective: Codable {

    public struct Parameter: Codable {

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

    public struct Attribute: Codable {
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

extension MarkdownBlockDirective.Parameter: Equatable {
    public static func == (
        lhs: MarkdownBlockDirective.Parameter,
        rhs: MarkdownBlockDirective.Parameter
    ) -> Bool {
        lhs.label == rhs.label && lhs.`required` == rhs.`required`
            && lhs.`default` == rhs.`default`
    }
}

extension MarkdownBlockDirective.Attribute: Equatable {
    public static func == (
        lhs: MarkdownBlockDirective.Attribute,
        rhs: MarkdownBlockDirective.Attribute
    ) -> Bool {
        lhs.name == rhs.name && lhs.value == rhs.value
    }
}

extension MarkdownBlockDirective: Equatable {

    public static func == (
        lhs: MarkdownBlockDirective,
        rhs: MarkdownBlockDirective
    ) -> Bool {
        lhs.name == rhs.name && lhs.parameters == rhs.parameters
            && lhs.requiresParentDirective == rhs.requiresParentDirective
            && lhs.removesChildParagraph == rhs.removesChildParagraph
            && lhs.tag == rhs.tag && lhs.attributes == rhs.attributes
            && lhs.output == rhs.output
    }
}
