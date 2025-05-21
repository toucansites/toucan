//
//  File.swift
//  toucan
//
//  Created by Tibor Bödecs on 2025. 05. 21..
//

import ToucanSource

extension Mocks.ContentDefinitions {

    static func page() -> ContentDefinition {
        .init(
            id: "page",
            default: true,
            paths: [
                "pages"
            ],
            properties: [
                "title": .init(
                    propertyType: .string,
                    isRequired: true,
                    defaultValue: nil
                ),
                "description": .init(
                    propertyType: .string,
                    isRequired: true,
                    defaultValue: nil
                ),
            ],
            relations: [:],
            queries: [:]
        )
    }

    static func author(isDefault: Bool = false) -> ContentDefinition {
        .init(
            id: "author",
            default: isDefault,
            paths: [
                "blog/authors"
            ],
            properties: [
                "name": .init(
                    propertyType: .string,
                    isRequired: true,
                    defaultValue: nil
                ),
                "description": .init(
                    propertyType: .string,
                    isRequired: false,
                    defaultValue: nil
                ),
                "age": .init(
                    propertyType: .int,
                    isRequired: false,
                    defaultValue: nil
                ),
                "height": .init(
                    propertyType: .double,
                    isRequired: false,
                    defaultValue: nil
                ),
            ],
            relations: [:],
            queries: [
                "posts": .init(
                    contentType: "post",
                    scope: "list",
                    limit: 100,
                    offset: 0,
                    filter: .field(
                        key: "authors",
                        operator: .contains,
                        value: .init("{{id}}")
                    ),
                    orderBy: [
                        .init(key: "publication", direction: .desc)
                    ]
                )
            ]
        )
    }

    static func tag() -> ContentDefinition {
        .init(
            id: "tag",
            paths: [
                "blog/tags"
            ],
            properties: [
                "title": .init(
                    propertyType: .string,
                    isRequired: true,
                    defaultValue: nil
                )
            ],
            relations: [:],
            queries: [
                "posts": .init(
                    contentType: "post",
                    scope: "list",
                    limit: 100,
                    offset: 0,
                    filter: .field(
                        key: "tags",
                        operator: .contains,
                        value: .init("{{id}}")
                    ),
                    orderBy: [
                        .init(key: "publication", direction: .desc)
                    ]
                )
            ]
        )
    }

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

    static func category() -> ContentDefinition {
        .init(
            id: "category",
            paths: [
                "docs/categories"
            ],
            properties: [
                "title": .init(
                    propertyType: .string,
                    isRequired: true,
                    defaultValue: nil
                ),
                "order": .init(
                    propertyType: .int,
                    isRequired: false,
                    defaultValue: .init(100)
                ),
            ],
            relations: [:],
            queries: [
                "guides": .init(
                    contentType: "guide",
                    scope: "list",
                    limit: 100,
                    offset: 0,
                    filter: .field(
                        key: "category",
                        operator: .equals,
                        value: .init("{{id}}")
                    ),
                    orderBy: [
                        .init(key: "order", direction: .desc)
                    ]
                )
            ]
        )
    }

    static func guide() -> ContentDefinition {
        .init(
            id: "guide",
            paths: [
                "docs/guides"
            ],
            properties: [
                "title": .init(
                    propertyType: .string,
                    isRequired: true,
                    defaultValue: nil
                ),
                "order": .init(
                    propertyType: .int,
                    isRequired: false,
                    defaultValue: .init(100)
                ),
            ],
            relations: [
                "category": .init(
                    references: "category",
                    relationType: .one,
                    order: .init(key: "name", direction: .asc)
                )
            ],
            queries: [:]
        )
    }
    static func redirect() -> ContentDefinition {
        .init(
            id: "redirect",
            paths: [],
            properties: [
                "to": .init(propertyType: .string, isRequired: true),
                "code": .init(
                    propertyType: .int,
                    isRequired: true,
                    defaultValue: .init(301)
                ),
            ],
            relations: [:],
            queries: [:]
        )
    }

    static func rss() -> ContentDefinition {
        .init(
            id: "rss",
            paths: [],
            properties: [:],
            relations: [:],
            queries: [
                // for testing purpopses, we use authors, posts and tags
                "posts": .init(
                    contentType: "post",
                    scope: "list",
                    orderBy: [
                        .init(key: "lastUpdate", direction: .desc)
                    ]
                ),
                "authors": .init(
                    contentType: "author",
                    scope: "list",
                    orderBy: [
                        .init(key: "lastUpdate", direction: .desc)
                    ]
                ),
                "tags": .init(
                    contentType: "tag",
                    scope: "list",
                    orderBy: [
                        .init(key: "lastUpdate", direction: .desc)
                    ]
                ),
            ]
        )
    }

    static func sitemap() -> ContentDefinition {
        .init(
            id: "sitemap",
            paths: [],
            properties: [:],
            relations: [:],
            queries: [:]
        )
    }
}
