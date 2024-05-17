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
    ) throws -> [String: String] {
        var res: [String: String] = [:]
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

            let dirEnum = fileManager.enumerator(atPath: assetInputUrl.path)
            while let file = dirEnum?.nextObject() as? String {
                let key = "./" + [directory, id, file].joined(separator: "/")
                let value = "/" + [Directories.assets, directory, slug, file].joined(separator: "/")
                res[key] = value
            }

            try fileManager.copy(
                from: assetInputUrl,
                to: assetOutputUrl
            )
        }
        return res
    }

    private func getAssetIdentifiers(
        at url: URL
    ) -> [String] {
        var toProcess: [String] = []
        let dirEnum = fileManager.enumerator(atPath: url.path)
        while let file = dirEnum?.nextObject() as? String {
            toProcess.append(file)
        }
        return toProcess
    }
    
    /// copy all the assets for the site
    func copyAssets(site: Site) throws -> [String: String] {

        var assets: [String: String] = [:]
        for author in site.authors {
            let res = try copyAsset(
                directory: Directories.authors,
                id: author.id,
                slug: author.slug
            )
            assets = assets + res
        }

        for page in site.pages {
            let res = try copyAsset(
                directory: Directories.pages,
                id: page.id,
                slug: page.slug
            )
            assets = assets + res
        }

        for post in site.posts {
            let res = try copyAsset(
                directory: Directories.posts,
                id: post.id,
                slug: post.slug
            )
            assets = assets + res
        }

        for tag in site.tags {
            let res = try copyAsset(
                directory: Directories.tags,
                id: tag.id,
                slug: tag.slug
            )
            assets = assets + res
        }
        
        return assets
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
        let assets = try copyAssets(site: site)
        
        let generator = Generator(
            site: site,
            assets: .init(site, assets),
            templatesUrl: templatesUrl,
            outputUrl: outputUrl
        )
        try generator.generate()
    }
}


struct Assets {
    
    enum Variant {
        case light
        case dark
    }

    private let site: Site
    private let assets: [String: String]
        
    init(
        _ site: Site,
        _ assets: [String: String]
    ) {
        self.site = site
        self.assets = assets
    }

    func exists(_ id: String) -> Bool {
        assets[id] != nil
    }
    
    func url(
        _ id: String?,
        for type: ContentType,
        variant: Variant = .light
    ) -> String? {
        guard let id, !id.isEmpty else {
            return nil
        }
        if id.hasPrefix("./") {
            // TODO: handle this better...
            var key: String
            switch variant {
            case .light:
                key = id
            case .dark:
                var items = id.split(separator: ".")
                items.insert("~dark", at: items.count - 1)
                key = items
                    .joined(separator: ".")
                    .replacingOccurrences(
                            of: ".~dark",
                            with: "~dark"
                        )
            }
            
            key = key.replacingOccurrences(
                    of: "./",
                    with: "./\(type.rawValue)s/"
                )

            if let slug = assets[key] {
                return site.permalink(slug)
            }
            return nil
        }
        return id
    }
    
//    let imageModifier = Modifier(target: .images) { html, markdown in
    //            let input = String(markdown)
    //            guard
    //                let alt = input.slice(from: "![", to: "]"),
    //                let file = input.slice(from: "](", to: ")"),
    //                let name = file.split(separator: ".").first,
    //                let ext = file.split(separator: ".").last,
    //                assets.contains(file)
    //            else {
    //                print("[WARNING] Image link issues `\(input)` in `\(slug)`.")
    //                return html
    //            }
    //
    //            let darkFile = String(name) + "~dark." + String(ext)
    //            let src = baseUrl + "images/assets/" + slug + "/images/" + file
    //            let darkSrc =
    //                baseUrl + "images/assets/" + slug + "/images/" + darkFile
    //
    //            var dark = ""
    //            if assets.contains(darkFile) {
    //                dark =
    //                    #"<source srcset="\#(darkSrc)" media="(prefers-color-scheme: dark)">\#n\#t\#t"#
    //            }
    //            return #"""
    //                </section><section class="wrapper">
    //                <figure>
    //                    <picture>
    //                        \#(dark)<img class="post-image" src="\#(src)" alt="\#(alt)">
    //                    </picture>
    //                </figure>
    //                </section><section class="content-wrapper">
    //                """#
    //        }
}
