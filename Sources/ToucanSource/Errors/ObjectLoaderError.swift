//
//  ObjectLoaderError.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 21..
//

import struct Foundation.URL
import ToucanCore

/// A custom error type representing a failure to load or decode a file.
///
/// Wraps the file URL and an optional underlying error for context and debugging.
public struct ObjectLoaderError: ToucanError {
    // MARK: - Properties

    /// The URL of the file that caused the error.
    let url: URL
    /// The underlying error that occurred during loading or decoding.
    let error: Error?

    // MARK: - Computed Properties

    /// An array containing the underlying error if present.
    public var underlyingErrors: [Error] {
        error.map { [$0] } ?? []
    }

    /// A developer-facing log message including the path of the failed file.
    public var logMessage: String {
        "File issue at: `\(url.path())`."
    }

    /// A user-facing message indicating a loading failure.
    public var userFriendlyMessage: String {
        "Could not load object."
    }

    // MARK: - Lifecycle

    /// Initializes a new `ObjectLoaderError`.
    ///
    /// - Parameters:
    ///   - url: The URL of the file involved in the error.
    ///   - error: An optional underlying error.
    init(
        url: URL,
        error: Error? = nil
    ) {
        self.url = url
        self.error = error
    }
}
