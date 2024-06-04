//
//  File.swift
//
//
//  Created by Tibor Bodecs on 03/05/2024.
//

import struct Foundation.Date

extension Content {

    struct Post: ContentInterface {

        static let folder = "blog/posts"
        static let slugPrefix: String? = "posts"

        let id: String
        let slug: String
        let title: String
        let description: String
        let coverImage: String?
        let template: String?
        let lastModification: Date
        let frontMatter: [String: Any]
        let markdown: String

        let publication: Date
        let authorIds: [String]
        let tagIds: [String]
        let featured: Bool

        var userDefined: [String: Any] {
            frontMatter.filter {
                ![
                    "slug",
                    "title",
                    "description",
                    "coverImage",
                    "template",
                    "publication",
                    "authors",
                    "tags",
                    "featured",
                ]
                .contains($0.key)
            }
        }
    }
}
