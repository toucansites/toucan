//
//  Pipeline+DataTypes+Date.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 02. 16..
//

extension Pipeline.DataTypes {

    /// Configuration for handling date formatting across a pipeline,
    /// supporting multiple named formats with optional localization and time zone settings.
    public struct Date: Decodable {

        // MARK: - Coding Keys

        private enum CodingKeys: CodingKey {
            case dateFormats
        }

        // MARK: - Properties

        /// A mapping of named date format identifiers (e.g., `"full"`, `"rss"`, `"iso"`)
        /// to their corresponding localized formatting definitions.
        public var dateFormats: [String: LocalizedDateFormat]

        // MARK: - Defaults

        /// Provides a default configuration with no named date formats.
        public static var defaults: Self {
            .init(dateFormats: [:])
        }

        // MARK: - Initialization

        /// Initializes the date formatting configuration with explicitly defined format mappings.
        ///
        /// - Parameter dateFormats: A dictionary of named formats to localized date format rules.
        public init(dateFormats: [String: LocalizedDateFormat]) {
            self.dateFormats = dateFormats
        }

        // MARK: - Decoding

        /// Decodes a `Date` configuration object from a decoder.
        ///
        /// Falls back to an empty format map if `dateFormats` is not provided.
        ///
        /// - Parameter decoder: The decoder to read from.
        /// - Throws: A decoding error if the structure is malformed.
        public init(
            from decoder: any Decoder
        ) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            let dateFormats =
                try container.decodeIfPresent(
                    [String: LocalizedDateFormat].self,
                    forKey: .dateFormats
                ) ?? [:]

            self.init(dateFormats: dateFormats)
        }
    }
}
