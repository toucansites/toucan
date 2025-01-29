//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 01. 29..
//

struct HTMLRendererConfig {

    struct Location: Decodable {
        let folder: String
    }

    // MARK: -

    struct Themes: Decodable {

        enum CodingKeys: CodingKey {
            case use
            case folder
            case assets
            case templates
            case types
            case overrides
        }

        let use: String
        let folder: String
        let assets: Location
        let templates: Location
        let types: Location
        let overrides: Location
        
        public static var `defaults`: Themes {
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
        
        init(
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

        init(from decoder: any Decoder) throws {
            let defaults = Themes.defaults
            guard let container = try? decoder.container(keyedBy: CodingKeys.self) else {
                self = defaults
                return
            }
            self.use = try container.decodeIfPresent(String.self, forKey: .use) ?? defaults.use
            self.folder = try container.decodeIfPresent(String.self, forKey: .folder) ?? defaults.folder
            self.assets = try container.decodeIfPresent(Location.self, forKey: .assets) ?? defaults.assets
            self.templates = try container.decodeIfPresent(Location.self, forKey: .templates) ?? defaults.templates
            self.types = try container.decodeIfPresent(Location.self, forKey: .types) ?? defaults.types
            self.overrides = try container.decodeIfPresent(Location.self, forKey: .overrides) ?? defaults.overrides
        }
    }

    // MARK: -

    struct Contents {

        struct Page {
            let id: String
            let template: String
        }

        struct DateFormats {
            let timeZone: String
            let input: String
            let output: [String: String]
        }

        let folder: String
        let assets: Location
        let dateFormats: DateFormats
        let home: Page
        let notFound: Page
    }

    // MARK: -

    struct Transformers {

        struct Pipeline {

            struct Run {
                let name: String
            }

            let run: [Run]
            let isMarkdownResult: Bool
        }

        let folder: String
        let pipelines: [String: Pipeline]
    }

    // MARK: -
    
    let themes: Themes
    let contents: Contents
    let transformers: Transformers
}
