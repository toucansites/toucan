//
//  TemplateLocation.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 01. 31..
//

import Foundation

/// Represents the physical location of a template file, identified by a logical ID.
public struct Template: Equatable {

    /// A unique identifier for the template
    public let id: String

    /// The full file system path to the template file.
    public let path: String

    /// Initializes a new `TemplateLocation` with a logical ID and file path.
    ///
    /// - Parameters:
    ///   - id: A unique string identifier for referencing the template.
    ///   - path: The file path pointing to the template file.
    public init(id: String, path: String) {
        self.id = id
        self.path = path
    }
}
