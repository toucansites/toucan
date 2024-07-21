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

    // MARK: -

    let inputUrl: URL
    let outputUrl: URL
    let baseUrl: String?

    /// Initialize a new instance.
    /// - Parameters:
    ///   - input: The input url as a path string.
    ///   - output: The output url as a path string.
    public init(
        input: String,
        output: String,
        baseUrl: String?
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
            sourceUrl: inputUrl,
            fileManager: fileManager,
            frontMatterParser: .init()
        )
        let source = try loader.load()

        // TODO: output url is completely wiped, check if it's safe to delete everything
        try resetOutputDirectory()

        let themeUrl =
            inputUrl
            .appendingPathComponent(source.config.themes.folder)
            .appendingPathComponent(source.config.themes.use)

        let themeAssetsUrl =
            themeUrl
            .appendingPathComponent(source.config.themes.assets.folder)

        let themeTemplatesUrl =
            themeUrl
            .appendingPathComponent(source.config.themes.templates.folder)

        let themeOverrideUrl =
            inputUrl
            .appendingPathComponent(source.config.themes.overrides.folder)
            .appendingPathComponent(source.config.themes.use)

        let themeOverrideAssetsUrl =
            themeOverrideUrl
            .appendingPathComponent(source.config.themes.assets.folder)

        let themeOverrideTemplatesUrl =
            themeOverrideUrl
            .appendingPathComponent(source.config.themes.templates.folder)

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
                .appendingPathComponent(pageBundle.assetsPath)

            guard
                fileManager.directoryExists(at: assetsUrl),
                !fileManager.listDirectory(at: assetsUrl).isEmpty
            else {
                continue
            }

            let outputUrl =
                outputUrl
                .appendingPathComponent(pageBundle.slug.isEmpty ? "" : "assets")
                .appendingPathComponent(pageBundle.slug)

            //            print("-------------")
            //            print(assetsUrl.path)
            //            print(outputUrl.path)
            try fileManager.copyRecursively(
                from: assetsUrl,
                to: outputUrl
            )
        }

        let renderer = SiteRenderer(
            source: source,
            templatesUrl: themeTemplatesUrl,
            overridesUrl: themeOverrideTemplatesUrl,
            destinationUrl: outputUrl
        )

        try renderer.render()
    }
}
