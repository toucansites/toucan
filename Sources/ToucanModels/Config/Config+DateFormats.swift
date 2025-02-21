//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 02. 21..
//

extension Config {

    public struct DateFormats: Decodable {

        enum CodingKeys: CodingKey {
            case input
            case output
        }

        public var input: String
        public var output: [String: String]

        // MARK: - defaults

        public static var defaults: Self {
            .init(
                input: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
                output: [:]
            )
        }

        // MARK: - init

        public init(
            input: String,
            output: [String: String]
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
                    String.self,
                    forKey: .input
                ) ?? defaults.input

            self.output =
                try container.decodeIfPresent(
                    [String: String].self,
                    forKey: .output
                ) ?? defaults.output
        }
    }
}
