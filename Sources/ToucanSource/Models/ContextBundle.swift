//
//  ContextBundle.swift
//  Toucan
//
//  Created by Tibor Bodecs on 2025. 02. 21..
//

import ToucanModels

/// A bundle containing a single content item, its rendering context, and its destination metadata.
///
/// `ContextBundle` is typically used as an input for template rendering or output generation,
/// combining the actual content with any supplemental data required for processing.
public struct ContextBundle {

    /// The primary content item to be rendered or processed.
    public var content: Content

    /// A key-value store representing the extended rendering context (e.g., metadata, global variables).
    /// These values can be used during template evaluation or logic processing.
    public var context: [String: AnyCodable]

    /// The intended destination of the output generated from this bundle.
    public var destination: Destination

    /// Initializes a new `ContextBundle` with content, context data, and a destination.
    ///
    /// - Parameters:
    ///   - content: The `Content` instance to render.
    ///   - context: A context dictionary providing additional rendering metadata or variables.
    ///   - destination: Where the rendered output should be saved.
    public init(
        content: Content,
        context: [String: AnyCodable],
        destination: Destination
    ) {
        self.content = content
        self.context = context
        self.destination = destination
    }
}
