//
//  CopyManager.swift
//  Toucan
//
//  Created by gerp83 on 2025. 04. 17..
//

import FileManagerKit
import Foundation

/// Responsible for copying static assets from various source locations into the working directory.
public struct CopyManager {

    /// File manager abstraction for performing file operations.
    let fileManager: FileManagerKit

    /// Source configuration, containing paths to asset directories.
    let sources: [URL]

    /// The target directory where all assets should be written.
    let destination: URL

    /// Initializes a new asset writer for copying static files.
    ///
    /// - Parameters:
    ///   - fileManager: The file system manager.
    ///   - sources: Provides paths based on the source urls.
    ///   - destination: Target directory for copying all assets.
    public init(
        fileManager: FileManagerKit,
        sources: [URL],
        destination: URL
    ) {
        self.fileManager = fileManager
        self.sources = sources
        self.destination = destination
    }

    /// Copies all default, overridden, and site-level assets into the working directory.
    ///
    /// - Throws: Errors from the file system if copying fails.
    public func copy() throws {
        for source in sources {
            try fileManager.copyRecursively(
                from: source,
                to: destination
            )
        }
    }
}
