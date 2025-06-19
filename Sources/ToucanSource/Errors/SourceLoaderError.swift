//
//  SourceLoaderError.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 21..
//

import ToucanCore

/// A custom error type representing failures during the source loading process.
///
/// Wraps the type of failure and an optional underlying error for context.
public struct SourceLoaderError: ToucanError {

    /// A string representing the type of component that failed to load.
    let type: String
    /// An optional error providing additional context about the failure.
    let error: Error?

    /// An array containing the underlying error if available, used for nested error representation.
    public var underlyingErrors: [Error] {
        error.map { [$0] } ?? []
    }

    /// A developer-facing message indicating the type that failed to load.
    public var logMessage: String {
        "Could not load: `\(type)`."
    }

    /// A user-facing message indicating a generic failure to load source content.
    public var userFriendlyMessage: String {
        "Could not load source."
    }

    /// Initializes a new `SourceLoaderError`.
    ///
    /// - Parameters:
    ///   - type: A string indicating the failed component type.
    ///   - error: An optional error that triggered the failure.
    init(
        type: String,
        error: Error? = nil
    ) {
        self.type = type
        self.error = error
    }
}
