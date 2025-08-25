//
//  ToucanDecoderError.swift
//  Toucan
//
//  Created by gerp83 on 2025. 04. 17..
//

import ToucanCore

/// Extension providing a custom `logMessage` for decoding context.
///
/// Transforms the coding path into a readable string or returns the debug description if the path is empty.
extension DecodingError.Context {
    /// A string representation of the decoding path or debug description.
    var logMessage: String {
        var components = [debugDescription]

        if !codingPath.isEmpty {
            components.append("Coding path:")

            let path =
                codingPath
                .map(\.stringValue)
                .joined(separator: ".")

            components.append("`\(path)`.")
        }

        return components.joined(separator: " ")
    }
}

/// Extension to make `DecodingError` conform to the `ToucanError` protocol.
///
/// Provides developer and user-facing messages based on the type of decoding error.
extension DecodingError: ToucanError {
    /// A detailed message describing the decoding failure, including context.
    public var logMessage: String {
        switch self {
        case let .dataCorrupted(context):
            "Data corrupted: \(context.logMessage)"
        case let .keyNotFound(key, context):
            "Key not found: \(key) - \(context.logMessage)"
        case let .typeMismatch(type, context):
            "Type mismatch: \(type) - \(context.logMessage)"
        case let .valueNotFound(type, context):
            "Value not found: \(type) - \(context.logMessage)"
        default:
            "\(self)"
        }
    }

    /// A localized description suitable for displaying to end users.
    public var userFriendlyMessage: String {
        localizedDescription
    }
}

/// A custom error type representing a decoding failure for a specific type.
///
/// Wraps an optional underlying error and includes type information for logging.
public struct ToucanDecoderError: ToucanError {

    /// The type that failed to decode.
    let type: Any.Type
    /// An optional underlying error providing more context.
    let error: Error?

    /// An array containing the underlying error, if any.
    public var underlyingErrors: [any Error] {
        error.map { [$0] } ?? []
    }

    /// A developer-facing message indicating which type failed to decode.
    public var logMessage: String {
        "Type decoding error: `\(type)`."
    }

    /// A user-friendly message indicating a decoding failure.
    public var userFriendlyMessage: String {
        "Could not decode object."
    }

    /// Creates a new `ToucanDecoderError`.
    ///
    /// - Parameters:
    ///   - type: The type that failed decoding.
    ///   - error: An optional underlying error.
    init(
        type: Any.Type,
        error: Error? = nil
    ) {
        self.type = type
        self.error = error
    }
}
