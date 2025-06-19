//
//  Destination.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 02. 21..
//

/// Represents the destination location and filename for rendered or transformed content.
public struct Destination: Sendable {

    /// The relative or absolute path to the target directory where the file should be placed.
    public var path: String

    /// The base name of the file (without extension).
    public var file: String

    /// The file extension (e.g., "html", "json", "md").
    public var ext: String

    // MARK: - Lifecycle

    /// Initializes a new `Destination` describing where and how a file should be written.
    ///
    /// - Parameters:
    ///   - path: The directory path to write the file to.
    ///   - file: The base file name (without extension).
    ///   - ext: The file extension (e.g., `"html"`, `"json"`).
    public init(
        path: String,
        file: String,
        ext: String
    ) {
        self.path = path
        self.file = file
        self.ext = ext
    }
}
