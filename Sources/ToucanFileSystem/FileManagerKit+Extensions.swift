//
//  FileManagerKit+Extensions.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 04. 17..

import Foundation
import FileManagerKit

extension FileManagerKit {

    /// Find files in the specified directory that match the given name and extensions criteria.
    ///
    /// - Parameters: url: The URL of the directory to search.
    /// - Returns: An array of file names that match the specified criteria.
    public func find(
        name: String? = nil,
        extensions: [String]? = nil,
        recursively: Bool = false,
        skipHiddenFiles: Bool = true,
        at url: URL
    ) -> [String] {
        var items: [String] = []
        if recursively {
            items = listDirectoryRecursively(at: url)
                .map {
                    // Convert to a relative path based on the root URL
                    $0.relativePath(to: url)
                }
        }
        else {
            items = listDirectory(at: url)
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
