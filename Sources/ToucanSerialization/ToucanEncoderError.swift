//
//  ToucanEncoderError.swift
//  Toucan
//
//  Created by gerp83 on 2025. 04. 17..
//

/// Errors thrown by a `ToucanEncoder` during the encoding process.
public enum ToucanEncoderError: Error {

    /// Indicates a failure to encode the object due to an underlying error.
    ///
    /// - Parameters:
    ///   - error: The original encoding error.
    ///   - type: The type that failed to encode.
    case encoding(Error, Any.Type)
}
