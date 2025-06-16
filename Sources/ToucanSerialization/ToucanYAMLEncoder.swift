//
//  ToucanYAMLEncoder.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 03. 06..
//

import struct Foundation.Data
import class Yams.YAMLEncoder

/// A n implementation of `ToucanEncoder` that uses `YAMLEncoder`.
public struct ToucanYAMLEncoder: ToucanEncoder {
    // MARK: - Lifecycle

    /// Initializes a new instance of the YAML encoder.
    public init() {}

    // MARK: - Functions

    /// Encodes a given `Encodable` object into a YAML `String`.
    ///
    /// - Parameter object: The value to encode.
    /// - Returns: A YAML-formatted string representation of the object.
    /// - Throws: `ToucanEncoderError.encoding` if encoding fails.
    public func encode<T: Encodable>(
        _ object: T
    ) throws(ToucanEncoderError) -> String {
        do {
            let encoder = YAMLEncoder()
            encoder.options.sortKeys = true
            return try encoder.encode(object)
        }
        catch {
            throw .init(type: T.self, error: error)
        }
    }
}
