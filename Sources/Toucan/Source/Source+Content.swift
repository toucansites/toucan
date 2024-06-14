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
}
