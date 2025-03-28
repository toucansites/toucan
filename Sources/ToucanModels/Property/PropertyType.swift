//
//  File.swift
//  Toucan
//
//  Created by Tibor Bodecs on 2025. 01. 21..
//

public enum PropertyType: Decodable, Equatable {
    case bool
    case int
    case double
    case string
    case date(format: String?)

    private enum CodingKeys: String, CodingKey {
        case type
        case format
    }

    private enum TypeKey: String, Decodable {
        case bool
        case int
        case double
        case string
        case date
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
        case .date:
            let format = try container.decodeIfPresent(
                String.self,
                forKey: .format
            )
            self = .date(format: format)
        }
    }
}
