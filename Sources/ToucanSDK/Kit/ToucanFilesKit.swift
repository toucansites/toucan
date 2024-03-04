import FileManagerKit
import Foundation

struct ToucanFilesKit {

    let fileManager = FileManager.default
    var outputUrl: URL = URL(fileURLWithPath: "")
    var contentsUrl: URL = URL(fileURLWithPath: "")
    var templatesUrl: URL = URL(fileURLWithPath: "")
    var postsUrl: URL = URL(fileURLWithPath: "")
    var pagesUrl: URL = URL(fileURLWithPath: "")
    var publicUrl: URL = URL(fileURLWithPath: "")
    var assetsUrl: URL = URL(fileURLWithPath: "")

    var postFileInfos: [ContentFileInfo] = []
    var pageFileInfos: [ContentFileInfo] = []

    mutating func createURLs(_ inputUrl: URL) throws {
        contentsUrl = inputUrl.appendingPathComponent("contents")
        templatesUrl = inputUrl.appendingPathComponent("templates")
        postsUrl = contentsUrl.appendingPathComponent("posts")
        pagesUrl = contentsUrl.appendingPathComponent("pages")
        publicUrl = inputUrl.appendingPathComponent("public")
    }

    mutating func createInfo(needToCopy: Bool) throws {
        let metadataParser = MetadataParser()
        var slugs = Set<String>()

        let postURLs = getContentURLsToProcess(at: postsUrl, using: fileManager)
        for postUrl in postURLs {

            let contentsUrl = postUrl.appendingPathComponent("contents.md")
            let modificationDate = try fileManager.modificationDate(
                at: contentsUrl
            )
            let metaData = try metadataParser.parse(at: contentsUrl)
            let slug = checkSlug(metaData: metaData, slugs: slugs, url: postUrl)
            slugs.insert(slug)

            let availableAssets = try processContentAssets(
                at: postUrl,
                slug: slug,
                assetsUrl: assetsUrl,
                fileManager: fileManager,
                needToCopy: needToCopy
            )
            let hasPostImage = fileManager.fileExists(
                at: postUrl.appendingPathComponent("cover.jpg")
            )

            postFileInfos.append(
                .init(
                    url: postUrl,
                    contentsUrl: contentsUrl,
                    modificationDate: modificationDate,
                    metaData: metaData,
                    availableAssets: availableAssets,
                    hasPostImage: hasPostImage
                )
            )
        }

        let pageURLs = getContentURLsToProcess(at: pagesUrl, using: fileManager)
        for pageUrl in pageURLs {

            let contentsUrl = pageUrl.appendingPathComponent("contents.md")
            let modificationDate = try fileManager.modificationDate(
                at: contentsUrl
            )
            let metaData = try metadataParser.parse(at: contentsUrl)
            let slug = checkSlug(metaData: metaData, slugs: slugs, url: pageUrl)
            slugs.insert(slug)

            let availableAssets = try processContentAssets(
                at: pageUrl,
                slug: slug,
                assetsUrl: assetsUrl,
                fileManager: fileManager,
                needToCopy: needToCopy
            )

            pageFileInfos.append(
                .init(
                    url: pageUrl,
                    contentsUrl: contentsUrl,
                    modificationDate: modificationDate,
                    metaData: metaData,
                    availableAssets: availableAssets,
                    hasPostImage: false
                )
            )
        }
    }

    mutating func createOutputs(_ outputUrl: URL) throws {
        self.outputUrl = outputUrl

        assetsUrl =
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

    }

    func savePostContentToFile(_ slug: String, _ content: String) throws {
        let htmlUrl =
            outputUrl
            .appendingPathComponent(slug)

        if !FileManager.default.directoryExists(at: htmlUrl) {
            try FileManager.default.createDirectory(at: htmlUrl)
        }

        let fileUrl =
            htmlUrl
            .appendingPathComponent("index")
            .appendingPathExtension("html")

        try content
            .write(
                to: fileUrl,
                atomically: true,
                encoding: .utf8
            )
    }

    func savePageContentToFile(_ slug: String, _ content: String) throws {
        let htmlUrl =
            outputUrl
            .appendingPathComponent(slug)
            .appendingPathExtension("html")

        try content
            .write(
                to: htmlUrl,
                atomically: true,
                encoding: .utf8
            )
    }

    func saveHomeContentToFile(_ content: String?) throws {
        let indexOutputUrl =
            outputUrl
            .appendingPathComponent("index")
            .appendingPathExtension("html")

        try content?
            .write(
                to: indexOutputUrl,
                atomically: true,
                encoding: .utf8
            )
    }

    func saveNotFoundContentToFile(_ content: String?) throws {
        let indexOutputUrl =
            outputUrl
            .appendingPathComponent("404")
            .appendingPathExtension("html")

        try content?
            .write(
                to: indexOutputUrl,
                atomically: true,
                encoding: .utf8
            )
    }

    func saveRSSContentToFile(_ content: String?) throws {
        let rssUrl =
            outputUrl
            .appendingPathComponent("rss")
            .appendingPathExtension("xml")

        try content?
            .write(
                to: rssUrl,
                atomically: true,
                encoding: .utf8
            )
    }

    func saveSiteMapContentToFile(_ content: String?) throws {
        let sitemapUrl =
            outputUrl
            .appendingPathComponent("sitemap")
            .appendingPathExtension("xml")

        try content?
            .write(
                to: sitemapUrl,
                atomically: true,
                encoding: .utf8
            )
    }

}
