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

        struct Page {
            enum Keys {
                static let id = "id"
                static let template = "template"
            }

            let id: String
            let template: String
        }

        enum Keys {
            static let dateFormat = "dateFormat"
            static let assets = "assets"
            static let home = "home"
            static let notFound = "notFound"
        }

        let folder: String
        let dateFormat: String
        let assets: Location
        let home: Page
        let notFound: Page

        init(
            folder: String,
            dateFormat: String,
            assets: Config.Location,
            home: Page,
            notFound: Page
        ) {
            self.folder = folder
            self.dateFormat = dateFormat
            self.assets = assets
            self.home = home
            self.notFound = notFound
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

            let home = dict.dict(Keys.home)
            self.home = .init(
                id: home.string(Page.Keys.id)
                    ?? Config.defaults.contents.home.id,
                template: home.string(Page.Keys.template)
                    ?? Config.defaults.contents.home.template
            )

            let notFound = dict.dict(Keys.notFound)
            self.notFound = .init(
                id: notFound.string(Page.Keys.id)
                    ?? Config.defaults.contents.notFound.id,
                template: notFound.string(Page.Keys.template)
                    ?? Config.defaults.contents.notFound.template
            )
        }
    }

    // MARK: -

    struct Transformers {

        enum Keys {
            static let pipelines = "pipelines"
        }

        struct Pipeline {
            
            enum Keys {
                static let run = "run"
                static let render = "render"
            }
            
            struct Run {
                
                enum Keys {
                    static let name = "name"
                }
                
                let name: String
                
                init?(_ dict: [String: Any]) {
                    guard let name = dict.string(Keys.name) else {
                        return nil
                    }
                    self.name = name
                }
            }
            
            let run: [Run]
            let render: Bool

            init(_ dict: [String: Any]) {
                self.run = dict
                    .array(Keys.run, as: [String: Any].self)
                    .map { Run($0)! }
                self.render = dict.bool(Keys.render) ?? true
            }
        }

        let folder: String
        let pipelines: [String: Pipeline]

        init(
            folder: String,
            pipelines: [String: Pipeline]
        ) {
            self.folder = folder
            self.pipelines = pipelines
        }

        init(_ dict: [String: Any]) {
            self.folder =
                dict.string(Location.Keys.folder)
                ?? Config.defaults.transformers.folder
            self.pipelines = dict
                .dict(Keys.pipelines)
                .compactMapValues { (item: Any) -> Pipeline? in
                    guard let dict = item as? [String: Any] else {
                        return nil
                    }
                    return Pipeline(dict)
                }
        }
    }

    // MARK: -

    enum Keys {
        static let site = "site"
        static let themes = "themes"
        static let contents = "contents"
        static let transformers = "transformers"
    }

    let themes: Themes
    let contents: Contents
    let transformers: Transformers

    init(
        themes: Themes,
        contents: Contents,
        transformers: Transformers
    ) {
        self.themes = themes
        self.contents = contents
        self.transformers = transformers
    }

    init(_ dict: [String: Any]) {
        self.themes = .init(dict.dict(Keys.themes))
        self.contents = .init(dict.dict(Keys.contents))
        self.transformers = .init(dict.dict(Keys.transformers))
    }
}

extension Config {

    static let `defaults` = Config(
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
            assets: .init(folder: "assets"),
            home: .init(
                id: "home",
                template: "pages.home"
            ),
            notFound: .init(
                id: "404",
                template: "pages.404"
            )
        ),
        transformers: .init(
            folder: "transformers",
            pipelines: [:]
        )
    )
}
