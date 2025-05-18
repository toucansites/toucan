//
//  File.swift
//  toucan
//
//  Created by Tibor Bödecs on 2025. 05. 18..
//

import struct Foundation.Data
import class Foundation.JSONEncoder

/// An implementation of `ToucanEncoder` that uses JSON`.
public struct ToucanJSONEncoder: ToucanEncoder {

    /// Initializes a new instance of the JSON encoder.
    public init() {}

    /// Encodes a given `Encodable` object into a JSON `String`.
    ///
    /// - Parameter object: The value to encode.
    /// - Returns: A YAML-formatted string representation of the object.
    /// - Throws: `ToucanEncoderError.encoding` if encoding fails.
    public func encode<T: Encodable>(
        _ object: T
    ) throws(ToucanEncoderError) -> String {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [
                .sortedKeys,
                .prettyPrinted,
                .withoutEscapingSlashes,
            ]
            let data = try encoder.encode(object)
            guard let string = String(data: data, encoding: .utf8) else {
                throw ToucanEncoderError.encoding(
                    EncodingError.invalidValue(
                        data,
                        .init(
                            codingPath: [],
                            debugDescription:
                                "The data cannot be represetned as UTF-8 encoded string."
                        )
                    ),
                    T.self
                )
            }
            return string
        }
        catch {
            throw .encoding(error, T.self)
        }
    }

}
