//
//  categories.swift
//  TestApp
//
//  Created by Tibor Bodecs on 2025. 01. 15..
//


@testable import ToucanModels

extension ContentBundle {
    
    static var tags: ContentBundle {
        .init(
            contentType: .init(
                id: "tag",
                location: "blog/tags",
                properties: [
                    .init(
                        key: "name",
                        type: .string,
                        required: true,
                        default: nil
                    ),
                ],
                relations: [],
                queries: [
                    "posts": .init(
                        contentType: "post",
                        scope: "???",
                        limit: 100,
                        offset: 0,
                        filter: .field(key: "tags", operator: .contains, value: "{{id}}"),
                        orderBy: [.init(key: "publication", direction: .desc)]
                    ),
                ]
            ),
            pageBundles: (0...9).map { i in
                    .init(
                        frontMatter: [
                            "id": "tags-\(i)",
                            "name": "Tag \(i)",
                        ],
                        properties: [:]
                    )
            }
            
        )
    }
}
