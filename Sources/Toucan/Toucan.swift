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
        static let config = "config.md"
    }

    public enum Directories {
        static let assets: String = "assets"
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
    func prepareDirectories() throws {
        let assetsDirUrl = outputUrl.appendingPathComponent(Directories.assets)
        try fileManager.createDirectory(at: assetsDirUrl)
    }

    /// copy one asset type using a directory a source identifier and a target slug
    private func copyAssets(
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
                .appendingPathComponent(slug)

            let dirEnum = fileManager.enumerator(atPath: assetInputUrl.path)
            while let file = dirEnum?.nextObject() as? String {
                let key = "./" + [directory, id, file].joined(separator: "/")
                let value =
                    "/"
                    + [Directories.assets, slug, file]
                    .joined(separator: "/")
                res[key] = value
            }
            
            try fileManager.createParentFolderIfNeeded(for: assetOutputUrl)
            
            try fileManager.copy(
                from: assetInputUrl,
                to: assetOutputUrl
            )
        }
        return res
    }

    /// copy all the assets for the site
    func copyContentAssets(
        content: Content
    ) throws -> [String: String] {

        var assets: [String: String] = [:]

        for content in content.siteContents {
            let res = try copyAssets(
                directory: type(of: content).folder,
                id: content.id,
                slug: content.slug
            )
            assets = assets + res
        }

        return assets
    }

    /// builds the static site
    func build() throws {
        let contentLoader = ContentLoader(
            contentsUrl: contentsUrl,
            fileManager: .default,
            frontMatterParser: .init()
        )
        let content = try contentLoader.load()
        
        try resetOutputDirectory()
        try copyPublicFiles()
        try prepareDirectories()
        let assets = try copyContentAssets(content: content)
        
        let site = Site(
            content: content,
            assets: assets
        )

//        for (k, v) in assets {
//            print(k)
//            print(v)
//            print("-------------------------------")
//        }

        let generator = SiteGenerator(
            site: site,
            templatesUrl: templatesUrl,
            outputUrl: outputUrl
        )

        try generator.generate()
    }
}

