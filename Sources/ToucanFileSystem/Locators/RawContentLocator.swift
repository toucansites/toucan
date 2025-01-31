import Foundation
import FileManagerKit

public struct RawContentLocator {

    private let fileManager: FileManagerKit
    private let indexFileLocator: FileLocator
    private let noindexFileLocator: FileLocator

    private let indexName = "index"
    private let noindexName = "noindex"
    private let mdExtensions = ["md", "markdown"]
    private let yamlExtensions = ["yaml", "yml"]

    init(fileManager: FileManagerKit) {
        self.fileManager = fileManager
        self.indexFileLocator = .init(
            fileManager: fileManager,
            name: indexName,
            extensions: mdExtensions + yamlExtensions
        )
        self.noindexFileLocator = .init(
            fileManager: fileManager,
            name: noindexName,
            extensions: mdExtensions + yamlExtensions
        )
    }

    func locate(at url: URL) -> [RawContentLocation] {
        loadBundleLocations(at: url)
            .sorted { $0.path < $1.path }
    }
}

private extension RawContentLocator {

    func loadBundleLocations(
        at contentsUrl: URL,
        slug: [String] = [],
        path: [String] = []
    ) -> [RawContentLocation] {
        var result: [RawContentLocation] = []

        let p = path.joined(separator: "/")
        let url = contentsUrl.appendingPathComponent(p)

        let indexFilePaths = indexFileLocator.locate(at: url)
        if indexFilePaths.count > 0 {
            result.append(
                .init(path: p, slug: slug.joined(separator: "/"))
            )
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
            result += loadBundleLocations(
                at: contentsUrl,
                slug: newSlug,
                path: newPath
            )
        }

        // filter out site bundle
        return result.filter { !$0.slug.isEmpty }
    }
}
