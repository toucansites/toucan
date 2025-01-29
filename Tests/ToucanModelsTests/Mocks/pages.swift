//
//  pages.swift
//  TestApp
//
//  Created by Tibor Bodecs on 2025. 01. 15..
//

@testable import ToucanModels

extension ContentBundle {

    static var pages: ContentBundle {

        .init(
            contentType: .init(
                id: "page",
                location: nil,
                properties: [
                    .init(
                        key: "title",
                        type: .string,
                        required: true,
                        default: nil
                    ),
                    .init(
                        key: "description",
                        type: .string,
                        required: true,
                        default: nil
                    ),
                ],
                relations: [],
                queries: [:]
            ),
            pageBundles: (0...9)
                .map { i in
                    .init(
                        frontMatter: [
                            "id": "page-\(i)",
                            "slug": "page-\(i)",
                            "title": "Page \(i)",
                            "description": "Page \(i) description",
                        ],
                        properties: [:]
                    )
                } + [
                    .init(
                        frontMatter: [
                            "id": "home",
                            "slug": "",
                            "title": "Home page",
                            "description": "Home page description",
                        ],
                        properties: [:]
                    ),
                    .init(
                        frontMatter: [
                            "id": "404",
                            "slug": "404",
                            "title": "404 page",
                            "description": "404 page description",
                        ],
                        properties: [:]
                    ),
                    .init(
                        frontMatter: [
                            "id": "about",
                            "slug": "about",
                            "title": "About page",
                            "description": "About page description",
                        ],
                        properties: [:]
                    ),
                ]
        )
    }
}
