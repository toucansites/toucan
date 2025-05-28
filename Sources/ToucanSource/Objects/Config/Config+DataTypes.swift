//
//  Pipeline+DataTypes.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 02. 16..
//

extension Config {

    /// Defines how core data types—like date formats—should be interpreted or rendered within a pipeline.
    ///
    /// `DataTypes` is a configuration layer that allows pipelines to specify
    /// localized or project-specific formatting and handling logic for structured data.
    public struct DataTypes: Codable, Equatable {

        // MARK: - Coding Keys

        private enum CodingKeys: CodingKey {
            case date
        }

        // MARK: - Properties

        /// The configuration used to handle and format date values.
        public var date: Date

        // MARK: - Defaults

        /// Returns the default `DataTypes` configuration, using `.defaults` for date formatting.
        public static var defaults: Self {
            .init(date: .defaults)
        }

        // MARK: - Initialization

        /// Initializes a new `DataTypes` instance.
        ///
        /// - Parameter date: Date format configuration to apply.
        public init(
            date: Date
        ) {
            self.date = date
        }

        // MARK: - Decoding

        /// Decodes a `DataTypes` configuration from serialized input.
        ///
        /// Defaults to `.defaults` if the `date` field is missing.
        ///
        /// - Parameter decoder: The decoder to parse configuration from.
        /// - Throws: A decoding error if any value is invalid.
        public init(
            from decoder: any Decoder
        ) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            let date =
                try container.decodeIfPresent(
                    Date.self,
                    forKey: .date
                ) ?? .defaults

            self.init(date: date)
        }
    }
}
