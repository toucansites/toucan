//
//  File.swift
//
//
//  Created by Tibor Bodecs on 13/06/2024.
//

import Foundation

extension Source {

    struct Config {

        struct ContentConfig {
            let folder: String
            let slugPrefix: String?
        }

        struct PageConfig {
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

        struct Contents {
            struct Blog {
                let posts: ContentConfig
                let authors: ContentConfig
                let tags: ContentConfig
            }

            struct Docs {
                let categories: ContentConfig
                let guides: ContentConfig
            }

            struct Pages {
                let custom: ContentConfig
            }

            let blog: Blog
            let docs: Docs
            let pages: Pages
        }

        // MARK: - page configs

        struct Pages {

            struct Main {
                let home: PageConfig
                let notFound: PageConfig
            }

            struct Blog {
                let home: PageConfig
                let authors: PageConfig
                let tags: PageConfig
                let posts: PageConfig
            }

            struct Docs {
                let home: PageConfig
                let categories: PageConfig
                let guides: PageConfig
            }

            let main: Main
            let blog: Blog
            let docs: Docs
        }

        // MARK: - properties

        let site: Site
        let contents: Contents
        let pages: Pages
    }
}
