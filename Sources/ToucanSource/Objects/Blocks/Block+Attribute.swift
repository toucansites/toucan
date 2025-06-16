//
//  Block+Attribute.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 18..
//

public extension Block {
    /// Represents a static HTML attribute that will be rendered on the directive's HTML tag.
    struct Attribute: Sendable, Codable, Equatable {
        // MARK: - Properties

        /// The name of the HTML attribute (e.g., `class`, `id`).
        public var name: String

        /// The corresponding value of the attribute.
        public var value: String

        // MARK: - Lifecycle

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
}
