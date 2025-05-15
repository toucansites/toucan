//
//  ToucanEncoder.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 03. 06..
//

import Foundation

/// A protocol representing a custom encoder that serializes `Encodable` types into `String` output.
public protocol ToucanEncoder {

    /// Encodes an object conforming to `Encodable` into a `String` representation.
    ///
    /// - Parameter object: The value to encode.
    /// - Returns: A serialized string output (e.g., JSON or YAML).
    /// - Throws: `ToucanEncoderError` if encoding fails.
    func encode<T: Encodable>(
        _ object: T
    ) throws(ToucanEncoderError) -> String
}
