//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 02. 16..
//

extension Pipeline {

    public struct DataTypes: Decodable {

        enum CodingKeys: CodingKey {
            case date
        }

        public var date: Date

        // MARK: - init

        public init(
            date: Date
        ) {
            self.date = date
        }
        
        // TODO: use `defauls` instead
        public init() {
            self.date = .init(formats: [:])
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
                ) ?? .init(formats: [:])

            self.init(date: date)
        }

    }

}
