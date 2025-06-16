//
//  Behavior.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 06. 16..
//

import struct Foundation.URL

/// A protocol that defines a behavior with a unique identifier
/// and an operation that runs on a given file URL.
protocol Behavior {
    /// A unique identifier for the behavior.
    static var id: String { get }

    /// Executes the behavior with the given file URL.
    ///
    /// - Parameter fileURL: The URL of the file to process.
    /// - Returns: A `String` result of the behavior.
    /// - Throws: An error if the behavior fails.
    func run(fileURL: URL) throws -> String
}
