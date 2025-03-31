//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 02. 21..
//

extension Config {

    public struct DateFormats: Decodable, Equatable {

        enum CodingKeys: CodingKey {
            case input
            case output
        }

        public var input: LocalizedDateFormat
        public var output: [String: LocalizedDateFormat]

        // MARK: - defaults

        public static var defaults: Self {
            .init(
                input: .init(format: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"),
                output: [:]
            )
        }

        // MARK: - init

        public init(
            input: LocalizedDateFormat,
            output: [String: LocalizedDateFormat]
        ) {
            self.input = input
            self.output = output
        }

        // MARK: - decoder

        public init(
            from decoder: any Decoder
        ) throws {
            let defaults = Self.defaults
            guard
                let container = try? decoder.container(
                    keyedBy: CodingKeys.self
                )
            else {
                self = defaults
                return
            }

            self.input =
                try container.decodeIfPresent(
                    LocalizedDateFormat.self,
                    forKey: .input
                ) ?? defaults.input

            self.output =
                try container.decodeIfPresent(
                    [String: LocalizedDateFormat].self,
                    forKey: .output
                ) ?? defaults.output
        }
    }
}
