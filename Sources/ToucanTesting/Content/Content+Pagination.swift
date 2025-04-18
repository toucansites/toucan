//
//  Content+Pagination.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 04. 17..

import Foundation
import ToucanModels

public extension Content.Mocks {

    static func pagination(
        now: Date = .init()
    ) -> Content {

        return .init(
            id: "{{post.pagination}}",
            slug: .init(value: "posts/page/{{post.pagination}}"),
            rawValue: .init(
                origin: .init(
                    path: "posts/{{post.pagination}}/index.md",
                    slug: "{{post.pagination}}"
                ),
                frontMatter: [
                    "slug": .init("posts/page/{{post.pagination}}"),
                    "image": nil,
                    "type": .init("page"),
                    "css": .init([]),
                    "js": .init([]),
                    "title": .init("Posts - {{number}} / {{total}}"),
                    "description": .init("Posts page - {{number}} / {{total}}"),
                    "home": .init("posts/page"),
                    "template": .init("default"),
                ],
                markdown: "",
                lastModificationDate: now.timeIntervalSince1970,
                assets: []
            ),
            definition: .init(
                id: "page",
                default: true,
                paths: [],
                properties: [
                    "title": Property(
                        propertyType: PropertyType.string,
                        isRequired: true,
                        defaultValue: nil
                    )
                ],
                relations: [:],
                queries: [:]
            ),

            properties: [
                "title": .init("Posts - {{number}} / {{total}}")
            ],
            relations: [:],
            userDefined: [
                "image": nil,
                "css": .init([]),
                "js": .init([]),
                "description": .init("Posts page - {{number}} / {{total}}"),
                "home": .init("posts/page"),
                "template": .init("default"),
            ],
            iteratorInfo: nil
        )
    }

}
