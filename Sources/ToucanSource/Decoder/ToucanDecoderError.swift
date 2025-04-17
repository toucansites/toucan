//
//  ToucanDecoderError.swift
//  Toucan
//
//  Created by gerp83 on 2025. 04. 04.
//

/// Errors thrown by a `ToucanDecoder` during the decoding process.
public enum ToucanDecoderError: Error {

    /// Indicates a failure to decode the given type from raw data.
    ///
    /// - Parameters:
    ///   - error: The original decoding error.
    ///   - type: The `Decodable` type that failed to decode.
    case decoding(Error, Any.Type)
}
