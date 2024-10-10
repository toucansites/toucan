//
//  File.swift
//
//
//  Created by Tibor Bodecs on 27/06/2024.
//

import Foundation
import FileManagerKit
import Yams
import Logging

private extension Config {

    enum Keys {
        static let site = "site"
        static let themes = "themes"
        static let contents = "contents"
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
        static let assets = "assets"
        static let templates = "templates"
        static let types = "types"
        static let overrides = "overrides"
    }

    enum Defaults {
        static let use = "default"
        static let folder = "themes"
        static let assetsFolder = "assets"
        static let templatesFolder = "templates"
        static let typesFolder = "types"
        static let overridesFolder = "overrides"
    }
}

private extension Config.Contents {

    enum Keys {
        static let dateFormat = "dateFormat"
        static let assets = "assets"
    }

    enum Defaults {
        static let dateFormat = "yyyy-MM-dd HH:mm:ss"
        static let contentsFolder = "contents"
        static let assetsFolder = "assets"
    }
}

public struct ConfigLoader {

    /// An enumeration representing possible errors that can occur while loading the configuration.
    public enum Error: Swift.Error {
        case missing(URL)
        /// Indicates an error related to file operations.
        case file(Swift.Error)
        /// Indicates an error related to parsing YAML.
        case yaml(YamlError)
    }

    /// The URL of the source files.
    let sourceUrl: URL
    /// The file manager used for file operations.
    let fileManager: FileManager
    /// The base URL to use for the configuration.
    let baseUrl: String?
    /// The logger instance
    let logger: Logger

    /// Loads the configuration.
    ///
    /// - Returns: A `Config` object.
    /// - Throws: An error if the configuration fails to load.
    func load() throws -> Config {
        let configUrl = sourceUrl.appendingPathComponent("config")

        let yamlConfigUrls = [
            configUrl.appendingPathExtension("yaml"),
            configUrl.appendingPathExtension("yml"),
        ]
        for yamlConfigUrl in yamlConfigUrls {
            guard fileManager.fileExists(at: yamlConfigUrl) else {
                continue
            }
            do {
                logger.debug(
                    "Loading config file: `\(yamlConfigUrl.absoluteString)`."
                )
                let rawYaml = try String(
                    contentsOf: yamlConfigUrl,
                    encoding: .utf8
                )
                let dict = try Yams.load(yaml: rawYaml) as? [String: Any] ?? [:]
                let config = try dictToConfig(dict)
                return config
            }
            catch let error as YamlError {
                throw Error.yaml(error)
            }
            catch {
                throw Error.file(error)
            }
        }
        throw Error.missing(sourceUrl)
    }

    func dictToConfig(
        _ yaml: [String: Any]
    ) throws -> Config {
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

        let types = themes.dict(Config.Themes.Keys.types)
        let typesFolder =
            types.string(Config.Location.Keys.folder)
            ?? Config.Themes.Defaults.typesFolder

        // MARK: - content

        let contents = yaml.dict(Config.Keys.contents)
        let contentsFolder =
            contents.string(Config.Location.Keys.folder)
            ?? Config.Contents.Defaults.contentsFolder

        let contentsDateFormat =
            contents.string(Config.Contents.Keys.dateFormat)
            ?? Config.Contents.Defaults.dateFormat

        let contentsAssets = contents.dict(Config.Contents.Keys.assets)
        let contentsAssetsFolder =
            contentsAssets
            .string(Config.Location.Keys.folder)
            ?? Config.Contents.Defaults.assetsFolder

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
                assets: .init(folder: assetsFolder),
                templates: .init(folder: templatesFolder),
                types: .init(folder: typesFolder),
                overrides: .init(folder: overridesFolder)
            ),
            contents: .init(
                folder: contentsFolder,
                dateFormat: contentsDateFormat,
                assets: .init(folder: contentsAssetsFolder)
            )
        )
    }
}
