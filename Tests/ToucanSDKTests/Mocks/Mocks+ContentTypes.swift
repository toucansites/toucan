//
//  Mocks+ContentTypes.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 21..
//

import ToucanSource

extension Mocks.ContentTypes {
    static func page() -> ContentType {
        .init(
            id: "page",
            default: true,
            paths: [
                "pages",
            ],
            properties: [
                "draft": .init(
                    propertyType: .bool,
                    isRequired: true,
                    defaultValue: false
                ),
                "title": .init(
                    propertyType: .string,
                    isRequired: true
                ),
                "description": .init(
                    propertyType: .string,
                    isRequired: true
                ),
            ],
            relations: [:],
            queries: [:]
        )
    }

    static func author() -> ContentType {
        .init(
            id: "author",
            paths: [
                "blog/authors",
            ],
            properties: [
                "draft": .init(
                    propertyType: .bool,
                    isRequired: true,
                    defaultValue: false
                ),
                "name": .init(
                    propertyType: .string,
                    isRequired: true
                ),
                "description": .init(
                    propertyType: .string,
                    isRequired: false
                ),
                "image": .init(
                    propertyType: .asset,
                    isRequired: true
                ),
                "age": .init(
                    propertyType: .int,
                    isRequired: false
                ),
                "height": .init(
                    propertyType: .double,
                    isRequired: false
                ),
            ],
            relations: [:],
            queries: [
                "posts": .init(
                    contentType: "post",
                    scope: "list",
                    filter: .field(
                        key: "authors",
                        operator: .contains,
                        value: .init("{{id}}")
                    ),
                    orderBy: [
                        .init(
                            key: "publication",
                            direction: .desc
                        ),
                    ]
                ),
            ]
        )
    }

    static func tag() -> ContentType {
        .init(
            id: "tag",
            paths: [
                "blog/tags",
            ],
            properties: [
                "draft": .init(
                    propertyType: .bool,
                    isRequired: true,
                    defaultValue: false
                ),
                "title": .init(
                    propertyType: .string,
                    isRequired: true
                ),
                "description": .init(
                    propertyType: .string,
                    isRequired: true
                ),
            ],
            relations: [:],
            queries: [
                "posts": .init(
                    contentType: "post",
                    scope: "list",
                    filter: .field(
                        key: "tags",
                        operator: .contains,
                        value: .init("{{id}}")
                    ),
                    orderBy: [
                        .init(
                            key: "publication",
                            direction: .desc
                        ),
                    ]
                ),
            ]
        )
    }

    static func post() -> ContentType {
        .init(
            id: "post",
            paths: [
                "blog/posts",
            ],
            properties: [
                "draft": .init(
                    propertyType: .bool,
                    isRequired: true,
                    defaultValue: false
                ),
                "title": .init(
                    propertyType: .string,
                    isRequired: true
                ),
                "description": .init(
                    propertyType: .string,
                    isRequired: true
                ),
                "publication": .init(
                    propertyType: .date(
                        config: .init(
                            localization: .defaults,
                            format: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                        )
                    ),
                    isRequired: true
                ),
                "expiration": .init(
                    propertyType: .date(
                        config: .init(
                            localization: .defaults,
                            format: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                        )
                    ),
                    isRequired: true
                ),
                "featured": .init(
                    propertyType: .bool,
                    isRequired: true,
                    defaultValue: false
                ),
                "rating": .init(
                    propertyType: .double,
                    isRequired: false
                ),
            ],
            relations: [
                "authors": .init(
                    references: "author",
                    relationType: .many,
                    order: .init(
                        key: "title",
                        direction: .asc
                    )
                ),
                "tags": .init(
                    references: "tag",
                    relationType: .many,
                    order: .init(
                        key: "title",
                        direction: .asc
                    )
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
                        ),
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
                        ),
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

    static func category() -> ContentType {
        .init(
            id: "category",
            paths: [
                "docs/categories",
            ],
            properties: [
                "draft": .init(
                    propertyType: .bool,
                    isRequired: true,
                    defaultValue: false
                ),
                "title": .init(
                    propertyType: .string,
                    isRequired: true
                ),
                "description": .init(
                    propertyType: .string,
                    isRequired: false
                ),
                "order": .init(
                    propertyType: .int,
                    isRequired: true,
                    defaultValue: .init(100)
                ),
            ],
            relations: [:],
            queries: [
                "guides": .init(
                    contentType: "guide",
                    scope: "list",
                    filter: .field(
                        key: "category",
                        operator: .equals,
                        value: .init("{{id}}")
                    ),
                    orderBy: [
                        .init(
                            key: "order",
                            direction: .asc
                        ),
                    ]
                ),
            ]
        )
    }

    static func guide() -> ContentType {
        .init(
            id: "guide",
            paths: [
                "docs/guides",
            ],
            properties: [
                "draft": .init(
                    propertyType: .bool,
                    isRequired: true,
                    defaultValue: false
                ),
                "title": .init(
                    propertyType: .string,
                    isRequired: true
                ),
                "description": .init(
                    propertyType: .string,
                    isRequired: false
                ),
                "order": .init(
                    propertyType: .int,
                    isRequired: true,
                    defaultValue: .init(100)
                ),
            ],
            relations: [
                "category": .init(
                    references: "category",
                    relationType: .one
                ),
            ],
            queries: [:]
        )
    }

    static func redirect() -> ContentType {
        .init(
            id: "redirect",
            paths: [],
            properties: [
                "draft": .init(
                    propertyType: .bool,
                    isRequired: true,
                    defaultValue: false
                ),
                "to": .init(
                    propertyType: .string,
                    isRequired: true
                ),
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
}
