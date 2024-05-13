//
//  File.swift
//
//
//  Created by Tibor Bodecs on 07/05/2024.
//

import Foundation
import Algorithms

struct SiteGenerator {

    let site: Site
    let templatesUrl: URL
    let publicFilesUrl: URL
    let outputUrl: URL
    let fileManager = FileManager.default

    func resetOutputDirectory() throws {
        if fileManager.exists(at: outputUrl) {
            try fileManager.removeItem(at: outputUrl)
        }
        try fileManager.createDirectory(at: outputUrl)
    }

    func copyPublicFiles() throws {
        for file in fileManager.listDirectory(at: publicFilesUrl) {
            try fileManager.copyItem(
                at: publicFilesUrl.appendingPathComponent(file),
                to: outputUrl.appendingPathComponent(file)
            )
        }
    }

    func generate() throws {
        let templates = try TemplateLibrary(
            templatesUrl: templatesUrl
        )
        try resetOutputDirectory()
        try copyPublicFiles()

        let postPages = site.posts
            .sorted(by: { $0.publication > $1.publication })
            .chunks(ofCount: 2)

        let htmlRenderer = HTMLRenderer()

        let postsDirUrl = outputUrl.appendingPathComponent("posts")
        try fileManager.createDirectory(at: postsDirUrl)

        for (index, posts) in postPages.enumerated() {
            let pageIndex = index + 1

            let postPageDirUrl =
                postsDirUrl
                .appendingPathComponent("\(pageIndex)")

            try fileManager.createDirectory(at: postPageDirUrl)

            let postPageUrl =
                postPageDirUrl
                .appendingPathComponent("index.html")

            try renderPostsPage(
                templates,
                posts: Array(posts),
                pageIndex: index,
                pageCount: postPages.count,
                to: postPageUrl
            )

            for post in posts {
                let postDirUrl = outputUrl.appendingPathComponent(post.slug)
                try fileManager.createDirectory(at: postDirUrl)
                let postUrl = postDirUrl.appendingPathComponent("index.html")
                let postBody = htmlRenderer.render(markdown: post.markdown)

                try renderSimplePost(
                    templates,
                    post: post,
                    body: postBody,
                    to: postUrl
                )
            }
        }

        try renderHomePage(templates)
    }

    // MARK: -

    func renderPostsPage(
        _ templates: TemplateLibrary,
        posts: [Post],
        pageIndex index: Int,
        pageCount count: Int,
        to destination: URL
    ) throws {
        let pageIndex = index + 1
        let context = PageContext(
            site: .init(
                baseUrl: site.baseUrl,
                name: site.name,
                tagline: site.tagline,
                imageUrl: site.imageUrl,
                language: site.language
            ),
            metadata: .init(
                permalink: site.permalink("posts/\(pageIndex)"),
                title: "posts page 1",
                description: "posts page 1 description",
                imageUrl: nil
            ),
            content: PostsContext(
                posts: posts.map {
                    post in
                    PostContext(
                        title: post.metatags.title,
                        exceprt: post.metatags.description,
                        date: "\(post.publication)",
                        figure: .init(
                            src: post.metatags.imageUrl ?? "",
                            darkSrc: nil,
                            alt: post.metatags.title,
                            title: post.metatags.title
                        )
                    )
                },
                pagination: (0..<count)
                    .map { idx in
                        let currentPageIndex = idx + 1
                        return .init(
                            name: "\(currentPageIndex)",
                            url: site.permalink("posts/\(currentPageIndex)"),
                            isCurrent: index == idx
                        )
                    }
            )
        )

        try templates.render(
            template: "pages.posts",
            with: context,
            to: destination
        )
    }

    func renderSimplePost(
        _ templates: TemplateLibrary,
        post: Post,
        body: String,
        to destination: URL
    ) throws {

        let context = PageContext(
            site: .init(
                baseUrl: site.baseUrl,
                name: site.name,
                tagline: site.tagline,
                imageUrl: site.imageUrl,
                language: site.language
            ),
            metadata: .init(
                permalink: site.permalink(post.slug),
                title: post.metatags.title,
                description: post.metatags.description,
                imageUrl: post.metatags.imageUrl
            ),
            content: SinglePostContext(
                title: post.metatags.title,
                exceprt: post.metatags.description,
                date: "\(post.publication)",  // TODO: date formatter
                figure: .init(
                    src: "http://lorempixel.com/light.jpg",
                    darkSrc: "http://lorempixel.com/dark.jpg",
                    alt: post.metatags.title,
                    title: post.metatags.title
                ),
                tags: [
                    .init(permalink: site.permalink("foo"), name: "Foo")
                ],
                body: body
            )
        )

        try templates.render(
            template: "pages.single.post",
            with: context,
            to: destination
        )
    }

    func renderHomePage(_ templates: TemplateLibrary) throws {
        let context = PageContext(
            site: .init(
                baseUrl: site.baseUrl,
                name: site.name,
                tagline: site.tagline,
                imageUrl: site.imageUrl,
                language: site.language
            ),
            metadata: .init(
                permalink: site.permalink(""),
                title: "home page",
                description: "home page description",
                imageUrl: nil
            ),
            content: PostsContext(
                posts: [],
                pagination: []
            )
        )

        let indexUrl = outputUrl.appendingPathComponent("index.html")
        try templates.render(
            template: "pages.home",
            with: context,
            to: indexUrl
        )
    }
}

//func processContentAssets(
//        at url: URL,
//        slug: String,
//        assetsUrl: URL,
//        fileManager: FileManager,
//        needToCopy: Bool
//    ) throws -> [String] {
//        var assets: [String] = []
//        // create assets dir
//        let assetsDir = assetsUrl.appendingPathComponent(slug)
//        if needToCopy {
//            try fileManager.createDirectory(at: assetsDir)
//        }
//
//        // check for image assets
//        let imagesUrl = url.appendingPathComponent("images")
//        var imageList: [String] = []
//        if fileManager.directoryExists(at: imagesUrl) {
//            imageList = fileManager.listDirectory(at: imagesUrl)
//        }
//
//        // copy image assets
//        if !imageList.isEmpty {
//            let assetImagesDir = assetsDir.appendingPathComponent("images")
//            if needToCopy {
//                try fileManager.createDirectory(at: assetImagesDir)
//            }
//            for image in imageList {
//                let sourceUrl = imagesUrl.appendingPathComponent(image)
//                let assetPath = assetImagesDir.appendingPathComponent(image)
//                if needToCopy {
//                    try fileManager.copy(from: sourceUrl, to: assetPath)
//                }
//                assets.append(image)
//            }
//        }
//
//        // copy cover + dark version
//        let coverUrl = url.appendingPathComponent("cover.jpg")
//        let coverAssetUrl = assetsDir.appendingPathComponent("cover.jpg")
//        if fileManager.fileExists(at: coverUrl) {
//            if needToCopy {
//                try fileManager.copy(from: coverUrl, to: coverAssetUrl)
//            }
//            assets.append("cover.jpg")
//        }
//        else {
//            print("[WARNING] Cover image issues in `\(slug)`.")
//        }
//
//        // copy dark cover image if exists
//        let darkCoverUrl = url.appendingPathComponent("cover~dark.jpg")
//        let darkCoverAssetUrl = assetsDir.appendingPathComponent(
//            "cover~dark.jpg"
//        )
//        if fileManager.fileExists(at: darkCoverUrl) {
//            if needToCopy {
//                try fileManager.copy(from: darkCoverUrl, to: darkCoverAssetUrl)
//            }
//            assets.append("cover~dark.jpg")
//        }
//        return assets
//    }
//
//}
