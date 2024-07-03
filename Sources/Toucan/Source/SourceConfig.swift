//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 27/06/2024.
//

import Foundation

struct SourceConfig {

    struct Content {
        let folder: String
        let slugPrefix: String?
    }

    struct Page {
        let path: String
    }

    // MARK: - site configs

    struct Site {
        let baseUrl: String
        let title: String
        let description: String
        let language: String?
        let dateFormat: String?
        
    }

    // MARK: - content configs

    struct Assets {
        let input: String
        let output: String
    }

    struct Themes {
        let use: String
        let path: String
        let templatesPath: String
        let assetsPath: String
        let overridesPath: String
    }

    struct Contents {
        
        struct Assets {
            let outputPath: String
        }

        struct Pagination {
            let limit: UInt
        }

        struct Blog {
            let posts: Content
            let authors: Content
            let tags: Content
        }

        struct Docs {
            let categories: Content
            let guides: Content
        }

        struct Pages {
            let custom: Content
        }

        let folder: String
        let assets: Assets
        let pagination: Pagination
        let blog: Blog
        let docs: Docs
        let pages: Pages
    }

    // MARK: - page configs

    struct Pages {

        struct Main {
            let home: Page
            let notFound: Page
        }

        struct Blog {
            let home: Page
            let authors: Page
            let tags: Page
            let posts: Page
        }

        struct Docs {
            let home: Page
            let categories: Page
            let guides: Page
        }

        let main: Main
        let blog: Blog
        let docs: Docs
    }

    // MARK: - properties

    let sourceUrl: URL
    let site: Site
    let assets: Assets
    let contents: Contents
    let themes: Themes
    let pages: Pages
    let userDefined: [String: Any]
}
