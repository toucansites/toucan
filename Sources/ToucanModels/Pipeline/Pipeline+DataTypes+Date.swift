//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 02. 16..
//

extension Pipeline.DataTypes {

    public struct Date: Decodable {

        enum CodingKeys: CodingKey {
            case formats
        }

        public var formats: [String: LocalizedDateFormat]

        // MARK: - defaults

        public static var defaults: Self {
            .init(formats: [:])
        }

        // MARK: - init

        public init(formats: [String: LocalizedDateFormat]) {
            self.formats = formats
        }

        // MARK: - decoder

        public init(
            from decoder: any Decoder
        ) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            let formats =
                try container.decodeIfPresent(
                    [String: LocalizedDateFormat].self,
                    forKey: .formats
                ) ?? [:]

            self.init(formats: formats)
        }
    }
}
