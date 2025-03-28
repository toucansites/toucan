import Foundation
import FileManagerKit

/// A structure for locating files from the filesystem.
public struct FileLocator {

    /// The file manager used for accessing the filesystem.
    private let fileManager: FileManagerKit

    let name: String?

    /// An array of file extensions to search for when loading files.
    let extensions: [String]?

    public init(
        fileManager: FileManagerKit,
        name: String? = nil,
        extensions: [String]? = nil
    ) {
        self.fileManager = fileManager
        self.name = name
        self.extensions = extensions
    }

    /// Locates files in the specified directory that match the given name and extensions criteria.
    ///
    /// - Parameters:
    ///   - url: The URL of the directory to search.
    /// - Returns: An array of file names that match the specified criteria.
    public func locate(at url: URL) -> [String] {
        fileManager
            .listDirectory(at: url)
            .filter { fileName in
                let url = URL(fileURLWithPath: fileName)
                let baseName = url.deletingPathExtension().lastPathComponent
                let ext = url.pathExtension

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
