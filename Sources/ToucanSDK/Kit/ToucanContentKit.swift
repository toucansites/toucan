import Foundation

struct ToucanContentKit {

    var posts: [Post] = []
    var pages: [Page] = []
    var home: Home? = nil
    var notFound: NotFound? = nil
    var rss: RSS? = nil
    var sitemap: Sitemap? = nil

    mutating func create(
        baseUrl: String?,
        contentsUrl: URL,
        templatesUrl: URL,
        postFileInfos: [ContentFileInfo],
        pageFileInfos: [ContentFileInfo]
    ) throws {

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        let metadataParser = MetadataParser()
        let contentParser = ContentParser()

        let indexUrl = contentsUrl.appendingPathComponent("index.md")
        let indexMeta = try metadataParser.parse(at: indexUrl)
        let postCoverImageTemplateUrl = templatesUrl.appendingPathComponent(
            "post-cover-image.html"
        )
        let postCoverImageTemplate = try String(
            contentsOf: postCoverImageTemplateUrl
        )

        let config = Config(
            baseUrl: baseUrl ?? indexMeta["baseUrl"] ?? "./",
            title: indexMeta["title"] ?? "Untitled",
            description: indexMeta["description"] ?? "",
            language: indexMeta["language"] ?? "en-US"
        )

        // process posts
        for postInfo in postFileInfos {

            guard let slug = postInfo.metaData["slug"] else {
                fatalError(
                    "Invalid or missing slug \(postInfo.metaData["slug"] ?? "n/a"), \(postInfo.url.path)"
                )
            }
            let html = try contentParser.parse(
                at: postInfo.contentsUrl,
                baseUrl: config.baseUrl,
                slug: slug,
                assets: postInfo.availableAssets
            )

            let meta = getContentMeta(
                slug: slug,
                config: config,
                metadata: postInfo.metaData
            )

            let tags = (postInfo.metaData["tags"] ?? "").split(separator: ",")
                .map {
                    $0.trimmingCharacters(in: .whitespacesAndNewlines)
                }

            var postDate = Date()
            if let rawDate = postInfo.metaData["date"],
                let date = formatter.date(from: rawDate)
            {
                postDate = date
            }
            else {
                print("[WARNING] Date issues in `\(slug)`.")
            }

            var postCoverImageHtml = ""
            if postInfo.hasPostImage {
                postCoverImageHtml = postCoverImageTemplate
            }

            let post = Post(
                meta: meta,
                slug: slug,
                date: postDate,
                tags: tags,
                html: html,
                postCoverImageHtml: postCoverImageHtml,
                config: config,
                templatesUrl: templatesUrl,
                modificationDate: postInfo.modificationDate,
                userDefined: postInfo.metaData
            )

            posts.append(post)
        }

        // process pages
        for pageInfo in pageFileInfos {

            guard let slug = pageInfo.metaData["slug"] else {
                fatalError(
                    "Invalid or missing slug \(pageInfo.metaData["slug"] ?? "n/a"), \(pageInfo.url.path)"
                )
            }
            let html = try contentParser.parse(
                at: pageInfo.contentsUrl,
                baseUrl: "./",
                slug: slug,
                assets: pageInfo.availableAssets
            )

            let meta = getContentMeta(
                slug: slug,
                config: config,
                metadata: pageInfo.metaData
            )

            let page = Page(
                meta: meta,
                slug: slug,
                html: html,
                templatesUrl: templatesUrl,
                modificationDate: pageInfo.modificationDate
            )
            pages.append(page)
        }

        home = Home(
            contentsUrl: contentsUrl,
            config: config,
            posts: posts,
            templatesUrl: templatesUrl
        )

        notFound = NotFound(
            contentsUrl: contentsUrl,
            config: config,
            posts: posts,
            templatesUrl: templatesUrl
        )

        rss = RSS(
            config: config,
            posts: posts
        )

        sitemap = Sitemap(
            config: config,
            pages: pages,
            posts: posts
        )

    }

}
