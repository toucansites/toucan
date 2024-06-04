//
//  File.swift
//
//
//  Created by Tibor Bodecs on 27/05/2024.
//

extension Content {

    struct Config {

        struct Site {
            let baseUrl: String
            let title: String
            let description: String
            let language: String?
            let dateFormat: String?

            let userDefined: [String: Any]
        }

        struct Blog {
            struct Posts {

                struct Page {
                    let slug: String?
                    let limit: Int
                }

                let slug: String?
                let page: Page
            }

            struct Authors {
                let slug: String?
            }

            struct Tags {
                let slug: String?
            }

            let slug: String?
            let posts: Posts
            let authors: Authors
            let tags: Tags
        }

        struct Pages {
            let slug: String?
        }

        let site: Site
        let blog: Blog
        let pages: Pages
    }

}
