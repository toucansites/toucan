//
//  File.swift
//
//
//  Created by Tibor Bodecs on 03/05/2024.
//

/// A static site generator.
public struct Toucan {

    //    public let inputUrl: URL
    //    public let outputUrl: URL

    /// Creates a new instance.
    public init(
        inputPath: String,
        outputPath: String
    ) {
        //        let home = FileManager.default.homeDirectoryForCurrentUser.path
        //        func getSafeUrl(_ path: String, home: String) -> URL {
        //            .init(
        //                fileURLWithPath: path.replacingOccurrences(["~": home])
        //            )
        //            .standardized
        //        }
        //        self.inputUrl = getSafeUrl(inputPath, home: home)
        //        self.outputUrl = getSafeUrl(outputPath, home: home)
    }

    /// Generates a static site.
    public func generate(
        _ baseUrl: String?
    ) throws {
        //
        //        var toucanFilesKit = ToucanFilesKit()
        //        try toucanFilesKit.createURLs(inputUrl)
        //        try toucanFilesKit.createOutputs(outputUrl)
        //        try toucanFilesKit.createInfo(needToCopy: true)
        //
        //        var toucanContentKit = ToucanContentKit()
        //        try toucanContentKit.create(
        //            baseUrl: baseUrl,
        //            contentsUrl: toucanFilesKit.contentsUrl,
        //            templatesUrl: toucanFilesKit.templatesUrl,
        //            postFileInfos: toucanFilesKit.postFileInfos,
        //            pageFileInfos: toucanFilesKit.pageFileInfos
        //        )
        //
        //        for post in toucanContentKit.posts {
        //            let content = try post.generate()
        //            try toucanFilesKit.savePostContentToFile(post.slug, content)
        //        }
        //
        //        for page in toucanContentKit.pages {
        //            let content = try page.generate()
        //            try toucanFilesKit.savePageContentToFile(page.slug, content)
        //        }
        //
        //        let homeContent = try toucanContentKit.home?.generate()
        //        try toucanFilesKit.saveHomeContentToFile(homeContent)
        //
        //        let notFoundContent = try toucanContentKit.notFound?.generate()
        //        try toucanFilesKit.saveNotFoundContentToFile(notFoundContent)
        //
        //        let rssContent = try toucanContentKit.rss?.generate()
        //        try toucanFilesKit.saveRSSContentToFile(rssContent)
        //
        //        let sitemapContent = try toucanContentKit.sitemap?.generate()
        //        try toucanFilesKit.saveSiteMapContentToFile(sitemapContent)
    }

}
