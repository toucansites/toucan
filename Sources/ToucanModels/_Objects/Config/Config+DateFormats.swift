//
//  Config+DateFormats.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 02. 21..
//

extension Config {

    /// Provides a configuration for parsing and formatting dates across the site or contents.
    public struct DateFormats: Codable, Equatable {

        // MARK: - Coding Keys

        private enum CodingKeys: CodingKey {
            case input
            case output
        }

        // MARK: - Properties

        /// The expected format for parsing date input strings (typically from front matter or JSON).
        ///
        /// Example: `"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"` (ISO-8601 with milliseconds)
        public var input: LocalizedDateFormat

        /// A dictionary of named output formats for rendering dates in different contexts.
        ///
        /// Example:
        /// ```yaml
        /// output:
        ///   short: { format: "MMM d" }
        ///   full: { format: "MMMM d, yyyy" }
        /// ```
        public var output: [String: LocalizedDateFormat]

        // MARK: - Defaults

        /// Returns a default configuration using ISO 8601 parsing and no predefined output formats.
        public static var defaults: Self {
            .init(
                input: .init(format: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"),
                output: [:]
            )
        }

        // MARK: - Initialization

        /// Initializes a custom date format configuration.
        ///
        /// - Parameters:
        ///   - input: Format used to parse raw date values.
        ///   - output: Named formats for rendering parsed dates.
        public init(
            input: LocalizedDateFormat,
            output: [String: LocalizedDateFormat]
        ) {
            self.input = input
            self.output = output
        }

        // MARK: - Decoding

        /// Decodes the configuration from a serialized source,
        /// applying default values for missing fields.
        public init(from decoder: any Decoder) throws {
            let defaults = Self.defaults

            guard
                let container = try? decoder.container(keyedBy: CodingKeys.self)
            else {
                self = defaults
                return
            }

            self.input =
                try container.decodeIfPresent(
                    LocalizedDateFormat.self,
                    forKey: .input
                )
                ?? defaults.input

            self.output =
                try container.decodeIfPresent(
                    [String: LocalizedDateFormat].self,
                    forKey: .output
                )
                ?? defaults.output
        }
    }
}
