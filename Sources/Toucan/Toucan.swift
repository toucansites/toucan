//
//  File.swift
//
//
//  Created by Tibor Bodecs on 03/05/2024.
//

import Foundation
import FileManagerKit

/// A static site generator.
public struct Toucan {

    public enum Files {
        static let index = "index.html"
        static let notFound = "404.html"
        static let rss = "rss.xml"
        static let sitemap = "sitemap.xml"
        static let site = "site.md"
    }

    public enum Directories {
        static let assets: String = "assets"
        static let authors: String = "authors"
        static let pages: String = "pages"
        static let posts: String = "posts"
        static let postsPage: String = "page"
        static let tags: String = "tags"
    }

    let inputUrl: URL
    let outputUrl: URL

    init(
        inputUrl: URL,
        outputUrl: URL
    ) {
        self.inputUrl = inputUrl
        self.outputUrl = outputUrl
    }

    var publicFilesUrl: URL { inputUrl.appendingPathComponent("public") }
    var templatesUrl: URL { inputUrl.appendingPathComponent("templates") }
    var contentsUrl: URL { inputUrl.appendingPathComponent("contents") }

    let fileManager = FileManager.default

    func resetOutputDirectory() throws {
        if fileManager.exists(at: outputUrl) {
            try fileManager.delete(at: outputUrl)
        }
        try fileManager.createDirectory(at: outputUrl)
    }

    /// copy all the public files
    func copyPublicFiles() throws {
        for file in fileManager.listDirectory(at: publicFilesUrl) {
            try fileManager.copy(
                from: publicFilesUrl.appendingPathComponent(file),
                to: outputUrl.appendingPathComponent(file)
            )
        }
    }

    /// prepares all the output directories
    func prepareDirectories(site: Site) throws {
        let assetsDirUrl = outputUrl.appendingPathComponent(Directories.assets)
        try fileManager.createDirectory(at: assetsDirUrl)

        let assetDirectories = [
            Directories.authors,
            Directories.pages,
            Directories.posts,
            Directories.tags,
        ]
        for dir in assetDirectories {
            let assetDirUrl = assetsDirUrl.appendingPathComponent(dir)
            try fileManager.createDirectory(at: assetDirUrl)
        }

        let authorsDirUrl =
            outputUrl
            .appendingPathComponent(Directories.authors)
        try fileManager.createDirectory(at: authorsDirUrl)

        for author in site.authors {
            let authorUrl = authorsDirUrl.appendingPathComponent(author.slug)
            try fileManager.createDirectory(at: authorUrl)
        }

        for page in site.customPages {
            let pageUrl = outputUrl.appendingPathComponent(page.slug)
            try fileManager.createDirectory(at: pageUrl)
        }

        let postsDirUrl = outputUrl.appendingPathComponent(Directories.posts)
        try fileManager.createDirectory(at: postsDirUrl)

        for post in site.posts {
            let postUrl = postsDirUrl.appendingPathComponent(post.slug)
            try fileManager.createDirectory(at: postUrl)
        }

        let postsPageDirUrl =
            postsDirUrl
            .appendingPathComponent(Directories.postsPage)
        for (index, _) in site.postChunks.enumerated() {
            let pageIndex = index + 1
            let pageDirUrl =
                postsPageDirUrl
                .appendingPathComponent(String(pageIndex))
            try fileManager.createDirectory(at: pageDirUrl)
        }

        let tagsDirUrl = outputUrl.appendingPathComponent(Directories.tags)
        try fileManager.createDirectory(at: tagsDirUrl)

        for tag in site.tags {
            let tagUrl = tagsDirUrl.appendingPathComponent(tag.slug)
            try fileManager.createDirectory(at: tagUrl)
        }

    }

    /// copy one asset type using a directory a source identifier and a target slug
    private func copyAsset(
        directory: String,
        id: String,
        slug: String
    ) throws {
        let assetInputUrl =
            contentsUrl
            .appendingPathComponent(directory)
            .appendingPathComponent(id)

        if fileManager.directoryExists(at: assetInputUrl) {
            let assetOutputUrl =
                outputUrl
                .appendingPathComponent(Directories.assets)
                .appendingPathComponent(directory)
                .appendingPathComponent(slug)

            try fileManager.copy(
                from: assetInputUrl,
                to: assetOutputUrl
            )
        }
    }

    /// copy all the assets for the site
    func copyAssets(site: Site) throws {

        for author in site.authors {
            try copyAsset(
                directory: Directories.authors,
                id: author.id,
                slug: author.slug
            )
        }

        for page in site.pages {
            try copyAsset(
                directory: Directories.pages,
                id: page.id,
                slug: page.slug
            )
        }

        for post in site.posts {
            try copyAsset(
                directory: Directories.posts,
                id: post.id,
                slug: post.slug
            )
        }

        for tag in site.tags {
            try copyAsset(
                directory: Directories.tags,
                id: tag.id,
                slug: tag.slug
            )
        }
    }

    /// builds the static site
    func build() throws {

        let contentLoader = ContentLoader(
            path: contentsUrl.path
        )
        let site = try contentLoader.load()

        try resetOutputDirectory()

        try copyPublicFiles()
        try prepareDirectories(site: site)
        try copyAssets(site: site)

        let generator = Generator(
            site: site,
            templatesUrl: templatesUrl,
            outputUrl: outputUrl
        )
        try generator.generate()
    }
}
