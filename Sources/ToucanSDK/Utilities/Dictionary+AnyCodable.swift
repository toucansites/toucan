//
//  Dictionary+AnyCodable.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 01. 31..
//

import Foundation
import ToucanSource

public extension [String: AnyCodable] {
    /// Returns a dictionary with the same keys as the original, where each value has been unwrapped or transformed using the `unboxed` method.
    ///
    /// - Returns: A `[String: Any]` dictionary with unboxed values.
    func unboxed(_ encoder: JSONEncoder) -> [String: Any] {
        reduce(into: [:]) { result, element in
            result[element.key] = element.value.unboxed(encoder)
        }
    }
}
