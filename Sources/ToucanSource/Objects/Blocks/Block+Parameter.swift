//
//  Block+Parameter.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 18..
//

public extension Block {
    /// Defines a configurable parameter for a directive, which may be required and have a default value.
    struct Parameter: Sendable, Codable, Equatable {

        /// The label of the parameter.
        public var label: String

        /// Indicates whether the parameter is required. Defaults to `nil` (optional).
        public var isRequired: Bool?

        /// A default value for the parameter, used if it is not explicitly specified in the directive.
        public var defaultValue: String?

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
            self.isRequired = isRequired
            self.defaultValue = defaultValue
        }
    }
}
