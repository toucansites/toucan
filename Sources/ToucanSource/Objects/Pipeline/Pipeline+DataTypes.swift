//
//  Pipeline+DataTypes.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 30..
//

public extension Pipeline {
    /// Defines how core data types—like date formats—should be interpreted or rendered within a pipeline.
    ///
    /// `DataTypes` is a configuration layer that allows pipelines to specify
    /// localized or project-specific formatting and handling logic for structured data.
    struct DataTypes: Codable, Equatable {

        private enum CodingKeys: CodingKey {
            case date
        }

        /// Returns the default `DataTypes` configuration, using `.defaults` for date formatting.
        public static var defaults: Self {
            .init(date: .defaults)
        }

        /// The configuration used to handle and format date values.
        public var date: Date

        /// Initializes a new `DataTypes` instance.
        ///
        /// - Parameter date: Date format configuration to apply.
        public init(
            date: Date
        ) {
            self.date = date
        }

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
