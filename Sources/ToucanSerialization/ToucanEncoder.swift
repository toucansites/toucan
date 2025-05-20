//
//  ToucanEncoder.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 03. 06..
//

import struct Foundation.Data

/// A protocol representing a custom encoder that serializes `Encodable` types into `String` output.
public protocol ToucanEncoder {

    /// Encodes an object conforming to `Encodable` into a `String` representation.
    ///
    /// - Parameter object: The value to encode.
    /// - Returns: A serialized string output.
    /// - Throws: `ToucanEncoderError` if encoding fails.
    func encode<T: Encodable>(
        _ object: T
    ) throws(ToucanEncoderError) -> String

    /// Encodes an object conforming to `Encodable` into a `Data` representation.
    ///
    /// - Parameter object: The value to encode.
    /// - Returns: The Data representation of the Encodable.
    /// - Throws: `ToucanEncoderError` if encoding fails.
    func encode<T: Encodable>(
        _ object: T
    ) throws(ToucanEncoderError) -> Data
}

extension ToucanEncoder {

    public func encode<T: Encodable>(
        _ object: T
    ) throws(ToucanEncoderError) -> Data {
        let string: String = try encode(object)

        guard let data = string.data(using: .utf8) else {
            throw ToucanEncoderError(
                type: T.self,
                error: EncodingError.invalidValue(
                    string,
                    .init(
                        codingPath: [],
                        debugDescription:
                            "The string cannot be represetned as UTF-8 encoded data."
                    )
                )
            )
        }
        return data
    }
}
