//
//  Pipeline.DataTypes+Date.swift
//  Toucan
//
//  Created by Tibor Bodecs on 2025. 02. 16..
//

extension Pipeline.DataTypes {

    public struct Date: Decodable {

        enum CodingKeys: CodingKey {
            case dateFormats
        }

        public var dateFormats: [String: LocalizedDateFormat]

        // MARK: - defaults

        public static var defaults: Self {
            .init(dateFormats: [:])
        }

        // MARK: - init

        public init(dateFormats: [String: LocalizedDateFormat]) {
            self.dateFormats = dateFormats
        }

        // MARK: - decoder

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
