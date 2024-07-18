//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 27/06/2024.
//

import Foundation

struct Config: Codable {
    
    struct Location: Codable {
        let folder: String
    }

    struct Site: Codable {

        struct Hreflang: Codable {
            let lang: String
            let url: String
        }

        let baseUrl: String
        let title: String
        let description: String
        let language: String?
        let dateFormat: String?
        let noindex: Bool
        let hreflang: [Hreflang]?
        
    }

    struct Themes: Codable {
        let use: String
        let folder: String
        let templates: Location
        let assets: Location
        let overrides: Location
    }

    struct Content: Codable {
        let folder: String
        let assets: Location
    }

    let site: Site
    let themes: Themes
    let types: Location
    let content: Content
}


