//
//  File.swift
//  ToucanV2
//
//  Created by Tibor Bodecs on 2025. 01. 21..
//

public enum DataType {
    case bool
    case int
    case double
    case string
    case date(format: String?)// => fallback to global date format config
}

extension DataType: Equatable {

    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.bool, .bool), (.int, .int), (.double, .double), (.string, .string):
            return true
        case let (.date(format1), .date(format2)):
            return format1 == format2
        default:
            return false
        }
    }
}

extension DataType: Codable {
    
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
    
    public init(from decoder: Decoder) throws {
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
            let format = try container.decode(String.self, forKey: .format)
            self = .date(format: format)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .bool:
            try container.encode(TypeKey.bool, forKey: .type)
        case .int:
            try container.encode(TypeKey.int, forKey: .type)
        case .double:
            try container.encode(TypeKey.double, forKey: .type)
        case .string:
            try container.encode(TypeKey.string, forKey: .type)
        case .date(let format):
            try container.encode(TypeKey.date, forKey: .type)
            try container.encode(format, forKey: .format)
        }
    }
}
