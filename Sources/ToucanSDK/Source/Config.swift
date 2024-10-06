//
//  File.swift
//
//
//  Created by Tibor Bodecs on 27/06/2024.
//

struct Config {

    struct Location {
        let folder: String
    }

    struct Site {

        struct Hreflang: Codable {
            let lang: String
            let url: String
        }

        let baseUrl: String
        let title: String
        let description: String
        let language: String?
        let dateFormat: String?
        let noindex: Bool?
        let hreflang: [Hreflang]?
        let userDefined: [String: Any]
    }

    struct Themes {
        let use: String
        let folder: String
        let templates: Location
        let assets: Location
        let overrides: Location
    }

    struct Content {
        let folder: String
        let dateFormat: String
        let assets: Location
    }

    struct Types {
        let folder: String
    }

    var site: Site
    let themes: Themes
    let types: Types
    let content: Content
}
