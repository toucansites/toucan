import FileManagerKit
import Foundation

public struct Toucan {

    public let inputUrl: URL
    public let outputUrl: URL

    public init(
        inputPath: String,
        outputPath: String
    ) {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        func getSafeUrl(_ path: String, home: String) -> URL {
            .init(
                fileURLWithPath: path.replacingOccurrences(["~": home])
            )
            .standardized
        }
        self.inputUrl = getSafeUrl(inputPath, home: home)
        self.outputUrl = getSafeUrl(outputPath, home: home)
    }

    public func generate(_ baseUrl: String?) throws {

        let fileManager = FileManager.default

        // input
        let publicUrl = inputUrl.appendingPathComponent("public")
        let contentsUrl = inputUrl.appendingPathComponent("contents")
        let templatesUrl = inputUrl.appendingPathComponent("templates")
        let postsUrl = contentsUrl.appendingPathComponent("posts")
        let pagesUrl = contentsUrl.appendingPathComponent("pages")

        // output
        let assetsUrl =
            outputUrl
            .appendingPathComponent("images")
            .appendingPathComponent("assets")

        if !fileManager.directoryExists(at: outputUrl) {
            try fileManager.createDirectory(at: outputUrl)
        }

        // wipe output directory if it's probably dist or docs folder
        if outputUrl.path.contains("dist") || outputUrl.path.contains("docs") {
            let list = fileManager.listDirectory(
                at: outputUrl,
                includingHiddenItems: true
            )
            for path in list {
                try fileManager.delete(
                    at: outputUrl.appendingPathComponent(path)
                )
            }
        }

        guard fileManager.listDirectory(at: outputUrl).isEmpty else {
            fatalError("Output directory should be empty.")
        }

        // copy public files
        for path in fileManager.listDirectory(at: publicUrl) {
            try fileManager.copy(
                from: publicUrl.appendingPathComponent(path),
                to: outputUrl.appendingPathComponent(path)
            )
        }

        // create assets directory
        if !fileManager.directoryExists(at: assetsUrl) {
            try fileManager.createDirectory(at: assetsUrl)
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        let metadataParser = MetadataParser()
        let contentParser = ContentParser()
        var slugs = Set<String>()

        let indexUrl = contentsUrl.appendingPathComponent("index.md")
        let indexMeta = try metadataParser.parse(at: indexUrl)

        let config = Config(
            baseUrl: baseUrl ?? indexMeta["baseUrl"] ?? "./",
            title: indexMeta["title"] ?? "Untitled",
            description: indexMeta["description"] ?? "",
            language: indexMeta["language"] ?? "en-US"
        )

        // process posts
        let postURLs = getContentURLsToProcess(at: postsUrl, using: fileManager)
        var posts: [Post] = []
        for url in postURLs {
            let contentsUrl = url.appendingPathComponent("contents.md")
            let modificationDate = try fileManager.modificationDate(
                at: contentsUrl
            )
            let metadata = try metadataParser.parse(at: contentsUrl)
            guard
                let slug = metadata["slug"],
                !slug.isEmpty,
                !slugs.contains(slug)
            else {
                fatalError(
                    "Invalid or missing slug \(metadata["slug"] ?? "n/a"), \(url.path)"
                )
            }
            slugs.insert(slug)

            let availableAssets = try processContentAssets(
                at: url,
                slug: slug,
                assetsUrl: assetsUrl,
                fileManager: fileManager
            )

            let html = try contentParser.parse(
                at: contentsUrl,
                baseUrl: config.baseUrl,
                slug: slug,
                assets: availableAssets
            )

            let meta = getContentMeta(
                slug: slug,
                config: config,
                metadata: metadata
            )

            let tags = (metadata["tags"] ?? "").split(separator: ",")
                .map {
                    $0.trimmingCharacters(in: .whitespacesAndNewlines)
                }

            var postDate = Date()
            if let rawDate = metadata["date"],
                let date = formatter.date(from: rawDate)
            {
                postDate = date
            }
            else {
                print("[WARNING] Date issues in `\(slug)`.")
            }

            let post = Post(
                meta: meta,
                slug: slug,
                date: postDate,
                tags: tags,
                html: html,
                config: config,
                templatesUrl: templatesUrl,
                outputUrl: outputUrl,
                modificationDate: modificationDate,
                userDefined: metadata
            )
            try post.generate()
            posts.append(post)
        }

        var pages: [Page] = []
        // process pages
        let pageURLs = getContentURLsToProcess(at: pagesUrl, using: fileManager)
        for url in pageURLs {
            let contentsUrl = url.appendingPathComponent("contents.md")
            let modificationDate = try fileManager.modificationDate(
                at: contentsUrl
            )
            let metadata = try metadataParser.parse(at: contentsUrl)
            guard
                let slug = metadata["slug"],
                !slug.isEmpty,
                !slugs.contains(slug)
            else {
                fatalError(
                    "Invalid or missing slug \(metadata["slug"] ?? "n/a"), \(url.path)"
                )
            }
            slugs.insert(slug)

            let availableAssets = try processContentAssets(
                at: url,
                slug: slug,
                assetsUrl: assetsUrl,
                fileManager: fileManager
            )

            let html = try contentParser.parse(
                at: contentsUrl,
                baseUrl: "./",
                slug: slug,
                assets: availableAssets
            )

            let meta = getContentMeta(
                slug: slug,
                config: config,
                metadata: metadata
            )

            let page = Page(
                meta: meta,
                slug: slug,
                html: html,
                templatesUrl: templatesUrl,
                outputUrl: outputUrl,
                modificationDate: modificationDate
            )

            try page.generate()
            pages.append(page)
        }

        let home = Home(
            contentsUrl: contentsUrl,
            config: config,
            posts: posts,
            templatesUrl: templatesUrl,
            outputUrl: outputUrl
        )
        try home.generate()

        let notFound = NotFound(
            contentsUrl: contentsUrl,
            config: config,
            posts: posts,
            templatesUrl: templatesUrl,
            outputUrl: outputUrl
        )
        try notFound.generate()

        let rss = RSS(
            config: config,
            posts: posts,
            outputUrl: outputUrl
        )
        try rss.generate()

        let sitemap = Sitemap(
            config: config,
            pages: pages,
            posts: posts,
            outputUrl: outputUrl
        )
        try sitemap.generate()
    }

}

extension Toucan {

