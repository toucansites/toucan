//
//  File.swift
//
//
//  Created by Tibor Bodecs on 13/06/2024.
//

import Foundation

//@DebugDescription
struct SourceMaterials {

    struct Blog {
        let authors: [SourceMaterial]
        let tags: [SourceMaterial]
        let posts: [SourceMaterial]
    }

    struct Docs {
        let categories: [SourceMaterial]
        let guides: [SourceMaterial]
    }

    // MARK: - pages

    struct Pages {

        struct Main {
            let home: SourceMaterial
            let notFound: SourceMaterial
        }

        struct Blog {
            let home: SourceMaterial?
            let authors: SourceMaterial?
            let tags: SourceMaterial?
            let posts: SourceMaterial?
        }

        struct Docs {
            let home: SourceMaterial?
            let categories: SourceMaterial?
            let guides: SourceMaterial?
        }
        
        struct Custom {
            let home: SourceMaterial?
            let pages: [SourceMaterial]
        }

        let main: Main
        let blog: Blog
        let docs: Docs
        let custom: Custom
    }

    let blog: Blog
    let docs: Docs
    let pages: Pages
}


extension SourceMaterials {

    func all() -> [SourceMaterial] {
        var result: [SourceMaterial?] = []

        result += [pages.main.home]
        result += [pages.main.notFound]
        result += [pages.blog.home]
        result += [pages.blog.authors]
        result += [pages.blog.tags]
        result += [pages.blog.posts]
        result += [pages.docs.home]
        result += [pages.docs.categories]
        result += [pages.docs.guides]
        result += [pages.custom.home]
        result += pages.custom.pages
        result += blog.authors
        result += blog.tags
        result += blog.posts
        result += docs.categories
        result += docs.guides

        return result.compactMap { $0 }
    }

    func validateSlugs() throws {
        let slugs = all().map(\.slug)
        let uniqueSlugs = Set(slugs)
        guard slugs.count == uniqueSlugs.count else {
            var seenSlugs = Set<String>()
            var duplicateSlugs = Set<String>()

            for element in slugs {
                if seenSlugs.contains(element) {
                    duplicateSlugs.insert(element)
                } 
                else {
                    seenSlugs.insert(element)
                }
            }

            for element in duplicateSlugs {
                fatalError("Duplicate slug: \(element)")
            }
            fatalError("Invalid slugs")
        }
    }
}
