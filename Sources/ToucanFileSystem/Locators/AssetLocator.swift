//
//  File.swift
//  toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 03. 03..
//

import Foundation
import FileManagerKit

/// A structure for locating assets from the filesystem.
public struct AssetLocator {

    /// The file manager used for accessing the filesystem.
    private let fileManager: FileManagerKit

    public init(fileManager: FileManagerKit) {
        self.fileManager = fileManager
    }

    public func locate(at url: URL) -> [String] {
        fileManager
            .listDirectoryRecursively(at: url)
            .map { item in
                item.relativePath(to: url)
            }
            .filter {
                !$0.hasPrefix(".")
            }
    }
}
