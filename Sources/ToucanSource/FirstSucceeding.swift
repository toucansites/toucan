//
//  FirstSucceeding.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 05. 11..
//

/// Attempts to execute a sequence of throwing closures, returning the first non-nil result.
///
/// Iterates over the provided array of closures and executes each in order.
/// If a closure throws an error, the error is ignored and the next closure is attempted.
/// The function returns the first non-nil value produced by a closure, or `nil` if all closures either throw or return nil.
///
/// - Parameter blocks: An array of throwing closures that each return an optional value.
/// - Returns: The first non-nil result returned by a closure, or `nil` if none succeed.
func firstSucceeding<T>(_ blocks: [() throws -> T?]) -> T? {
    for block in blocks {
        if let result = try? block() {
            return result
        }
    }
    return nil
}
