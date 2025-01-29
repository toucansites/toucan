//
//  posts.swift
//  TestApp
//
//  Created by Tibor Bodecs on 2025. 01. 15..
//


@testable import ToucanModels

extension ContentBundle {
    
    static var posts: ContentBundle {
        
        .init(
            contentType: .init(
                id: "post",
                location: "blog/posts",
                properties: [
                    .init(
                        key: "name",
                        type: .string,
                        required: true,
                        default: nil
                    ),
                    .init(
                        key: "date",
                        type: .date(format: "yyyy-MM-dd'T'HH:mm:ssZ"),
                        required: true,
                        default: nil
                    ),
                    .init(
                        key: "featured",
                        type: .bool,
                        required: true,
                        default: false
                    ),
                ],
                relations: [
                    .init(
                        key: "authors",
                        references: "author",
                        type: .many,
                        order: .init(key: "title", direction: .asc)
                    ),
                    .init(
                        key: "tags",
                        references: "tag",
                        type: .many,
                        order: .init(key: "title", direction: .asc)
                    )
                ],
                queries: [
                    "related": .init(
                        contentType: "post",
                        scope: "list",
                        limit: 4,
                        offset: 0,
                        filter: .field(key: "tags", operator: .in, value: "{{tags}}"),
                        orderBy: []
                    ),
                ]
            ),
            pageBundles: (0...9).map { i in
                    .init(
                        frontMatter: [
                            "id": "post-\(i)",
                            "slug": "posts/post-\(i)",
                            "name": "Post \(i)",
                            "date": "2022-01-31T02:22:40+00:00",
                            "featured": Bool.random(),
                            "authors": (0...9).shuffled().prefix((1...4).randomElement()!).map { "author-\($0)" },
                            "tags": (0...9).shuffled().prefix((1...4).randomElement()!).map { "tag-\($0)" },
                        ],
                        properties: [:]
                    )
            }
        )
    }
}
