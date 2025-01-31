//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 01. 31..
//

import ToucanModels

// TODO: check if encodable is needed at all?
extension PropertyType: Decodable {

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

    //    public func encode(to encoder: Encoder) throws {
    //        var container = encoder.container(keyedBy: CodingKeys.self)
    //        switch self {
    //        case .bool:
    //            try container.encode(TypeKey.bool, forKey: .type)
    //        case .int:
    //            try container.encode(TypeKey.int, forKey: .type)
    //        case .double:
    //            try container.encode(TypeKey.double, forKey: .type)
    //        case .string:
    //            try container.encode(TypeKey.string, forKey: .type)
    //        case .date(let format):
    //            try container.encode(TypeKey.date, forKey: .type)
    //            try container.encode(format, forKey: .format)
    //        }
    //    }
}
