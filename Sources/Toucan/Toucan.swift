//
//  File.swift
//
//
//  Created by Tibor Bodecs on 03/05/2024.
//



import Foundation
import FileManagerKit

extension FileManager {

    func copyRecursively(
        from inputURL: URL,
        to outputURL: URL
    ) throws {
        guard directoryExists(at: inputURL) else {
            return
        }
        if !directoryExists(at: outputURL) {
            try createDirectory(at: outputURL)
        }
        
        for item in listDirectory(at: inputURL) {
            let itemSourceUrl = inputURL.appendingPathComponent(item)
            let itemDestinationUrl = outputURL.appendingPathComponent(item)
            if fileExists(at: itemSourceUrl) {
                if fileExists(at: itemDestinationUrl) {
                    try delete(at: itemDestinationUrl)
                }
                try copy(from: itemSourceUrl, to: itemDestinationUrl)
            }
            else {
                try copyRecursively(from: itemSourceUrl, to: itemDestinationUrl)
            }
        }
    }
}

/// A static site generator.
public struct Toucan {

    public enum Files {
        static let index = "index.html"
        static let notFound = "404.html"
        static let rss = "rss.xml"
        static let sitemap = "sitemap.xml"

        static let config = "config.yaml"
    }

    public enum Directories {
        static let assets: String = "assets"
        static let contents: String = "contents"
        static let themes: String = "themes"
        static let templates: String = "templates"
    }
    
    // MARK: -

    let inputUrl: URL
    let outputUrl: URL

    /// Initialize a new instance.
    /// - Parameters:
    ///   - inputUrl: The input URL
    ///   - outputUrl: The output URL
    public init(
        inputUrl: URL,
        outputUrl: URL
    ) {
        self.inputUrl = inputUrl
        self.outputUrl = outputUrl
    }

    // MARK: - urls
    
    var configFileUrl: URL { inputUrl.appendingPathComponent(Files.config) }

    var assetsUrl: URL { inputUrl.appendingPathComponent(Directories.assets) }
    var contentsUrl: URL { inputUrl.appendingPathComponent(Directories.contents) }
    
    // TODO: fix this
    var themeUrl: URL {
        inputUrl
            .appendingPathComponent(Directories.themes)
            .appendingPathComponent("toucan")
            
    }
    
    var themeAssetsUrl: URL { themeUrl.appendingPathComponent(Directories.assets) }
    var templatesUrl: URL { themeUrl.appendingPathComponent(Directories.templates) }
    
    // TODO: fix this
    var templateOverridesUrl: URL {
        inputUrl
            .appendingPathComponent("theme_overrides")
            .appendingPathComponent("toucan")
            .appendingPathComponent(Directories.templates)
    }
    
    // TODO: fix this
    var templateOverridesAssetsUrl: URL {
        inputUrl
            .appendingPathComponent("theme_overrides")
            .appendingPathComponent("toucan")
            .appendingPathComponent(Directories.assets)
    }
    
    
    // MARK: - file management

    let fileManager = FileManager.default

    // MARK: - directory management
    
    func resetOutputDirectory() throws {
        if fileManager.exists(at: outputUrl) {
            try fileManager.delete(at: outputUrl)
        }
        try fileManager.createDirectory(at: outputUrl)
    }

    func copyAssets() throws {
        // theme assets
        try fileManager.copyRecursively(
            from: themeAssetsUrl,
            to: outputUrl
        )
        // theme override assets
        try fileManager.copyRecursively(
            from: templateOverridesAssetsUrl,
            to: outputUrl
        )
        // content assets
        try fileManager.copyRecursively(
            from: assetsUrl,
            to: outputUrl
        )
    }
    
    

    /// copy one asset type using a directory a source identifier and a target slug
//    private func copyAssets(
//        directory: String,
//        id: String,
//        slug: String
//    ) throws -> [String: String] {
//        var res: [String: String] = [:]
//        let assetInputUrl =
//            contentsUrl
//            .appendingPathComponent(directory)
//            .appendingPathComponent(id)
//
//        print("---------------------")
//        print(assetInputUrl.path)
//
//        if fileManager.directoryExists(at: assetInputUrl) {
//            let assetOutputUrl =
//                outputUrl
//                .appendingPathComponent(Directories.assets)
//                .appendingPathComponent(slug)
//
//            let dirEnum = fileManager.enumerator(atPath: assetInputUrl.path)
//            while let file = dirEnum?.nextObject() as? String {
//                let key = "./" + [directory, id, file].joined(separator: "/")
//                let value =
//                    "/"
//                    + [Directories.assets, slug, file]
//                    .joined(separator: "/")
//                res[key] = value
//            }
//
//            try fileManager.createParentFolderIfNeeded(for: assetOutputUrl)
//
//            try fileManager.copy(
//                from: assetInputUrl,
//                to: assetOutputUrl
//            )
//        }
//        return res
//    }

    /// copy all the assets for the site
//    func copyContentAssets(
//        content: Content
//    ) throws -> [String: String] {
//
//        var assets: [String: String] = [:]
//
//        for content in content.siteContents {
//            if content.slug.isEmpty {
//                continue
//            }
//            let res = try copyAssets(
//                directory: type(of: content).folder,
//                id: content.slug, // TODO: fix this
//                slug: content.slug
//            )
//            assets = assets + res
//        }
//
//        return assets
//    }

    /// builds the static site
    public func run() async throws {
        
        try resetOutputDirectory()
        try copyAssets()

        
        let configLoader = Source.ConfigLoader(
            configFileUrl: configFileUrl,
            fileManager: .default,
            frontMatterParser: .init()
        )
        let config = try configLoader.load()

        let contentsLoader = Source.ContentsLoader(
            contentsUrl: contentsUrl,
            config: config,
            fileManager: .default,
            frontMatterParser: .init()
        )

        let contents = try contentsLoader.load()
        try contents.validateSlugs()

        // TODO: use content assets
        let site = Site(
            source: .init(
                config: config,
                contents: contents,
                assets: .init(
                    storage: [:]
                )
            ),
            destinationUrl: outputUrl
        )

        let renderer = SiteRenderer(
            site: site,
            templatesUrl: templatesUrl,
            overridesUrl: templateOverridesUrl
        )

        try renderer.render()
    }
}
