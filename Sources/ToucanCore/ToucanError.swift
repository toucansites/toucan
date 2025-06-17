//
//  ToucanError.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 20..
//

import Foundation

/// A protocol for custom errors used in the Toucan framework.
///
/// Provides properties for logging, user-facing messages, and a method
/// to format nested error messages in a readable stack-like format.
public protocol ToucanError: Error {
    /// A developer-facing error description used for logging purposes.
    var logMessage: String { get }
    /// A simplified error message suitable for display to end users.
    var userFriendlyMessage: String { get }
    /// A list of underlying errors, useful for representing error hierarchies.
    var underlyingErrors: [Error] { get }
    /// Generates a readable stack-like message of the error and any underlying errors.
    ///
    /// - Returns: A formatted string detailing the error structure.
    func logMessageStack() -> String

    /// Searches for an error of a specific type in the error hierarchy.
    ///
    /// This method traverses the list of underlying errors and attempts to cast
    /// each one to the specified error type `T`. If a match is found, it is returned.
    /// The search is recursive and will descend into nested `ToucanError`s.
    ///
    /// - Parameter errorType: The type of error to search for.
    /// - Returns: An instance of the specified error type if found, otherwise `nil`.
    func lookup<T: Error>(
        _ errorType: T.Type
    ) -> T?

    /// Searches for a specific associated value in the error hierarchy using a custom matcher.
    ///
    /// This method first attempts to locate an error of type `T`, and if successful,
    /// applies the provided matcher closure to extract an associated value.
    ///
    /// - Parameter t: A closure that takes an error of type `T` and returns an associated value of type `V?`.
    /// - Returns: The extracted associated value if found, otherwise `nil`.
    func lookup<T: Error, V>(
        _ t: (T) -> V?
    ) -> V?
}

public extension ToucanError {
    /// Searches for an error of a specific type in the error hierarchy.
    ///
    /// This method traverses the list of underlying errors and attempts to cast
    /// each one to the specified error type `T`. If a match is found, it is returned.
    /// The search is recursive and will descend into nested `ToucanError`s.
    ///
    /// - Parameter errorType: The type of error to search for.
    /// - Returns: An instance of the specified error type if found, otherwise `nil`.
    func lookup<T: Error>(
        _ errorType: T.Type
    ) -> T? {
        for error in underlyingErrors {
            if let match = error as? T {
                return match
            }
            if let match = (error as ToucanError).lookup(errorType) {
                return match
            }
        }
        return nil
    }

    /// Searches for a specific associated value in the error hierarchy using a custom matcher.
    ///
    /// This method first attempts to locate an error of type `T`, and if successful,
    /// applies the provided matcher closure to extract an associated value.
    ///
    /// - Parameter t: A closure that takes an error of type `T` and returns an associated value of type `V?`.
    /// - Returns: The extracted associated value if found, otherwise `nil`.
    func lookup<T: Error, V>(
        _ t: (T) -> V?
    ) -> V? {
        lookup(T.self).flatMap(t)
    }
}

/// Conforms `NSError` to the `ToucanError` protocol, providing
/// default implementations for logging and user-friendly messages.
extension NSError: ToucanError {
    /// A detailed log message composed of the domain, code, and localized description.
    public var logMessage: String {
        "\(domain):\(code) - \(localizedDescription)"
    }

    /// A user-facing message derived from the localized description.
    public var userFriendlyMessage: String {
        "\(localizedDescription)"
    }
}

/// Provides default implementations for `ToucanError` protocol
/// including empty `underlyingErrors` and a recursive `logMessageStack`.
public extension ToucanError {
    /// A default empty list of underlying errors. Can be overridden by conforming types to provide error hierarchies.
    var underlyingErrors: [Error] { [] }

    /// Recursively builds a string that describes the error and its underlying errors in a readable format.
    ///
    /// - Returns: A formatted stack-like string representing the error and any nested underlying errors.
    func logMessageStack() -> String {
        format(error: self)
    }

    /// Recursively formats an error and its underlying errors into a structured log message.
    ///
    /// - Parameters:
    ///   - error: The error to format.
    ///   - prefix: The current indentation prefix.
    ///   - isLast: Indicates whether the error is the last in its group.
    /// - Returns: A formatted string representing the error hierarchy.
    private func format(
        error: Error,
        prefix: String = "",
        isLast: Bool = true
    ) -> String {
        let type = type(of: error)

        var message: String
        var underlyingErrors: [Error]
        switch error {
        case let e as ToucanError:
            message = e.logMessage
            underlyingErrors = e.underlyingErrors
        case let e as LocalizedError:
            message = e.localizedDescription
            underlyingErrors = []
        default:
            message = "\(error)"
            underlyingErrors = []
        }

        let branch = prefix.isEmpty ? "" : (isLast ? "└─ " : "├─ ")
        var output = "\(prefix)\(branch)\(type): \"\(message)\"\n"
        let childPrefix = prefix + (isLast ? "    " : "│   ")

        let childCount = underlyingErrors.count
        for (idx, error) in underlyingErrors.enumerated() {
            let lastChild = (idx == childCount - 1)
            output += format(
                error: error,
                prefix: childPrefix,
                isLast: lastChild
            )
        }

        return output
    }
}
