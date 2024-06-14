//
//  File.swift
//
//
//  Created by Tibor Bodecs on 13/06/2024.
//

import Foundation

extension Source {

    struct Content {
        let slug: String
        let title: String
        let description: String
        let coverImage: String?
        let template: String?

        let lastModification: Date
        let frontMatter: [String: Any]
        let markdown: String

        func updated(slug: String) -> Self {
            .init(
                slug: slug,
                title: title,
                description: description,
                coverImage: coverImage,
                template: template,
                lastModification: lastModification,
                frontMatter: frontMatter,
                markdown: markdown
            )
        }
    }

    // MARK: - contents

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

extension Source.Contents {
    
    func all() -> [Source.Content] {
        var contents: [Source.Content?] = []
        
        contents += [pages.main.home]
        contents += [pages.main.notFound]
        contents += [pages.blog.home]
        contents += [pages.blog.authors]
        contents += [pages.blog.tags]
        contents += [pages.blog.posts]
        contents += [pages.docs.home]
        contents += [pages.docs.categories]
        contents += [pages.docs.guides]
        contents += pages.custom
        contents += blog.authors
        contents += blog.tags
        contents += blog.posts
        contents += docs.categories
        contents += docs.guides

        return contents.compactMap { $0 }
    }
    
    func validateSlugs() throws {
        let slugs = all().map(\.slug)
        let uniqueSlugs = Set(slugs)
        guard slugs.count == uniqueSlugs.count else {
            fatalError("invalid slugs")
        }
    }
}
