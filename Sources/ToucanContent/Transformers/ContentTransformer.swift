//
//  ContentTransformer.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 02. 21..
//

/// Represents a content transformer command used in a transformation pipeline.
public struct ContentTransformer {

    /// The directory path where the executable is located.
    /// Defaults to `"/usr/local/bin"` if not explicitly specified.
    public var path: String

    /// The name of the executable or script to run.
    public var name: String

    /// Initializes a new `ContentTransformer` with an optional path and required name.
    ///
    /// - Parameters:
    ///   - path: The directory path to the executable. Defaults to `"/usr/local/bin"`.
    ///   - name: The name of the command-line executable or script.
    public init(
        path: String = "/usr/local/bin",
        name: String
    ) {
        self.path = path
        self.name = name
    }
}
