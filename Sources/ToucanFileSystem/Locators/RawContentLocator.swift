import Foundation
import FileManagerKit
import ToucanModels

public struct RawContentLocator {

    private let fileManager: FileManagerKit
    private let indexFileLocator: FileLocator
    private let noindexFileLocator: FileLocator

    private let indexName = "index"
    private let noindexName = "noindex"

    public init(
        fileManager: FileManagerKit,
        fileType: RawContentFileType
    ) {
        self.fileManager = fileManager
        self.indexFileLocator = .init(
            fileManager: fileManager,
            name: indexName,
            extensions: fileType.extensions
        )
        self.noindexFileLocator = .init(
            fileManager: fileManager,
            name: noindexName,
            extensions: RawContentFileType.yaml.extensions
        )
    }

    public func locate(at url: URL) -> [Origin] {
        loadRawContents(at: url).sorted { $0.path < $1.path }
    }
}

private extension RawContentLocator {

    func loadRawContents(
        at contentsUrl: URL,
        slug: [String] = [],
        path: [String] = []
    ) -> [Origin] {
        var result: [Origin] = []

        let p = path.joined(separator: "/")
        let url = contentsUrl.appendingPathComponent(p)

        let indexFilePaths = indexFileLocator.locate(at: url).sorted()
        if !indexFilePaths.isEmpty {
            let origin = Origin(
                path: p + "/" + indexFilePaths.first!,
                slug: slug.joined(separator: "/")
            )
            result.append(origin)
        }

        let list = fileManager.listDirectory(at: url)
        for item in list {
            var newSlug = slug
            let childUrl = url.appendingPathComponent(item)

            let noindexFilePaths = noindexFileLocator.locate(at: childUrl)
            if noindexFilePaths.isEmpty {
                newSlug += [item]
            }

            let newPath = path + [item]
            result += loadRawContents(
                at: contentsUrl,
                slug: newSlug,
                path: newPath
            )
        }

        // filter out site raw content
        return result.filter { !$0.slug.isEmpty }
    }
}
