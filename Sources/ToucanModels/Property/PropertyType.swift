//
//  PropertyType.swift
//  Toucan
//
//  Created by Tibor Bodecs on 2025. 01. 21..
//

public indirect enum PropertyType: Decodable, Equatable {
    case bool
    case int
    case double
    case string
    case date(format: LocalizedDateFormat?)
    case array(of: PropertyType)

    private enum CodingKeys: String, CodingKey {
        case of
        case type
        case dateFormat
    }

    private enum TypeKey: String, Decodable {
        case bool
        case int
        case double
        case string
        case date
        case array
    }

    // MARK: - decoder

    public init(
        from decoder: Decoder
    ) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(TypeKey.self, forKey: .type)

        switch type {
        case .bool:
            self = .bool
        case .int:
            self = .int
        case .double:
            self = .double
        case .string:
            self = .string
        case .array:
            // TODO: test decoding
            let itemType = try container.decode(
                PropertyType.self,
                forKey: .of
            )
            self = .array(of: itemType)
        case .date:
            let format = try container.decodeIfPresent(
                LocalizedDateFormat.self,
                forKey: .dateFormat
            )
            self = .date(format: format)
        }
    }
}
