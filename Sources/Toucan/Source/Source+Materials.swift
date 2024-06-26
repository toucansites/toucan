//
//  File.swift
//
//
//  Created by Tibor Bodecs on 13/06/2024.
//

import Foundation

extension Source {

    struct Material {
        let location: URL
        
        let slug: String
        let title: String
        let description: String
        let image: String?
        
        let css: [String]
        let js: [String]

        let template: String?
        let assetsPath: String
        let lastModification: Date
        let redirects: [String]
        let userDefined: [String: Any]
        let data: [[String: Any]]
        
        let frontMatter: [String: Any]
        let markdown: String

        func updated(slug: String) -> Self {
            .init(
                location: location,
                slug: slug,
                title: title,
                description: description,
                image: image,
                css: css,
                js: js,
                template: template,
                assetsPath: assetsPath,
                lastModification: lastModification,
                redirects: redirects,
                userDefined: userDefined,
                data: data,
                frontMatter: frontMatter,
                markdown: markdown
            )
        }
        
        func resolveAsset(_ value: String?) -> String? {
            let prefix = "./\(assetsPath)"
            guard let value, value.hasPrefix(prefix) else {
                return value
            }
            let base = String(value.dropFirst(prefix.count))
            return "/assets/" + slug + "/" + base.safeSlug(prefix: nil)
        }
        
        func imageUrl() -> String? {
            resolveAsset(image)
        }
        
        func cssUrls() -> [String] {
            css.compactMap { resolveAsset($0) }
        }
        
        func jsUrls() -> [String] {
            js.compactMap { resolveAsset($0) }
        }
    }

    // MARK: - contents

    //@DebugDescription
    struct Materials {

        struct Blog {
            let authors: [Material]
            let tags: [Material]
            let posts: [Material]
        }

        struct Docs {
            let categories: [Material]
            let guides: [Material]
        }

        // MARK: - pages

        struct Pages {

            struct Main {
                let home: Material
                let notFound: Material
            }

            struct Blog {
                let home: Material?
                let authors: Material?
                let tags: Material?
                let posts: Material?
            }

            struct Docs {
                let home: Material?
                let categories: Material?
                let guides: Material?
            }

            let main: Main
            let blog: Blog
            let docs: Docs
            let custom: [Material]
        }

        let blog: Blog
        let docs: Docs
        let pages: Pages
    }
}

extension Source.Materials {

    func all() -> [Source.Material] {
        var contents: [Source.Material?] = []

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
