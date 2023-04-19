import FileManagerKit
import Foundation

public struct Toucan {

    let input: URL
    let output: URL

    public init(
        inputPath: String,
        outputPath: String
    ) {
        self.input = URL(fileURLWithPath: inputPath)
        self.output = URL(fileURLWithPath: outputPath)
    }

    public func generate() throws {

        let fileManager = FileManager.default

        // input
        let publicDir = input.appendingPathComponent("public")
        let contentsDir = input.appendingPathComponent("contents")
        let templatesDir = input.appendingPathComponent("templates")
        let postsDir = contentsDir.appendingPathComponent("posts")
        let pagesDir = contentsDir.appendingPathComponent("pages")

        // output
        let assetsDir =
            output
            .appendingPathComponent("images")
            .appendingPathComponent("assets")

        if !fileManager.directoryExists(at: output) {
            try fileManager.createDirectory(at: output)
        }

        // wipe output directory - @TODO: better validation
        if output.path.contains("dist") || output.path.contains("docs") {
            let list = fileManager.listDirectory(
                at: output,
                includingHiddenItems: true
            )
            for path in list {
                try fileManager.delete(at: output.appendingPathComponent(path))
            }
        }
        
        

        // copy public files
        for path in fileManager.listDirectory(at: publicDir) {
            try fileManager.copy(
                from: publicDir.appendingPathComponent(path),
                to: output.appendingPathComponent(path)
            )
        }

        // create assets directory
        if !fileManager.directoryExists(at: assetsDir) {
            try fileManager.createDirectory(at: assetsDir)
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        let metadataParser = MetadataParser()
        let contentParser = ContentParser()
        var slugs = Set<String>()

        let indexUrl = contentsDir.appendingPathComponent("index.md")
        let indexMeta = try metadataParser.parse(at: indexUrl)
        let config = Config(
            baseUrl: indexMeta["baseUrl"] ?? "./",
            title: indexMeta["title"] ?? "Untitled",
            description: indexMeta["description"] ?? "",
            language: indexMeta["description"] ?? "en-US"
        )

        // process posts
        let postURLs = getContentURLsToProcess(at: postsDir, using: fileManager)
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
                assetsDir: assetsDir,
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

            let tags = (metadata["tags"] ?? "").split(separator: ",").map {
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
                templatesDir: templatesDir,
                outputDir: output,
                modificationDate: modificationDate
            )
            try post.generate()
            posts.append(post)
        }

        var pages: [Page] = []
        // process pages
        let pageURLs = getContentURLsToProcess(at: pagesDir, using: fileManager)
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
                assetsDir: assetsDir,
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
                templatesDir: templatesDir,
                outputDir: output,
                modificationDate: modificationDate
            )

            try page.generate()
            pages.append(page)
        }

        let home = Home(
            contentsDir: contentsDir,
            config: config,
            posts: posts,
            templatesDir: templatesDir,
            outputDir: output
        )
        try home.generate()

        let notFound = NotFound(
            contentsDir: contentsDir,
            config: config,
            posts: posts,
            templatesDir: templatesDir,
            outputDir: output
        )
        try notFound.generate()

        let rss = RSS(
            config: config,
            posts: posts,
            outputDir: output
        )
        try rss.generate()

        let sitemap = Sitemap(
            config: config,
            pages: pages,
            posts: posts,
            outputDir: output
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
        assetsDir: URL,
        fileManager: FileManager
    ) throws -> [String] {
        var assets: [String] = []
        // create assets dir
        let assetsDir = assetsDir.appendingPathComponent(slug)
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
