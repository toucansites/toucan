import Foundation
import FileManagerKit

/// A structure for locating files from the filesystem.
public struct OverrideFileLocator {

    private let fileManager: FileManagerKit
    private let fileLocator: FileLocator

    public init(
        fileManager: FileManagerKit,
        extensions: [String]? = nil
    ) {
        self.fileManager = fileManager
        self.fileLocator = .init(
            fileManager: fileManager,
            extensions: extensions
        )
    }

    public func locate(
        at url: URL,
        overrides overridesUrl: URL
    ) -> [OverrideFileLocation] {
        let paths = fileLocator.locate(at: url)
        let overridesPaths = fileLocator.locate(at: overridesUrl)
        let overridesPathsDict = Dictionary(
            grouping: overridesPaths,
            by: \.baseName
        )

        return
            paths
            .map { path in
                let overridePath = overridesPathsDict[path.baseName]?.first
                return .init(path: path, overridePath: overridePath)
            }
            .sorted { $0.path < $1.path }
    }
}
