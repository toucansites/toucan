//
//  ToucanDecoder.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 01. 29..
//

import struct Foundation.Data

/// A protocol representing a custom decoder capable of transforming `Data` into strongly typed models.
public protocol ToucanDecoder {

    /// Decodes a `Decodable` type from raw data.
    ///
    /// - Parameters:
    ///   - type: The expected type to decode (conforms to `Decodable`).
    ///   - from: The raw `String` input (e.g., file contents as String).
    /// - Returns: A decoded instance of the specified type.
    /// - Throws: `ToucanDecoderError` if decoding fails or data is invalid.
    func decode<T: Decodable>(
        _ type: T.Type,
        from: String
    ) throws(ToucanDecoderError) -> T

    /// Decodes a `Decodable` type from raw data.
    ///
    /// - Parameters:
    ///   - type: The expected type to decode (conforms to `Decodable`).
    ///   - from: The raw `Data` input (e.g., file contents as Data).
    /// - Returns: A decoded instance of the specified type.
    /// - Throws: `ToucanDecoderError` if decoding fails or data is invalid.
    func decode<T: Decodable>(
        _ type: T.Type,
        from: Data
    ) throws(ToucanDecoderError) -> T
}

extension ToucanDecoder {

    public func decode<T: Decodable>(
        _ type: T.Type,
        from string: String
    ) throws(ToucanDecoderError) -> T {
        guard let data = string.data(using: .utf8) else {
            throw ToucanDecoderError.decoding(
                DecodingError.dataCorrupted(
                    .init(
                        codingPath: [],
                        debugDescription:
                            "The string cannot be represented as UTF-8 encoded data."
                    )
                ),
                T.self
            )
        }
        return try decode(type, from: data)
    }
}
