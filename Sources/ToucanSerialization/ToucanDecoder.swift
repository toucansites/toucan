//
//  ToucanDecoder.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 01. 29..
//

import Foundation

/// A protocol representing a custom decoder capable of transforming `Data` into strongly typed models.
public protocol ToucanDecoder {

    /// Decodes a `Decodable` type from raw data.
    ///
    /// - Parameters:
    ///   - type: The expected type to decode (conforms to `Decodable`).
    ///   - from: The raw `Data` input (e.g., file contents).
    /// - Returns: A decoded instance of the specified type.
    /// - Throws: `ToucanDecoderError` if decoding fails or data is invalid.
    func decode<T: Decodable>(
        _ type: T.Type,
        from: Data
    ) throws(ToucanDecoderError) -> T
}
