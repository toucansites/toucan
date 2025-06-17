//
//  ToucanJSONDecoder.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 04. 17..

import struct Foundation.Data
import class Foundation.JSONDecoder

/// An implementation of `ToucanDecoder` that uses `JSONDecoder`.
public struct ToucanJSONDecoder: ToucanDecoder {
    // MARK: - Lifecycle

    /// Initializes a new instance of `ToucanJSONDecoder`.
    ///
    /// Uses a `JSONDecoder` that allows JSON5 parsing by default.
    public init() {}

    // MARK: - Functions

    /// Decodes a JSON or JSON5-encoded `Data` object into a strongly-typed model.
    ///
    /// - Parameters:
    ///   - type: The target `Decodable` type.
    ///   - data: Raw data to decode.
    /// - Returns: A decoded instance of the provided type.
    /// - Throws: `ToucanDecoderError.decoding` if decoding fails.
    public func decode<T: Decodable>(
        _ type: T.Type,
        from data: Data
    ) throws(ToucanDecoderError) -> T {
        do {
            let decoder = JSONDecoder()
            decoder.allowsJSON5 = true
            return try decoder.decode(type, from: data)
        }
        catch {
            throw .init(type: T.self, error: error)
        }
    }
}
