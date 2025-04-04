//
//  Pipeline+DataTypes.swift
//  Toucan
//
//  Created by Tibor Bodecs on 2025. 02. 16..
//

extension Pipeline {

    public struct DataTypes: Decodable {

        enum CodingKeys: CodingKey {
            case date
        }

        public var date: Date

        // MARK: - defaults

        public static var defaults: Self {
            .init(date: .defaults)
        }

        // MARK: - init

        public init(
            date: Date
        ) {
            self.date = date
        }

        // MARK: - decoder

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
