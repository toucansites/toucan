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
        try source.validateSlugs()

        // TODO: output url is completely wiped, check if it's safe to delete everything
        try resetOutputDirectory()

        /// not sure if we still need absolute url support...
        let themeUrl: URL
        if source.config.themes.folder.hasPrefix("/") {
            themeUrl = URL(fileURLWithPath: source.config.themes.folder)
                .appendingPathComponent(source.config.themes.use)
        }
        else {
            themeUrl =
                inputUrl
                .appendingPathComponent(source.config.themes.folder)
        }

        let currentThemeUrl =
            themeUrl
            .appendingPathComponent(source.config.themes.use)

        let themeAssetsUrl =
            currentThemeUrl
            .appendingPathComponent(source.config.themes.assets.folder)

        let themeTemplatesUrl =
            currentThemeUrl
            .appendingPathComponent(source.config.themes.templates.folder)

        let themeOverrideUrl =
            themeUrl
            .appendingPathComponent(source.config.themes.overrides.folder)

        let themeOverrideAssetsUrl =
            themeOverrideUrl
            .appendingPathComponent(source.config.themes.assets.folder)

        let themeOverrideTemplatesUrl =
            themeOverrideUrl
            .appendingPathComponent(source.config.themes.templates.folder)

        logger.trace(
            "Themes location url: `\(themeUrl.absoluteString)`"
        )
        logger.trace(
            "Current theme url: `\(currentThemeUrl.absoluteString)`"
        )
        logger.trace(
            "Current theme assets url: `\(themeAssetsUrl.absoluteString)`"
        )
        logger.trace(
            "Current theme templates url: `\(themeTemplatesUrl.absoluteString)`"
        )

        logger.trace(
            "Theme override url: `\(themeOverrideUrl.absoluteString)`"
        )
        logger.trace(
            "Theme override assets url: `\(themeOverrideAssetsUrl.absoluteString)`"
        )
        logger.trace(
            "Theme override templates url: `\(themeOverrideTemplatesUrl.absoluteString)`"
        )

        // theme assets
        try fileManager.copyRecursively(
            from: themeAssetsUrl,
            to: outputUrl
        )
        // theme override assets
        try fileManager.copyRecursively(
            from: themeOverrideAssetsUrl,
            to: outputUrl
        )

        // MARK: copy assets

        for pageBundle in source.pageBundles {
            let assetsUrl = pageBundle.url
                .appendingPathComponent(pageBundle.assets.path)

            guard
                fileManager.directoryExists(at: assetsUrl),
                !fileManager.listDirectory(at: assetsUrl).isEmpty
            else {
                continue
            }

            let outputUrl =
                outputUrl
                .appendingPathComponent(
                    pageBundle.context.slug.isEmpty ? "" : "assets"
                )
                .appendingPathComponent(pageBundle.context.slug)

            //            print("-------------")
            //            print(assetsUrl.path)
            //            print(outputUrl.path)
            try fileManager.copyRecursively(
                from: assetsUrl,
                to: outputUrl
            )
        }

        let renderer = try SiteRenderer(
            source: source,
            templatesUrl: themeTemplatesUrl,
            overridesUrl: themeOverrideTemplatesUrl,
            destinationUrl: outputUrl,
            logger: logger
        )

        try renderer.render()
    }
}
