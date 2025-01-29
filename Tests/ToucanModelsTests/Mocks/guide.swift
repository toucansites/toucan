//
//  guide.swift
//  TestApp
//
//  Created by Tibor Bodecs on 2025. 01. 19..
//

@testable import ToucanModels

extension ContentBundle {

    static var guides: ContentBundle {

        .init(
            contentType: .init(
                id: "guide",
                location: "docs/guides",
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
                relations: [
                    .init(
                        key: "category",
                        references: "category",
                        type: .one,
                        order: .init(key: "name", direction: .asc)
                    )
                ],
                queries: [:]
            ),
            pageBundles: (0...9)
                .map { i in
                    .init(
                        frontMatter: [
                            "id": "guide-\(i)",
                            "name": "Guide \(i)",
                            "category": "category-\((0...9).randomElement()!)",
                            "order": i,
                        ],
                        properties: [:]
                    )
                }

        )
    }
}
