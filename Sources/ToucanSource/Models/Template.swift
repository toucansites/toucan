//
//  Template.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 01. 31..
//

import Foundation

/// Represents the physical location of a template file, identified by a logical ID.
public struct Template: Equatable {

    /// A unique identifier for the template
    public var id: String

    /// The file system path to the template file relative from the selected template directory.
    public var path: String

    /// Initializes a new `TemplateLocation` with a logical ID and file path.
    ///
    /// - Parameter path: The file path pointing to the template file.
    public init(
        path: String
    ) {
        let basePath =
            path
            .split(separator: ".")
            .dropLast()
            .joined(separator: ".")

        self.id =
            basePath
            .replacingOccurrences(of: "/", with: ".")
        self.path = path
    }
}
