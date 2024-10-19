//
//  File.swift
//
//
//  Created by Tibor Bodecs on 03/05/2024.
//

import Foundation
import FileManagerKit
import Logging

/// A static site generator.
public struct Toucan {

    // MARK: -

    let inputUrl: URL
    let outputUrl: URL
    let baseUrl: String?
    let logger: Logger

    /// Initialize a new instance.
    /// - Parameters:
    ///   - input: The input url as a path string.
    ///   - output: The output url as a path string.
    ///   - baseUrl: An optional baseUrl to override the config value.
    public init(
        input: String,
        output: String,
        baseUrl: String?,
        logger: Logger = .init(label: "toucan")
    ) {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        func getSafeUrl(_ path: String, home: String) -> URL {
            .init(
                fileURLWithPath: path.replacingOccurrences(["~": home])
            )
            .standardized
        }
        self.inputUrl = getSafeUrl(input, home: home)
        self.outputUrl = getSafeUrl(output, home: home)
        self.baseUrl = baseUrl
        self.logger = logger
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

    /// generates the static site
    public func generate() throws {
        let loader = SourceLoader(
            baseUrl: baseUrl,
            sourceUrl: inputUrl,
            yamlFileLoader: .yaml,
            fileManager: fileManager,
            frontMatterParser: .init(),
            logger: logger
        )
        let source = try loader.load()
        source.validate()

        // TODO: output url is completely wiped, check if it's safe to delete everything
        try resetOutputDirectory()

        // theme assets
        try fileManager.copyRecursively(
            from: source.sourceConfig.currentThemeAssetsUrl,
            to: outputUrl
        )
        // theme override assets
        try fileManager.copyRecursively(
            from: source.sourceConfig.currentThemeOverrideAssetsUrl,
            to: outputUrl
        )
        // copy global site assets
        try fileManager.copyRecursively(
            from: source.sourceConfig.assetsUrl,
            to: outputUrl
        )

        // MARK: copy assets

        for pageBundle in source.pageBundles {
            let assetsUrl = pageBundle.url
                .appendingPathComponent(pageBundle.config.assets.folder)

            guard
                fileManager.directoryExists(at: assetsUrl),
                !fileManager.listDirectory(at: assetsUrl).isEmpty
            else {
                continue
            }

            let outputUrl =
                outputUrl
                .appendingPathComponent(pageBundle.config.assets.folder)
                .appendingPathComponent(pageBundle.assetsLocation)

            try fileManager.copyRecursively(
                from: assetsUrl,
                to: outputUrl
            )
        }

        let templateRenderer = try MustacheToHTMLRenderer(
            templatesUrl: source.sourceConfig.currentThemeTemplatesUrl,
            overridesUrl: source.sourceConfig.currentThemeOverrideTemplatesUrl,
            logger: logger
        )

        let redirectRenderer = RedirectRenderer(
            destinationUrl: outputUrl,
            fileManager: .default,
            templateRenderer: templateRenderer,
            pageBundles: source.pageBundles
        )
        try redirectRenderer.render()

        let sitemapRenderer = SitemapRenderer(
            destinationUrl: outputUrl,
            fileManager: .default,
            templateRenderer: templateRenderer,
            pageBundles: source.sitemapPageBundles()
        )
        try sitemapRenderer.render()

        let rssRenderer = RSSRenderer(
            site: source.sourceConfig.site,
            destinationUrl: outputUrl,
            fileManager: .default,
            templateRenderer: templateRenderer,
            pageBundles: source.rssPageBundles()
        )
        try rssRenderer.render()

        let htmlRenderer = try HTMLRenderer(
            source: source,
            destinationUrl: outputUrl,
            templateRenderer: templateRenderer,
            logger: logger
        )

        try htmlRenderer.render()
        
        let apiRenderer = try APIRenderer(
            source: source,
            destinationUrl: outputUrl,
            logger: logger
        )
        try apiRenderer.render()
    }
}
