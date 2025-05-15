//
//  ToucanYAMLEncoder.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 03. 06..
//

import Foundation
import Yams

/// A n implementation of `ToucanEncoder` that uses `YAMLEncoder`.
public struct ToucanYAMLEncoder: ToucanEncoder {

    /// Initializes a new instance of the YAML encoder.
    public init() {}

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
            return try encoder.encode(object)
        }
        catch {
            throw .encoding(error, T.self)
        }
    }
}
