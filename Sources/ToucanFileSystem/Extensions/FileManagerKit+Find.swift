//
//  FileManagerKit+Find.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 16..

import Foundation
import FileManagerKit

extension FileManagerKit {

    /// Searches for files in the specified directory that match the given name and/or file extensions.
    ///
    /// This method filters the contents of the directory at the provided URL, returning only those
    /// files whose base name and/or extension match the given criteria.
    ///
    /// - Parameters:
    ///   - name: An optional base name to match (without extension). If `nil`, any name is accepted.
    ///   - extensions: An optional array of file extensions to match (e.g., `["json", "txt"]`). If `nil`, any extension is accepted.
    ///   - url: The URL of the directory to search.
    ///
    /// - Returns: An array of file names (as strings) that match the given criteria.
    public func find(
        name: String? = nil,
        extensions: [String]? = nil,
        at url: URL
    ) -> [String] {
        listDirectory(at: url)
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
