//
//  AnyCodable+Json.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 05. 12..
//

import ToucanModels
import Foundation

extension AnyCodable {

    /// Recursively unwraps all nested `AnyCodable` values into Swift-native types, encodable objects are converted into [String: Any] if possible.
    ///
    /// - Returns: A Swift-native representation of the value, unwrapped from any nested `AnyCodable` containers.
    public func unboxed(_ encoder: JSONEncoder) -> Any {
        switch value {
        case let dict as [String: AnyCodable]:
            return dict.unboxed(encoder)
        case let array as [[String: AnyCodable]]:
            return array.map { $0.unboxed(encoder) }
        case let array as [AnyCodable]:
            return array.unboxed(encoder)
        case let nested as AnyCodable:
            return nested.unboxed(encoder)
        case let encodable as Encodable:
            return encodable.toJsonDictionary(encoder) ?? value ?? NSNull()
        default:
            return value ?? NSNull()
        }
    }
}
