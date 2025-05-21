//
//  ToucanEncoderError.swift
//  Toucan
//
//  Created by gerp83 on 2025. 04. 17..
//

import ToucanCore

/// Extension to make `EncodingError` conform to the `ToucanError` protocol.
///
/// Provides developer and user-facing messages based on the encoding error.
extension EncodingError: ToucanError {

    /// A detailed log message representing the encoding error.
    public var logMessage: String {
        "\(self)"
    }

    /// A localized description suitable for display to end users.
    public var userFriendlyMessage: String {
        localizedDescription
    }
}

/// A custom error type representing a failure to encode a specific type.
///
/// Wraps an optional underlying error and includes the associated type information.
public struct ToucanEncoderError: ToucanError {

    /// The type that failed to encode.
    let type: Any.Type
    /// An optional underlying error providing additional context.
    let error: Error?

    /// Creates a new `ToucanEncoderError`.
    ///
    /// - Parameters:
    ///   - type: The type that failed encoding.
    ///   - error: An optional underlying error.
    init(
        type: Any.Type,
        error: Error? = nil
    ) {
        self.type = type
        self.error = error
    }

    /// An array containing the underlying error, if present.
    public var underlyingErrors: [any Error] {
        error.map { [$0] } ?? []
    }

    /// A developer-facing message describing the type that failed to encode.
    public var logMessage: String {
        "Type encoding error: `\(type)`."
    }

    /// A user-facing message indicating that the object could not be encoded.
    public var userFriendlyMessage: String {
        "Could not encode object."
    }
}
