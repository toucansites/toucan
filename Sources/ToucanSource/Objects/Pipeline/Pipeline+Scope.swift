//
//  Pipeline+Scope.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 02. 03..
//

extension Pipeline {

    /// Describes a rendering scope within a content pipeline.
    public struct Scope: Decodable {

        // MARK: - Coding Keys

        private enum CodingKeys: CodingKey {
            case id
            case context
            case fields
        }

        // MARK: - Properties

        /// The rendering context this scope applies to (e.g., `.detail`, `.list`, `.reference`).
        public var context: Context

        /// The specific content fields to include when rendering in this scope.
        /// If empty, all fields may be included by default.
        public var fields: [String]

        // MARK: - Initialization

        /// Initializes a `Scope` with a given context and set of fields.
        ///
        /// - Parameters:
        ///   - context: The rendering context.
        ///   - fields: The fields to expose in this scope.
        public init(
            context: Context = .detail,
            fields: [String] = []
        ) {
            self.context = context
            self.fields = fields
        }

        // MARK: - Decoding

        /// Decodes a `Scope` from configuration data, with fallback defaults.
        ///
        /// If `context` is not specified, defaults to `.detail`.
        /// If `fields` are not specified, defaults to an empty list.
        public init(
            from decoder: any Decoder
        ) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            let context =
                try container.decodeIfPresent(Context.self, forKey: .context)
                ?? .detail
            let fields =
                try container.decodeIfPresent([String].self, forKey: .fields)
                ?? []

            self.init(context: context, fields: fields)
        }

        // MARK: - Predefined Scopes

        /// A scope for rendering lightweight summaries or IDs for use in references.
        public static var reference: Scope {
            .init(context: .reference)
        }

        /// A scope for rendering content in a list format (e.g., previews, teasers).
        public static var list: Scope {
            .init(context: .list)
        }

        /// A scope for rendering full content in detail pages.
        public static var detail: Scope {
            .init(context: .detail)
        }

        // MARK: - Default Scope Sets

        /// A standard mapping of common context names to their default scopes.
        public static var standard: [String: Scope] {
            [
                "reference": reference,
                "list": list,
                "detail": detail,
            ]
        }

        /// The default fallback scope set, applied to all content types via the `*` wildcard.
        public static var `default`: [String: [String: Scope]] {
            [
                "*": standard
            ]
        }
    }
}
