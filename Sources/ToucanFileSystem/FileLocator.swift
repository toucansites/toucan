//
//  FileLocator.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 04. 17..

import Foundation
import FileManagerKit

/// A structure for locating files from the filesystem.
public struct FileLocator {

    /// The file manager used for accessing the filesystem.
    private let fileManager: FileManagerKit

    private let name: String?

    /// An array of file extensions to search for when loading files.
    private let extensions: [String]?

    private let recursively: Bool

    private let skipHiddenFiles: Bool

    /// Initializes a new file locator with optional name and extension filters.
    ///
    /// - Parameters:
    ///   - fileManager: The file system abstraction for reading directories.
    ///   - name: Optional base file name to match (without extension).
    ///   - extensions: Optional array of allowed extensions to filter by.
    ///   - recursively: Recursively check a directory (default: false).
    ///   - skipHiddenFiles: Skips hidden files, name starts with a . character (default: true).
    public init(
        fileManager: FileManagerKit,
        name: String? = nil,
        extensions: [String]? = nil,
        recursively: Bool = false,
        skipHiddenFiles: Bool = true
    ) {
        self.fileManager = fileManager
        self.name = name
        self.extensions = extensions
        self.recursively = recursively
        self.skipHiddenFiles = skipHiddenFiles
    }

    /// Locates files in the specified directory that match the given name and extensions criteria.
    ///
    /// - Parameters: url: The URL of the directory to search.
    /// - Returns: An array of file names that match the specified criteria.
    public func locate(at url: URL) -> [String] {
        var items: [String] = []
        if recursively {
            items = fileManager.listDirectoryRecursively(at: url)
                .map {
                    // Convert to a relative path based on the root URL
                    $0.relativePath(to: url)
                }
        }
        else {
            items = fileManager.listDirectory(at: url)
        }

        if skipHiddenFiles {
            items = items.filter { !$0.hasPrefix(".") }
        }
        return
            items
            .filter { fileName in
                let fileUrl = URL(fileURLWithPath: fileName)
                let baseName = fileUrl.deletingPathExtension().lastPathComponent
                let ext = fileUrl.pathExtension

                switch (name, extensions) {
                case (nil, nil):
                    return true
                case (let name?, nil):
                    return baseName == name
                case (nil, let extensions?):
                    return extensions.contains(ext)
                case (let name?, let extensions?):
                    return baseName == name && extensions.contains(ext)
                }
            }
    }
}
