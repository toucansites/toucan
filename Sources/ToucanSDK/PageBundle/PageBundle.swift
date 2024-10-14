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
    let imageUrl: String?
    let date: DateValue

    let contentType: ContentType
    let publication: Date
    let lastModification: Date
    let config: Config
    let frontMatter: [String: Any]
    let properties: [String: Any]
    let relations: [String: Any]
    let markdown: String
    let css: [String]
    let js: [String]

    var dict: [String: Any] {
        config.userDefined
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
