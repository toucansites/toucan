//
//  AnyCodable+Json.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 05. 12..
//

import Foundation
import ToucanSource

public extension AnyCodable {
    /// Recursively unwraps all nested `AnyCodable` values into Swift-native types, encodable objects are converted into [String: Any] if possible.
    ///
    /// - Returns: A Swift-native representation of the value, unwrapped from any nested `AnyCodable` containers.
    func unboxed(_ encoder: JSONEncoder) -> Any {
        switch value {
        case let dict as [String: AnyCodable]:
            dict.unboxed(encoder)
        case let array as [[String: AnyCodable]]:
            array.map { $0.unboxed(encoder) }
        case let array as [AnyCodable]:
            array.unboxed(encoder)
        case let nested as AnyCodable:
            nested.unboxed(encoder)
        case let encodable as Encodable:
            encodable.toJSONDictionary(encoder) ?? value ?? NSNull()
        default:
            value ?? NSNull()
        }
    }
}
