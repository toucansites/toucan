//
//  Pipeline+Scope+Context.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 02. 03..
//

public extension Pipeline.Scope {
    /// Represents the available data context for a rendering `Scope`.
    struct Context: OptionSet, Codable {

        /// Includes user-defined metadata and settings.
        public static var userDefined: Self { .init(rawValue: 1 << 0) }

        /// Includes all standard content properties (e.g., title, date).
        public static var properties: Self { .init(rawValue: 1 << 1) }

        /// Includes nested or inline contents (e.g., included markdown).
        public static var contents: Self { .init(rawValue: 1 << 2) }

        /// Includes resolved relations (e.g., related posts, authors).
        public static var relations: Self { .init(rawValue: 1 << 3) }

        /// Includes output from named or inline queries.
        public static var queries: Self { .init(rawValue: 1 << 4) }

        /// A context optimized for minimal, linked summaries.
        public static var reference: Self {
            [
                .userDefined,
                .properties,
                .relations,
                .contents,
                .queries,
            ]
        }

        /// A context optimized for list or collection rendering.
        public static var list: Self {
            [
                .userDefined,
                .properties,
                .relations,
                .contents,
                .queries,
            ]
        }

        /// A context optimized for detailed full-page rendering.
        public static var detail: Self {
            [
                .userDefined,
                .properties,
                .relations,
                .contents,
                .queries,
            ]
        }

        /// The underlying raw bitmask value used to represent the context.
        public let rawValue: UInt

        /// Returns the mapping of context options to their string names.
        private var allOptions: [(Context, String)] {
            [
                (.userDefined, "userDefined"),
                (.properties, "properties"),
                (.contents, "contents"),
                (.relations, "relations"),
                (.queries, "queries"),
                (.reference, "reference"),
                (.list, "list"),
                (.detail, "detail"),
            ]
        }

        /// Returns the string names of the options contained in the context.
        public var stringValues: [String] {
            allOptions.compactMap { contains($0.0) ? $0.1 : nil }
        }

        /// Initializes the context using a raw value.
        ///
        /// - Parameter rawValue: The UInt representation of the context.
        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }

        /// Initializes the context using a string name (e.g., "properties", "detail").
        ///
        /// - Parameter stringValue: The string representation of the context.
        public init(stringValue: String) {
            switch stringValue.lowercased() {
            case "userdefined":
                self = .userDefined
            case "properties":
                self = .properties
            case "contents":
                self = .contents
            case "relations":
                self = .relations
            case "queries":
                self = .queries
            case "reference":
                self = .reference
            case "list":
                self = .list
            case "detail":
                self = .detail
            default:
                self = []
            }
        }

        /// Decodes the context from either a single string or an array of strings.
        ///
        /// Supports user-friendly formats like:
        /// ```yaml
        /// context: "detail"
        /// ```
        /// or
        /// ```yaml
        /// context: ["properties", "relations"]
        /// ```
        ///
        /// - Parameter decoder: The decoder to use.
        /// - Throws: A decoding error if format is not supported.
        public init(
            from decoder: any Decoder
        ) throws {
            let container = try decoder.singleValueContainer()
            if let stringValue = try? container.decode(String.self) {
                self.init(stringValue: stringValue)
            }
            else if let stringArray = try? container.decode([String].self) {
                self = stringArray.reduce(into: []) {
                    $0.insert(.init(stringValue: $1))
                }
            }
            else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Invalid context format."
                )
            }
        }

        /// Encodes the context as a string or array of strings using the defined string values.
        ///
        /// - Parameter encoder: The encoder to write data to.
        /// - Throws: An error if any values are invalid or encoding fails.
        public func encode(
            to encoder: any Encoder
        ) throws {
            var container = encoder.singleValueContainer()

            if let matched = allOptions.first(where: { self == $0.0 }) {
                try container.encode(matched.1)
            }
            else {
                let parts = allOptions.filter { contains($0.0) }.map(\.1)
                try container.encode(parts)
            }
        }
    }
}
