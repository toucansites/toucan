//
//  category.swift
//  TestApp
//
//  Created by Tibor Bodecs on 2025. 01. 19..
//


@testable import ToucanModels

extension ContentBundle {
    
    static var categories: ContentBundle {
        
        .init(
            contentType: .init(
                id: "category",
                location: "docs/categories",
                properties: [
                    .init(
                        key: "name",
                        type: .string,
                        required: true,
                        default: nil
                    ),
                    .init(
                        key: "order",
                        type: .int,
                        required: false,
                        default: 100
                    ),
                ],
                relations: [],
                queries: [
                    "guides": .init(
                        contentType: "guide",
                        scope: "???",
                        limit: 100,
                        offset: 0,
                        filter: .field(key: "category", operator: .equals, value: "{{id}}"),
                        orderBy: [.init(key: "order", direction: .desc)]
                    ),
                ]
            ),
            pageBundles: (1...9).map { i in
                    .init(
                        frontMatter: [
                            "id": "category-\(i)",
                            "type": "category",
                            "slug": "categories/category-\(i)",
                            "name": "Category #\(i)",
                            "order": i,
                        ],
                        properties: [:]
                    )
            }
        )
    }
}
