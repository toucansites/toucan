import Foundation
import FileManagerKit
import ToucanModels

public struct RawContentLocator {

    private let fileManager: FileManagerKit
    private let indexMarkdownLocator: FileLocator
    private let indexMdLocator: FileLocator
    private let indexYamlLocator: FileLocator
    private let indexYmlLocator: FileLocator
    private let noindexFileLocator: FileLocator

    private let indexName = "index"
    private let noindexName = "noindex"

    public init(fileManager: FileManagerKit) {
        self.fileManager = fileManager
        self.indexMarkdownLocator = .init(
            fileManager: fileManager,
            name: indexName,
            extensions: ["markdown"]
        )
        self.indexMdLocator = .init(
            fileManager: fileManager,
            name: indexName,
            extensions: ["md"]
        )
        self.indexYamlLocator = .init(
            fileManager: fileManager,
            name: indexName,
            extensions: ["yaml"]
        )
        self.indexYmlLocator = .init(
            fileManager: fileManager,
            name: indexName,
            extensions: ["yml"]
        )
        self.noindexFileLocator = .init(
            fileManager: fileManager,
            name: noindexName,
            extensions: ["yaml", "yml"]
        )
    }

    public func locate(at url: URL) -> [RawContentLocation] {
        locateRawContents(at: url).sorted { $0.slug < $1.slug }
    }
}

private extension RawContentLocator {

    func locateRawContents(
        at contentsUrl: URL,
        slug: [String] = [],
        path: [String] = []
    ) -> [RawContentLocation] {
        var result: [RawContentLocation] = []

        let p = path.joined(separator: "/")
        let url = contentsUrl.appendingPathComponent(p)

        var rawContentLocation = RawContentLocation(
            slug: slug.joined(separator: "/")
        )

        if let value = indexMarkdownLocator.locate(at: url).first {
            rawContentLocation.markdown = p + "/" + value
        }
        if let value = indexMdLocator.locate(at: url).first {
            rawContentLocation.md = p + "/" + value
        }
        if let value = indexYamlLocator.locate(at: url).first {
            rawContentLocation.yaml = p + "/" + value
        }
        if let value = indexYmlLocator.locate(at: url).first {
            rawContentLocation.yml = p + "/" + value
        }

        if !rawContentLocation.isEmpty {
            result.append(rawContentLocation)
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
            result += locateRawContents(
                at: contentsUrl,
                slug: newSlug,
                path: newPath
            )
        }

        // filter out site raw content
        return result.filter { !$0.slug.isEmpty }
    }
}
