//
//  File.swift
//
//
//  Created by Tibor Bodecs on 27/06/2024.
//

import Foundation

/// A page bundle representing a subpage for a website.
struct PageBundle {

    struct DateValue {
        let html: String
        let rss: String
        let sitemap: String
    }

    let id: String
    let url: URL

    let slug: String
    let permalink: String

    let title: String
    let description: String
    let date: DateValue

    let contentType: ContentType
    let publication: Date
    let lastModification: Date
    let config: Config
    let frontMatter: [String: Any]
    let properties: [String: Any]
    let relations: [String: Any]
    let markdown: String
    let assets: [String]

    // MARK: -

    var assetsLocation: String {
        slug.isEmpty ? "home" : slug
    }

    func resolveAsset(path: String) -> String {
        let prefix = "./\(config.assets.folder)/"
        guard path.hasPrefix(prefix) else {
            return path
        }
        let src = String(path.dropFirst(prefix.count))
        return "/" + config.assets.folder + "/" + assetsLocation + "/" + src
    }

    // MARK: -

    var baseContext: [String: Any] {

        let assetsPrefix = "./\(config.assets.folder)/"

        // resolve imageUrl context
        var imageUrl: String?
        if let image = config.image {
            imageUrl = resolveAsset(path: image)
        }
        else if assets.contains("cover.jpg") {
            imageUrl = resolveAsset(path: assetsPrefix + "cover.jpg")
        }
        else if assets.contains("cover.png") {
            imageUrl = resolveAsset(path: assetsPrefix + "cover.png")
        }

        // resolve css context
        var css = config.css.map { resolveAsset(path: $0) }
        if assets.contains("style.css") {
            css.append(resolveAsset(path: assetsPrefix + "style.css"))
        }
        css = Array(Set(css))

        // resolve js context
        var js = config.js.map { resolveAsset(path: $0) }
        if assets.contains("main.js") {
            js.append(resolveAsset(path: assetsPrefix + "main.js"))
        }
        js = Array(Set(js))

        return config.userDefined
            .recursivelyMerged(
                with: [
                    "slug": slug,
                    "permalink": permalink,
                    "title": title,
                    "description": description,
                    "imageUrl": imageUrl ?? false,
                    "publication": date,
                    "css": css,
                    "js": js,
                ]
            )
            .recursivelyMerged(
                with: properties
            )
            .recursivelyMerged(
                with: relations
            )
            .sanitized()
    }
}
