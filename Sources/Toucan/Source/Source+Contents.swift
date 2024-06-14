//
//  File.swift
//
//
//  Created by Tibor Bodecs on 13/06/2024.
//

import Foundation

extension Source {

    //@DebugDescription
    struct Contents {

        struct Blog {
            let authors: [Content]
            let tags: [Content]
            let posts: [Content]
        }

        struct Docs {
            let categories: [Content]
            let guides: [Content]
        }

        // MARK: - pages

        struct Pages {

            struct Main {
                let home: Content
                let notFound: Content
            }

            struct Blog {
                let home: Content?
                let authors: Content?
                let tags: Content?
                let posts: Content?
            }

            struct Docs {
                let home: Content?
                let categories: Content?
                let guides: Content?
            }

            let main: Main
            let blog: Blog
            let docs: Docs
            let custom: [Content]
        }

        let blog: Blog
        let docs: Docs
        let pages: Pages
    }
}
