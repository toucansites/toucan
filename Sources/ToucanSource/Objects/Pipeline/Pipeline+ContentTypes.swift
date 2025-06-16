//
//  Pipeline+ContentTypes.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 02. 03..
//

extension Pipeline {

    /// Defines rules for selecting and filtering content types used in a pipeline.
    ///
    /// `ContentTypes` allows explicit inclusion or exclusion of types, as well as
    /// optional tracking for last modification timestamps.
    public struct ContentTypes: Codable {

        // MARK: - Coding Keys

        private enum CodingKeys: CodingKey {
            case include
            case exclude
            case lastUpdate
            case filterRules
        }

        // MARK: - Properties

        /// A list of content types to explicitly include.
        ///
        /// If this list is empty, all content types are included unless excluded.
        public var include: [String]

        /// A list of content types to explicitly exclude.
        ///
        /// These override entries in `include` and are always filtered out.
        public var exclude: [String]

        /// A list of content types that should be tracked for last update timestamps.
        public var lastUpdate: [String]

        /// A mapping of content type keys to filtering conditions.
        ///
        /// Each key represents a content type (e.g., `"post"`, `"author"`), and its value
        /// defines a condition that must be met for the content to be included in the pipeline.
        /// This enables fine-grained control over which specific content items are published.
        ///
        /// If a content type is not listed in `filterRules`, it is not subject to condition-based filtering.
        public var filterRules: [String: Condition]

        // MARK: - Defaults

        /// Default configuration with no filtering or update tracking.
        public static var defaults: Self {
            .init(
                include: [],
                exclude: [],
                lastUpdate: [],
                filterRules: [:]
            )
        }

        // MARK: - Initialization

        /// Initializes a new `ContentTypes` filter configuration.
        ///
        /// - Parameters:
        ///   - include: List of explicitly allowed content types.
        ///   - exclude: List of content types to exclude from processing.
        ///   - lastUpdate: List of content types to monitor for timestamp changes.
        ///   - filterRules: Mapping of content type keys to conditions used to filter content items.
        public init(
            include: [String],
            exclude: [String],
            lastUpdate: [String],
            filterRules: [String: Condition]
        ) {
            self.include = include
            self.exclude = exclude
            self.lastUpdate = lastUpdate
            self.filterRules = filterRules
        }

        // MARK: - Decoding

        /// Decodes a `ContentTypes` instance from a configuration source (e.g., JSON/YAML).
        ///
        /// Missing fields default to empty arrays.
        public init(
            from decoder: any Decoder
        ) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            let include =
                try container.decodeIfPresent([String].self, forKey: .include)
                ?? []
            let exclude =
                try container.decodeIfPresent([String].self, forKey: .exclude)
                ?? []
            let lastUpdate =
                try container.decodeIfPresent(
                    [String].self,
                    forKey: .lastUpdate
                ) ?? []

            let filterRules: [String: Condition] =
                try container.decodeIfPresent(
                    [String: Condition].self,
                    forKey: .filterRules
                ) ?? [:]

            self.init(
                include: include,
                exclude: exclude,
                lastUpdate: lastUpdate,
                filterRules: filterRules
            )
        }

        // MARK: - Evaluation

        /// Determines whether a given content type should be processed based on inclusion and exclusion rules.
        ///
        /// - Parameter contentType: The content type key (e.g., `"blog"`, `"author"`).
        /// - Returns: `true` if the content type is allowed, `false` otherwise.
        public func isAllowed(contentType: String) -> Bool {
            if exclude.contains(contentType) {
                return false
            }
            if include.isEmpty {
                return true
            }
            return include.contains(contentType)
        }
    }
}
