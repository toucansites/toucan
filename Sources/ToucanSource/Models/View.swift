//
//  View.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 01. 31..
//

import Foundation

/// Represents the physical location of a Mustache file, identified by a logical ID.
public struct View: Equatable {
    /// A unique identifier for the template
    public var id: String

    /// The file system path to the template file relative from the selected template directory.
    public var path: String

    /// The contents of the template file.
    public var contents: String

    /// Creates a new template instance.
    ///
    /// - Parameters:
    ///   - id: A unique identifier for the template.
    ///   - path: The relative file system path of the template file.
    ///   - contents: The full contents of the template file.
    public init(
        id: String,
        path: String,
        contents: String
    ) {
        self.id = id
        self.path = path
        self.contents = contents
    }
}