    fileprivate func getContentMeta(
        slug: String,
        config: Config,
        metadata: [String: String]
    ) -> Meta {
        .init(
            site: config.title,
            baseUrl: config.baseUrl,
            slug: slug,
            title: metadata["title"] ?? "Untitled",
            description: metadata["description"] ?? "",
            image: "images/assets/" + slug + "/cover.jpg"
        )
    }

    fileprivate func getContentURLsToProcess(
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

    fileprivate func processContentAssets(
        at url: URL,
        slug: String,
        assetsUrl: URL,
        fileManager: FileManager
    ) throws -> [String] {
        var assets: [String] = []
        // create assets dir
        let assetsDir = assetsUrl.appendingPathComponent(slug)
        try fileManager.createDirectory(at: assetsDir)

        // check for image assets
        let imagesUrl = url.appendingPathComponent("images")
        var imageList: [String] = []
        if fileManager.directoryExists(at: imagesUrl) {
            imageList = fileManager.listDirectory(at: imagesUrl)
        }

        // copy image assets
        if !imageList.isEmpty {
            let assetImagesDir = assetsDir.appendingPathComponent("images")
            try fileManager.createDirectory(at: assetImagesDir)

            for image in imageList {
                let sourceUrl = imagesUrl.appendingPathComponent(image)
                let assetPath = assetImagesDir.appendingPathComponent(image)
                try fileManager.copy(from: sourceUrl, to: assetPath)
                assets.append(image)
            }
        }

        // copy cover + dark version
        let coverUrl = url.appendingPathComponent("cover.jpg")
        let coverAssetUrl = assetsDir.appendingPathComponent("cover.jpg")
        if fileManager.fileExists(at: coverUrl) {
            try fileManager.copy(from: coverUrl, to: coverAssetUrl)
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
            try fileManager.copy(from: darkCoverUrl, to: darkCoverAssetUrl)
            assets.append("cover~dark.jpg")
        }
        return assets
    }
}
