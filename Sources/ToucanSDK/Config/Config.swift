//
//  File.swift
//
//
//  Created by Tibor Bodecs on 27/06/2024.
//

struct Config {

    struct Location {

        enum Keys {
            static let folder = "folder"
        }

        let folder: String

        init(folder: String) {
            self.folder = folder
        }

        init?(_ dict: [String: Any]) {
            guard let folder = dict.string(Keys.folder) else {
                return nil
            }
            self.folder = folder
        }
    }

    // MARK: -

    struct Site {

        enum Keys {
            static let baseUrl = "baseUrl"
            static let title = "title"
            static let description = "description"
            static let language = "language"
            static let dateFormat = "dateFormat"
            static let noindex = "noindex"
            static let hreflang = "hreflang"

            static let allKeys: [String] = [
                Keys.baseUrl,
                Keys.title,
                Keys.description,
                Keys.language,
                Keys.dateFormat,
                Keys.noindex,
                Keys.hreflang,
            ]
        }

        struct Hreflang: Codable {
            let lang: String
            let url: String
        }

        let baseUrl: String
        let title: String
        let description: String
        let language: String?
        let dateFormat: String
        let noindex: Bool
        let hreflang: [Hreflang]
        let userDefined: [String: Any]

        init(
            baseUrl: String,
            title: String,
            description: String,
            language: String?,
            dateFormat: String,
            noindex: Bool,
            hreflang: [Hreflang],
            userDefined: [String: Any]
        ) {
            self.baseUrl = baseUrl
            self.title = title
            self.description = description
            self.language = language
            self.dateFormat = dateFormat
            self.noindex = noindex
            self.hreflang = hreflang
            self.userDefined = userDefined
        }

        init(_ dict: [String: Any]) {
            self.baseUrl =
                dict.string(Keys.baseUrl)
                ?? Config.defaults.site.baseUrl

            self.title =
                dict.string(Keys.title)
                ?? Config.defaults.site.title

            self.description =
                dict.string(Keys.description)
                ?? Config.defaults.site.description

            self.language = dict.string(Keys.language)

            self.dateFormat =
                dict.string(Keys.dateFormat)
                ?? Config.defaults.site.dateFormat

            self.noindex =
                dict.bool(Keys.noindex)
                ?? Config.defaults.site.noindex

            self.hreflang = dict.array(Keys.hreflang, as: Hreflang.self)
            self.userDefined = dict.filter { !Keys.allKeys.contains($0.key) }
        }
    }

    // MARK: -

    struct Themes {

        enum Keys {
            static let use = "use"
            static let assets = "assets"
            static let templates = "templates"
            static let types = "types"
            static let overrides = "overrides"
        }

        let use: String
        let folder: String
        let assets: Location
        let templates: Location
        let types: Location
        let overrides: Location

        init(
            use: String,
            folder: String,
            assets: Config.Location,
            templates: Config.Location,
            types: Config.Location,
            overrides: Config.Location
        ) {
            self.use = use
            self.folder = folder
            self.assets = assets
            self.templates = templates
            self.types = types
            self.overrides = overrides
        }

        init(_ dict: [String: Any]) {
            self.use =
                dict.string(Keys.use)
                ?? Config.defaults.themes.use

            self.folder =
                dict.string(Location.Keys.folder)
                ?? Config.defaults.themes.folder

            let assets = dict.dict(Keys.assets)
            self.assets =
                Location(assets)
                ?? Config.defaults.themes.assets

            let templates = dict.dict(Keys.templates)
            self.templates =
                Location(templates)
                ?? Config.defaults.themes.templates

            let overrides = dict.dict(Keys.overrides)
            self.overrides =
                Location(overrides)
                ?? Config.defaults.themes.overrides

            let types = dict.dict(Keys.types)
            self.types =
                Location(types)
                ?? Config.defaults.themes.types
        }
    }

    // MARK: -

    struct Contents {

        enum Keys {
            static let dateFormat = "dateFormat"
            static let assets = "assets"
        }

        let folder: String
        let dateFormat: String
        let assets: Location

        init(
            folder: String,
            dateFormat: String,
            assets: Config.Location
        ) {
            self.folder = folder
            self.dateFormat = dateFormat
            self.assets = assets
        }

        init(_ dict: [String: Any]) {
            self.folder =
                dict.string(Location.Keys.folder)
                ?? Config.defaults.contents.folder

            self.dateFormat =
                dict.string(Keys.dateFormat)
                ?? Config.defaults.contents.dateFormat

            let assets = dict.dict(Keys.assets)
            self.assets =
                Location(assets)
                ?? Config.defaults.themes.assets
        }
    }

    // MARK: -

    struct Transformers {

        enum Keys {
            static let pipelines = "pipelines"
        }

        struct Pipeline {
            let types: [String]
            let run: [String]
            let render: Bool

            init(_ dict: [String: Any]) {
                self.types = dict.array("types", as: String.self)
                self.run = dict.array("run", as: String.self)
                self.render = dict.bool("render") ?? false
            }
        }

        let folder: String
        let pipelines: [Pipeline]

        init(
            folder: String,
            pipelines: [Pipeline]
        ) {
            self.folder = folder
            self.pipelines = pipelines
        }

        init(_ dict: [String: Any]) {
            self.folder =
                dict.string(Location.Keys.folder)
                ?? Config.defaults.transformers.folder

            self.pipelines = dict.array(Keys.pipelines, as: [String: Any].self)
                .map { .init($0) }
        }
    }

    // MARK: -

    enum Keys {
        static let site = "site"
        static let themes = "themes"
        static let contents = "contents"
        static let transformers = "transformers"
    }

    let site: Site
    let themes: Themes
    let contents: Contents
    let transformers: Transformers

    init(
        site: Site,
        themes: Themes,
        contents: Contents,
        transformers: Transformers
    ) {
        self.site = site
        self.themes = themes
        self.contents = contents
        self.transformers = transformers
    }

    init(_ dict: [String: Any]) {
        self.site = .init(dict.dict(Keys.site))
        self.themes = .init(dict.dict(Keys.themes))
        self.contents = .init(dict.dict(Keys.contents))
        self.transformers = .init(dict.dict(Keys.transformers))
    }
}

extension Config {

    static let `defaults` = Config(
        site: .init(
            baseUrl: "http://localhost:3000/",
            title: "",
            description: "",
            language: nil,
            dateFormat: "MMMM dd, yyyy",
            noindex: false,
            hreflang: [],
            userDefined: [:]
        ),
        themes: .init(
            use: "default",
            folder: "themes",
            assets: .init(folder: "assets"),
            templates: .init(folder: "templates"),
            types: .init(folder: "types"),
            overrides: .init(folder: "overrides")
        ),
        contents: .init(
            folder: "contents",
            dateFormat: "yyyy-MM-dd HH:mm:ss",
            assets: .init(folder: "assets")
        ),
        transformers: .init(
            folder: "transformers",
            pipelines: []
        )
    )
}
