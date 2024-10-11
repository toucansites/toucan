//
//  File.swift
//
//
//  Created by Tibor Bodecs on 27/06/2024.
//

import Foundation
import FileManagerKit
import Logging

private extension Config {

    enum Keys {
        static let site = "site"
        static let themes = "themes"
        static let content = "content"
        static let types = "types"
    }

}

private extension Config.Location {

    enum Keys {
        static let folder = "folder"
    }
}

private extension Config.Site {

    enum Keys: String, CaseIterable {
        case baseUrl
        case title
        case description
        case language
        case dateFormat
        case noindex
        case hreflang
    }

    enum Defaults {
        static let baseUrl = "http://localhost:3000/"
        static let title = ""
        static let description = ""
        static let dateFormat = "MMMM dd, yyyy"
        static let noindex = false
    }
}

private extension Config.Themes {

    enum Keys {
        static let use = "use"
        static let templates = "templates"
        static let assets = "assets"
        static let overrides = "overrides"
    }

    enum Defaults {
        static let use = "default"
        static let folder = "themes"
        static let templatesFolder = "templates"
        static let assetsFolder = "assets"
        static let overridesFolder = "template_overrides"
    }
}

private extension Config.Types {

    enum Defaults {
        static let typesFolder = "types"
    }
}

private extension Config.Content {

    enum Keys {
        static let dateFormat = "dateFormat"
        static let assets = "assets"
    }

    enum Defaults {
        static let dateFormat = "yyyy-MM-dd HH:mm:ss"
        static let contentFolder = "content"
        static let assetsFolder = "assets"
    }
}

public struct ConfigLoader {

    /// An enumeration representing possible errors that can occur while loading the configuration.
    public enum Error: Swift.Error {
        /// Indicates that a required configuration file is missing at the specified URL.
        case missing(URL)
    }

    /// The URL of the source files.
    let sourceUrl: URL
    /// A file loader used for loading files.
    let fileLoader: FileLoader
    /// The base URL to use for the configuration.
    let baseUrl: String?
    /// The logger instance
    let logger: Logger

    /// Loads the configuration.
    ///
    /// This function attempts to load a configuration file from a specified URL, parses the file contents,
    /// and returns a `Config` object based on the file's data. If the file is missing or cannot be parsed,
    /// an appropriate error is thrown.
    ///
    /// - Returns: A `Config` object representing the loaded configuration.
    /// - Throws: An error if the configuration file is missing or if its contents cannot be decoded.
    func load() throws -> Config {
        let configUrl = sourceUrl.appendingPathComponent("config")

        logger.debug("Loading config file: `\(configUrl.absoluteString)`.")

        do {
            let contents = try FileLoader.yaml.loadContents(at: configUrl)
            let yaml = try contents.decodeYaml()
            return dictToConfig(yaml)
        }
        catch FileLoader.Error.missing(let url) {
            throw Error.missing(url)
        }
    }

    func dictToConfig(
        _ yaml: [String: Any]
    ) -> Config {
        // MARK: - site
        let site = yaml.dict(Config.Keys.site)

        /// set base url to default value
        var baseUrl = Config.Site.Defaults.baseUrl.ensureTrailingSlash()
        /// load base url from YAML
        if let value = site.string(Config.Site.Keys.baseUrl.rawValue) {
            baseUrl = value.ensureTrailingSlash()
        }
        /// override base url with input
        if let value = self.baseUrl {
            baseUrl = value.ensureTrailingSlash()
        }

        let title =
            site.string(Config.Site.Keys.title.rawValue)
            ?? Config.Site.Defaults.title

        let description =
            site.string(Config.Site.Keys.description.rawValue)
            ?? Config.Site.Defaults.description

        let language = site.string(Config.Site.Keys.language.rawValue)

        let dateFormat =
            site.string(Config.Site.Keys.dateFormat.rawValue)
            ?? Config.Site.Defaults.dateFormat

        let noindex =
            site.bool(Config.Site.Keys.noindex.rawValue)
            ?? Config.Site.Defaults.noindex

        let hreflang = site.array(
            Config.Site.Keys.hreflang.rawValue,
            as: Config.Site.Hreflang.self
        )

        let userDefined = site.filter {
            !Config.Site.Keys.allCases.map(\.rawValue).contains($0.key)
        }

        // MARK: - themes

        let themes = yaml.dict(Config.Keys.themes)

        let use =
            themes.string(Config.Themes.Keys.use) ?? Config.Themes.Defaults.use

        let folder =
            themes.string(Config.Location.Keys.folder)
            ?? Config.Themes.Defaults.folder

        let templates = themes.dict(Config.Themes.Keys.templates)
        let templatesFolder =
            templates.string(Config.Location.Keys.folder)
            ?? Config.Themes.Defaults.templatesFolder

        let assets = themes.dict(Config.Themes.Keys.assets)
        let assetsFolder =
            assets.string(Config.Location.Keys.folder)
            ?? Config.Themes.Defaults.assetsFolder

        let overrides = themes.dict(Config.Themes.Keys.overrides)
        let overridesFolder =
            overrides.string(Config.Location.Keys.folder)
            ?? Config.Themes.Defaults.overridesFolder

        // MARK: - types

        let types = yaml.dict(Config.Keys.types)
        let typesFolder =
            types.string(Config.Location.Keys.folder)
            ?? Config.Types.Defaults.typesFolder

        // MARK: - content

        let content = yaml.dict(Config.Keys.content)
        let contentFolder =
            content.string(Config.Location.Keys.folder)
            ?? Config.Content.Defaults.contentFolder

        let contentDateFormat =
            content.string(Config.Content.Keys.dateFormat)
            ?? Config.Content.Defaults.dateFormat

        let contentAssets = content.dict(Config.Content.Keys.assets)
        let contentAssetsFolder =
            contentAssets
            .string(Config.Location.Keys.folder)
            ?? Config.Content.Defaults.assetsFolder

        // MARK: - config

        return .init(
            site: .init(
                baseUrl: baseUrl,
                title: title,
                description: description,
                language: language,
                dateFormat: dateFormat,
                noindex: noindex,
                hreflang: hreflang,
                userDefined: userDefined
            ),
            themes: .init(
                use: use,
                folder: folder,
                templates: .init(folder: templatesFolder),
                assets: .init(folder: assetsFolder),
                overrides: .init(folder: overridesFolder)
            ),
            types: .init(folder: typesFolder),
            content: .init(
                folder: contentFolder,
                dateFormat: contentDateFormat,
                assets: .init(folder: contentAssetsFolder)
            )
        )
    }
}
