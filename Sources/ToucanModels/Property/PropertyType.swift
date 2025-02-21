//
//  File.swift
//  ToucanV2
//
//  Created by Tibor Bodecs on 2025. 01. 21..
//

public enum PropertyType: Decodable {
    case bool
    case int
    case double
    case string
    case date(format: String?)  // => fallback to global date format config
    
    private enum CodingKeys: String, CodingKey {
        case type
        case format
    }

    private enum TypeKey: String, Codable {
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

extension PropertyType: Equatable {

    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.bool, .bool), (.int, .int), (.double, .double),
            (.string, .string):
            return true
        case let (.date(format1), .date(format2)):
            return format1 == format2
        default:
            return false
        }
    }
}
