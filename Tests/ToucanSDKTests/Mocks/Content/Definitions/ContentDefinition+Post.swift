//
//  ContentDefinition+Post.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 04. 17..

import ToucanModels

public extension ContentDefinition.Mocks {

    static func post() -> ContentDefinition {
        .init(
            id: "post",
            paths: [
                "blog/posts"
            ],
            properties: [
                "title": .init(
                    propertyType: .string,
                    isRequired: true,
                    defaultValue: nil
                ),
                "publication": .init(
                    propertyType: .date(
                        format: .init(format: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
                    ),
                    isRequired: true,
                    defaultValue: nil
                ),
                "featured": .init(
                    propertyType: .bool,
                    isRequired: true,
                    defaultValue: .init(false)
                ),
                "ages": .init(
                    propertyType: .array(of: .int),
                    isRequired: true,
                    defaultValue: nil
                ),
                "heights": .init(
                    propertyType: .array(of: .double),
                    isRequired: true,
                    defaultValue: nil
                ),
            ],
            relations: [
                "authors": .init(
                    references: "author",
                    relationType: .many,
                    order: .init(key: "title", direction: .asc)
                ),
                "tags": .init(
                    references: "tag",
                    relationType: .many,
                    order: .init(key: "title", direction: .asc)
                ),
            ],
            queries: [
                "prev": .init(
                    contentType: "post",
                    limit: 1,
                    filter: .field(
                        key: "publication",
                        operator: .lessThan,
                        value: .init("{{publication}}")
                    ),
                    orderBy: [
                        .init(
                            key: "publication",
                            direction: .desc
                        )
                    ]
                ),

                "next": .init(
                    contentType: "post",
                    limit: 1,
                    filter: .field(
                        key: "publication",
                        operator: .greaterThan,
                        value: .init("{{publication}}")
                    ),
                    orderBy: [
                        .init(
                            key: "publication",
                            direction: .asc
                        )
                    ]
                ),

                "related": .init(
                    contentType: "post",
                    scope: "list",
                    limit: 4,
                    filter: .and(
                        [
                            .field(
                                key: "id",
                                operator: .notEquals,
                                value: .init("{{id}}")
                            ),
                            .field(
                                key: "authors",
                                operator: .matching,
                                value: .init("{{authors}}")
                            ),
                        ]
                    ),
                    orderBy: []
                ),

                "similar": .init(
                    contentType: "post",
                    scope: "list",
                    limit: 4,
                    filter: .and(
                        [
                            .field(
                                key: "id",
                                operator: .notEquals,
                                value: .init("{{id}}")
                            ),
                            .field(
                                key: "tags",
                                operator: .matching,
                                value: .init("{{tags}}")
                            ),
                        ]
                    ),
                    orderBy: []
                ),
            ]
        )
    }
}
