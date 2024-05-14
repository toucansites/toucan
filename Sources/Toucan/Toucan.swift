//
//  File.swift
//
//
//  Created by Tibor Bodecs on 03/05/2024.
//

import Foundation
import Algorithms

/// A static site generator.
public struct Toucan {

    let site: Site
    //    let contentsUrl: URL
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

    func copyAssets() throws {
        let tagsDirUrl = outputUrl.appendingPathComponent("assets")
        try fileManager.createDirectory(at: tagsDirUrl)

        // TODO: copy assets for the contents
    }

    func generate() throws {
        // TODO: check reserved slugs
        let templates = try TemplateLibrary(
            templatesUrl: templatesUrl
        )
        try resetOutputDirectory()
        try copyPublicFiles()
        try copyAssets()

        let htmlRenderer = HTMLRenderer()
        try renderPosts(templates, htmlRenderer: htmlRenderer)
        try renderTags(templates, htmlRenderer: htmlRenderer)
        try renderAuthors(templates, htmlRenderer: htmlRenderer)

        let indexUrl = outputUrl.appendingPathComponent("index.html")
        try templates.renderHomePage(site: site, to: indexUrl)
        // TODO: render 404 page
        // TODO: render RSS.xml

        let sitemapUrl = outputUrl.appendingPathComponent("sitemap.xml")
        try templates.renderSitemap(site: site, to: sitemapUrl)
        // TODO: robots.txt?
    }

    // MARK: -

    func renderTags(
        _ templates: TemplateLibrary,
        htmlRenderer: HTMLRenderer
    ) throws {

        let tagsDirUrl = outputUrl.appendingPathComponent("tags")
        try fileManager.createDirectory(at: tagsDirUrl)

        for tag in site.tags {

            let tagPageDirUrl =
                tagsDirUrl
                .appendingPathComponent(tag.slug)

            try fileManager.createDirectory(at: tagPageDirUrl)

            let tagPageUrl =
                tagPageDirUrl
                .appendingPathComponent("index.html")

            let tagBody = htmlRenderer.render(markdown: tag.markdown)

            try templates.renderSingleTag(
                site: site,
                tag: tag,
                body: tagBody,
                to: tagPageUrl
            )
        }

        // TODO: render tags/index.html
    }

    func renderAuthors(
        _ templates: TemplateLibrary,
        htmlRenderer: HTMLRenderer
    ) throws {

        let authorsDirUrl = outputUrl.appendingPathComponent("authors")
        try fileManager.createDirectory(at: authorsDirUrl)

        for author in site.authors {

            let authorPageDirUrl =
                authorsDirUrl
                .appendingPathComponent(author.slug)

            try fileManager.createDirectory(at: authorPageDirUrl)

            let tagPageUrl =
                authorPageDirUrl
                .appendingPathComponent("index.html")

            let tagBody = htmlRenderer.render(markdown: author.markdown)

            try templates.renderSingleAuthor(
                site: site,
                author: author,
                body: tagBody,
                to: tagPageUrl
            )
        }

        // TODO: render authors/index.html
    }

    func renderPosts(
        _ templates: TemplateLibrary,
        htmlRenderer: HTMLRenderer
    ) throws {
        let postPages = site.posts
            .sorted(by: { $0.publication > $1.publication })
            .chunks(ofCount: 2)

        let postsDirUrl = outputUrl.appendingPathComponent("posts")
        try fileManager.createDirectory(at: postsDirUrl)

        for (index, posts) in postPages.enumerated() {
            let pageIndex = index + 1

            let postPageDirUrl =
                postsDirUrl
                .appendingPathComponent("page")
                .appendingPathComponent("\(pageIndex)")

            try fileManager.createDirectory(at: postPageDirUrl)

            let postPageUrl =
                postPageDirUrl
                .appendingPathComponent("index.html")

            // TODO: add canonical if index == 0
            try templates.renderPostsPage(
                site: site,
                posts: Array(posts),
                pageIndex: index,
                pageCount: postPages.count,
                to: postPageUrl
            )

            if index == 0 {
                let postsUrl =
                    postsDirUrl
                    .appendingPathComponent("index.html")
                try templates.renderPostsPage(
                    site: site,
                    posts: Array(posts),
                    pageIndex: index,
                    pageCount: postPages.count,
                    to: postsUrl
                )
            }

            for post in posts {
                let postDirUrl = outputUrl.appendingPathComponent(post.slug)
                try fileManager.createDirectory(at: postDirUrl)
                let postUrl = postDirUrl.appendingPathComponent("index.html")
                let postBody = htmlRenderer.render(markdown: post.markdown)

                try templates.renderSinglePost(
                    site: site,
                    post: post,
                    body: postBody,
                    to: postUrl
                )
            }
        }
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
