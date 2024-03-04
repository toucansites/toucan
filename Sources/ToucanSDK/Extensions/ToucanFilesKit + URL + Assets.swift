import FileManagerKit
import Foundation

extension ToucanFilesKit {

    func checkSlug(
        metaData: [String: String],
        slugs: Set<String>,
        url: URL
    ) -> String {
        guard
            let slug = metaData["slug"],
            !slug.isEmpty,
            !slugs.contains(slug)
        else {
            fatalError(
                "Invalid or missing slug \(metaData["slug"] ?? "n/a"), \(url.path)"
            )
        }
        return slug
    }

    func getContentURLsToProcess(
        at url: URL,
        using fileManager: FileManager = .default
    ) -> [URL] {
        var toProcess: [URL] = []
        let dirEnum = fileManager.enumerator(atPath: url.path)
        while let file = dirEnum?.nextObject() as? String {
            let url = url.appendingPathComponent(file)
            guard url.lastPathComponent.lowercased() == "contents.md" else {
                continue
            }
            toProcess.append(url.deletingLastPathComponent())
        }
        return toProcess
    }

    func processContentAssets(
        at url: URL,
        slug: String,
        assetsUrl: URL,
        fileManager: FileManager,
        needToCopy: Bool
    ) throws -> [String] {
        var assets: [String] = []
        // create assets dir
        let assetsDir = assetsUrl.appendingPathComponent(slug)
        if needToCopy {
            try fileManager.createDirectory(at: assetsDir)
        }

        // check for image assets
        let imagesUrl = url.appendingPathComponent("images")
        var imageList: [String] = []
        if fileManager.directoryExists(at: imagesUrl) {
            imageList = fileManager.listDirectory(at: imagesUrl)
        }

        // copy image assets
        if !imageList.isEmpty {
            let assetImagesDir = assetsDir.appendingPathComponent("images")
            if needToCopy {
                try fileManager.createDirectory(at: assetImagesDir)
            }
            for image in imageList {
                let sourceUrl = imagesUrl.appendingPathComponent(image)
                let assetPath = assetImagesDir.appendingPathComponent(image)
                if needToCopy {
                    try fileManager.copy(from: sourceUrl, to: assetPath)
                }
                assets.append(image)
            }
        }

        // copy cover + dark version
        let coverUrl = url.appendingPathComponent("cover.jpg")
        let coverAssetUrl = assetsDir.appendingPathComponent("cover.jpg")
        if fileManager.fileExists(at: coverUrl) {
            if needToCopy {
                try fileManager.copy(from: coverUrl, to: coverAssetUrl)
            }
            assets.append("cover.jpg")
        }
        else {
            print("[WARNING] Cover image issues in `\(slug)`.")
        }

        // copy dark cover image if exists
        let darkCoverUrl = url.appendingPathComponent("cover~dark.jpg")
        let darkCoverAssetUrl = assetsDir.appendingPathComponent(
            "cover~dark.jpg"
        )
        if fileManager.fileExists(at: darkCoverUrl) {
            if needToCopy {
                try fileManager.copy(from: darkCoverUrl, to: darkCoverAssetUrl)
            }
            assets.append("cover~dark.jpg")
        }
        return assets
    }

}
