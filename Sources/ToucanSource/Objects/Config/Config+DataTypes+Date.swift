//
//  Config+DataTypes+Date.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 02. 21..
//

extension Config.DataTypes {

    /// Provides a configuration for parsing and formatting dates across the site or contents.
    public struct Date: Codable, Equatable {

        // MARK: - Coding Keys

        private enum CodingKeys: CodingKey {
            case input
            case output
            case formats
        }

        // MARK: - Properties

        /// The expected format for parsing date input strings (typically from front matter or JSON).
        ///
        /// Example: `"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"` (ISO-8601 with milliseconds)
        public var input: DateFormatterConfig

        /// A custom date localization for the standard localized output formats.
        public var output: DateLocalization

        /// A dictionary of named output formats for rendering dates in different contexts.
        ///
        /// Example:
        /// ```yaml
        /// formats:
        ///   short: { format: "MMM d" }
        ///   full: { format: "MMMM d, yyyy" }
        /// ```
        public var formats: [String: DateFormatterConfig]

        // MARK: - Defaults

        /// Returns a default configuration using ISO 8601 parsing and no predefined output formats.
        public static var defaults: Self {
            .init(
                input: .defaults,
                output: .defaults,
                formats: [:]
            )
        }

        // MARK: - Initialization

        /// Initializes a custom date format configuration.
        ///
        /// - Parameters:
        ///   - input: Format used to parse raw date values.
        ///   - output: The date localization config for the standard date outputs.
        ///   - formats: Named formats for rendering parsed dates.
        public init(
            input: DateFormatterConfig,
            output: DateLocalization,
            formats: [String: DateFormatterConfig]
        ) {
            self.input = input
            self.output = output
            self.formats = formats
        }

        // MARK: - Decoding

        /// Decodes the configuration from a serialized source,
        /// applying default values for missing fields.
        public init(
            from decoder: any Decoder
        ) throws {
            let defaults = Self.defaults

            guard
                let container = try? decoder.container(keyedBy: CodingKeys.self)
            else {
                self = defaults
                return
            }

            self.input =
                try container.decodeIfPresent(
                    DateFormatterConfig.self,
                    forKey: .input
                ) ?? defaults.input

            self.output =
                try container.decodeIfPresent(
                    DateLocalization.self,
                    forKey: .output
                ) ?? defaults.output

            self.formats =
                try container.decodeIfPresent(
                    [String: DateFormatterConfig].self,
                    forKey: .formats
                ) ?? defaults.formats
        }
    }
}
