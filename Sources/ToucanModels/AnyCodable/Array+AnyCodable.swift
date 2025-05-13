//
//  Array+AnyCodable.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 05. 11..
//

import Foundation

public extension [AnyCodable] {

    /// Returns an array of unboxed elements by applying `unboxed()` to each element in the sequence.
    ///
    /// - Returns: An array containing the result of calling `unboxed()` on each element.
    func unboxed(_ encoder: JSONEncoder) -> [Any] {
        reduce(into: []) { result, element in
            result.append(element.unboxed(encoder))
        }
    }
}
