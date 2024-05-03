
import Markdown


//import FileManagerKit
//import Foundation
//
public struct Toucan {
//
//    public let inputUrl: URL
//    public let outputUrl: URL
//
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
        
        /// Counts `Link`s in a `Document`.
        struct LinkCounter: MarkupWalker {
            var count = 0
            mutating func visitLink(_ link: Link) {
                if link.destination == "https://swift.org" {
                    count += 1
                }
                descendInto(link)
            }
        }
        
        /// Delete all **strong** elements in a markup tree.
        struct StrongDeleter: MarkupRewriter {
            mutating func visitStrong(_ strong: Strong) -> Markup? {
                return nil
            }
        }


        let source = #"""
            There are [two](https://swift.org) links to <https://swift.org> here.
            Now you see me, **now you don't**
            """#

        let document = Document(parsing: source)
//        print(document.debugDescription())
        var linkCounter = LinkCounter()
        linkCounter.visit(document)
//        print(linkCounter.count)

        var strongDeleter = StrongDeleter()
        let newDocument = strongDeleter.visit(document)

        var htmlVisitor = HTMLVisitor()
        let html = htmlVisitor.visitDocument(document)

        print(html)
        
    }

    public func generate(_ baseUrl: String?) throws {
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


