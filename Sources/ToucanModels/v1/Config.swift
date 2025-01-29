//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 01. 29..
//

public struct HTMLRendererConfig: Codable {

    enum CodingKeys: CodingKey {
        case themes
        case contents
        case transformers
    }

    public var contents: Contents
    public var themes: Themes
    public var transformers: Transformers

    public static var defaults: Self {
        .init(
            contents: .defaults,
            themes: .defaults,
            transformers: .defaults
        )
    }

    public init(
        contents: Contents,
        themes: Themes,
        transformers: Transformers
    ) {
        self.contents = contents
        self.themes = themes
        self.transformers = transformers
    }

    public init(from decoder: any Decoder) throws {
        let defaults = Self.defaults
        guard let container = try? decoder.container(keyedBy: CodingKeys.self)
        else {
            self = defaults
            return
        }
        self.contents =
            try container.decodeIfPresent(Contents.self, forKey: .contents)
            ?? defaults.contents
        self.themes =
            try container.decodeIfPresent(Themes.self, forKey: .themes)
            ?? defaults.themes
        self.transformers =
            try container.decodeIfPresent(
                Transformers.self,
                forKey: .transformers
            ) ?? defaults.transformers
    }
}

// MARK: -

extension HTMLRendererConfig {

    public struct Location: Codable {
        public var folder: String
    }
}

// MARK: -

extension HTMLRendererConfig {

    public struct Contents: Codable {

        enum CodingKeys: CodingKey {
            case folder
            case assets
            case dateFormats
            case home
            case notFound
        }

        public struct Page: Codable {
            public var id: String
            public var template: String
        }

        public struct DateFormats: Codable {

            enum CodingKeys: CodingKey {
                case timeZone
                case input
                case output
            }

            public var timeZone: String?
            public var input: String
            public var output: [String: String]

            public static var defaults: Self {
                .init(
                    timeZone: nil,
                    input: "yyyy-MM-dd HH:mm:ss",
                    output: [
                        "full": "yyyy-MM-dd HH:mm:ss"
                    ]
                )
            }

            public init(
                timeZone: String? = nil,
                input: String,
                output: [String: String]
            ) {
                self.timeZone = timeZone
                self.input = input
                self.output = output
            }

            public init(from decoder: any Decoder) throws {
                let defaults = Self.defaults
                guard
                    let container = try? decoder.container(
                        keyedBy: CodingKeys.self
                    )
                else {
                    self = defaults
                    return
                }
                self.timeZone =
                    try container.decodeIfPresent(
                        String.self,
                        forKey: .timeZone
                    ) ?? defaults.timeZone
                self.input =
                    try container.decodeIfPresent(String.self, forKey: .input)
                    ?? defaults.input
                self.output =
                    try container.decodeIfPresent(
                        [String: String].self,
                        forKey: .output
                    ) ?? defaults.output
            }
        }

        public var folder: String
        public var assets: Location
        public var dateFormats: DateFormats
        public var home: Page
        public var notFound: Page

        public init(
            folder: String,
            assets: Location,
            dateFormats: DateFormats,
            home: Page,
            notFound: Page
        ) {
            self.folder = folder
            self.assets = assets
            self.dateFormats = dateFormats
            self.home = home
            self.notFound = notFound
        }

        public static var defaults: Self {
            .init(
                folder: "contents",
                assets: .init(
                    folder: "assets"
                ),
                dateFormats: .defaults,
                home: .init(
                    id: "home",
                    template: "pages.home"
                ),
                notFound: .init(
                    id: "404",
                    template: "pages.404"
                )
            )
        }

        public init(from decoder: any Decoder) throws {
            let defaults = Self.defaults
            guard
                let container = try? decoder.container(keyedBy: CodingKeys.self)
            else {
                self = defaults
                return
            }
            self.folder =
                try container.decodeIfPresent(String.self, forKey: .folder)
                ?? defaults.folder
            self.assets =
                try container.decodeIfPresent(Location.self, forKey: .assets)
                ?? defaults.assets
            self.dateFormats =
                try container.decodeIfPresent(
                    DateFormats.self,
                    forKey: .dateFormats
                ) ?? defaults.dateFormats
            self.home =
                try container.decodeIfPresent(Page.self, forKey: .home)
                ?? defaults.home
            self.notFound =
                try container.decodeIfPresent(Page.self, forKey: .notFound)
                ?? defaults.notFound
        }
    }
}

