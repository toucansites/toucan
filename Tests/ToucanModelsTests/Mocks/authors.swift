//
//  authors.swift
//  TestApp
//
//  Created by Tibor Bodecs on 2025. 01. 15..
//


@testable import ToucanModels

extension ContentBundle {

    static var authors: ContentBundle {
        .init(
            contentType: .init(
                id: "author",
                location: "blog/authors",
                properties: [
                    .init(
                        key: "name",
                        type: .string,
                        required: true,
                        default: nil
                    ),
                    .init(
                        key: "description",
                        type: .string,
                        required: false,
                        default: nil
                    ),
                ],
                relations: [],
                queries: [
                    "posts": .init(
                        contentType: "post",
                        scope: "list",
                        limit: 100,
                        offset: 0,
                        filter: .field(key: "authors", operator: .contains, value: "{{id}}"),
                        orderBy: [.init(key: "publication", direction: .desc)]
                    ),
                ]
            ),
            pageBundles: (1...9).map { i in
                    .init(
                        frontMatter: [
                            "id": "author-\(i)",
                            "type": "author",
                            "slug": "authors/author-\(i)",
                            "name": "Author \(i)",
                            "description": "Author description \(i)",
                        ],
                        properties: [:]
                    )
            }
        )
    }
}