// MARK: -

extension HTMLRendererConfig {

    public struct Themes: Codable {

        enum CodingKeys: CodingKey {
            case use
            case folder
            case assets
            case templates
            case types
            case overrides
        }

        public var use: String
        public var folder: String
        public var assets: Location
        public var templates: Location
        public var types: Location
        public var overrides: Location

        public static var defaults: Self {
            .init(
                use: "default",
                folder: "themes",
                assets: .init(
                    folder: "assets"
                ),
                templates: .init(
                    folder: "templates"
                ),
                types: .init(
                    folder: "types"
                ),
                overrides: .init(
                    folder: "overrides"
                )
            )
        }

        public init(
            use: String,
            folder: String,
            assets: HTMLRendererConfig.Location,
            templates: HTMLRendererConfig.Location,
            types: HTMLRendererConfig.Location,
            overrides: HTMLRendererConfig.Location
        ) {
            self.use = use
            self.folder = folder
            self.assets = assets
            self.templates = templates
            self.types = types
            self.overrides = overrides
        }

        public init(from decoder: any Decoder) throws {
            let defaults = Self.defaults
            guard
                let container = try? decoder.container(keyedBy: CodingKeys.self)
            else {
                self = defaults
                return
            }
            self.use =
                try container.decodeIfPresent(String.self, forKey: .use)
                ?? defaults.use
            self.folder =
                try container.decodeIfPresent(String.self, forKey: .folder)
                ?? defaults.folder
            self.assets =
                try container.decodeIfPresent(Location.self, forKey: .assets)
                ?? defaults.assets
            self.templates =
                try container.decodeIfPresent(Location.self, forKey: .templates)
                ?? defaults.templates
            self.types =
                try container.decodeIfPresent(Location.self, forKey: .types)
                ?? defaults.types
            self.overrides =
                try container.decodeIfPresent(Location.self, forKey: .overrides)
                ?? defaults.overrides
        }
    }
}

// MARK: -

extension HTMLRendererConfig {

    public struct Transformers: Codable {

        public struct Pipeline: Codable {

            public struct Run: Codable {
                public var name: String
            }

            enum CodingKeys: CodingKey {
                case run
                case isMarkdownResult
            }

            public var run: [Run]
            public var isMarkdownResult: Bool

            public static var defaults: Self {
                .init(
                    run: [],
                    isMarkdownResult: false
                )
            }

            public init(
                run: [Run],
                isMarkdownResult: Bool
            ) {
                self.run = run
                self.isMarkdownResult = isMarkdownResult
            }

            public init(from decoder: any Decoder) throws {
                let defaults = Self.defaults
                guard
                    let container = try? decoder.container(
                        keyedBy: CodingKeys.self
                    )
                else {
                    self = defaults
                    return
                }
                self.run =
                    try container.decodeIfPresent([Run].self, forKey: .run)
                    ?? defaults.run
                self.isMarkdownResult =
                    try container.decodeIfPresent(
                        Bool.self,
                        forKey: .isMarkdownResult
                    ) ?? defaults.isMarkdownResult
            }
        }

        enum CodingKeys: CodingKey {
            case folder
            case pipelines
        }

        public var folder: String
        public var pipelines: [String: Pipeline]

        public static var defaults: Self {
            .init(
                folder: "transformers",
                pipelines: [:]
            )
        }

        public init(
            folder: String,
            pipelines: [String: Pipeline]
        ) {
            self.folder = folder
            self.pipelines = pipelines
        }

        public init(from decoder: any Decoder) throws {
            let defaults = Self.defaults
            guard
                let container = try? decoder.container(keyedBy: CodingKeys.self)
            else {
                self = defaults
                return
            }
            self.folder =
                try container.decodeIfPresent(String.self, forKey: .folder)
                ?? defaults.folder
            self.pipelines =
                try container.decodeIfPresent(
                    [String: Pipeline].self,
                    forKey: .pipelines
                ) ?? defaults.pipelines
        }
    }

}
