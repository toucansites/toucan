//
//  File.swift
//  toucan
//
//  Created by Tibor Bödecs on 2025. 05. 21..
//

import ToucanSource

extension Mocks.Pipelines {

    static func html() -> Pipeline {
        .init(
            id: "html",
            scopes: [:],
            queries: [
                "featured": .init(
                    contentType: "post",
                    scope: "list",
                    filter: .field(
                        key: "featured",
                        operator: .equals,
                        value: true
                    )
                )
            ],
            dataTypes: .init(
                date: .init(
                    dateFormats: [
                        "full": .init(format: "y.m.d.")
                    ]
                )
            ),
            contentTypes: .init(
                include: [],
                exclude: [
                    "rss",
                    "sitemap",
                ],
                lastUpdate: [],
                filterRules: [:]
            ),
            // are iterators always pages? iteratorPages? or segments? 🤔
            iterators: [
                "post.pagination": .init(
                    contentType: "post",
                    limit: 2
                )
            ],
            assets: .defaults,
            transformers: [:],
            engine: .init(
                id: "mustache",
                options: [
                    "contentTypes": [
                        "post": [
                            "template": "post.default"
                        ]
                    ]
                ]
            ),
            output: .init(
                path: "{{slug}}",
                file: "index",
                ext: "html"
            )
        )
    }

    static func redirect() -> Pipeline {
        .init(
            id: "redirect",
            scopes: [:],
            queries: [:],
            dataTypes: .defaults,
            contentTypes: .init(
                include: [
                    "redirect"
                ],
                exclude: [],
                lastUpdate: [],
                filterRules: [:]
            ),
            iterators: [:],
            assets: .defaults,
            transformers: [:],
            engine: .init(
                id: "mustache",
                options: [
                    "contentTypes": [
                        "redirect": [
                            "template": "redirect"
                        ]
                    ]
                ]
            ),
            output: .init(
                path: "{{slug}}",
                file: "index",
                ext: "html"
            )
        )
    }

    static func rss() -> Pipeline {
        .init(
            id: "rss",
            scopes: [:],
            queries: [:],
            dataTypes: .defaults,
            contentTypes: .init(
                include: [
                    "rss"
                ],
                exclude: [],
                lastUpdate: [
                    "post",
                    "author",
                    "tag",
                ],
                filterRules: [:]
            ),
            iterators: [:],
            assets: .defaults,
            transformers: [:],
            engine: .init(
                id: "mustache",
                options: [
                    "contentTypes": [
                        "rss": [
                            "template": "rss"
                        ]
                    ]
                ]
            ),
            output: .init(
                path: "",
                file: "rss",
                ext: "xml"
            )
        )
    }

    static func sitemap() -> Pipeline {
        .init(
            id: "sitemap",
            scopes: [:],
            queries: [
                "pages": .init(
                    contentType: "page",
                    scope: "list",
                    orderBy: [
                        .init(key: "lastUpdate", direction: .desc)
                    ]
                ),
                "posts": .init(
                    contentType: "post",
                    scope: "list",
                    limit: 2,
                    orderBy: [
                        .init(key: "lastUpdate", direction: .desc)
                    ]
                ),
                "authors": .init(
                    contentType: "author",
                    scope: "list",
                    limit: 2,
                    orderBy: [
                        .init(key: "lastUpdate", direction: .desc)
                    ]
                ),
                "tags": .init(
                    contentType: "tag",
                    scope: "list",
                    limit: 2,
                    orderBy: [
                        .init(key: "lastUpdate", direction: .desc)
                    ]
                ),
            ],
            dataTypes: .defaults,
            contentTypes: .init(
                include: [
                    "sitemap"
                ],
                exclude: [],
                lastUpdate: [],
                filterRules: [:]
            ),
            iterators: [
                "post.pagination": .init(
                    contentType: "post",
                    limit: 2
                )
            ],
            assets: .defaults,
            transformers: [:],
            engine: .init(
                id: "mustache",
                options: [
                    "contentTypes": [
                        "sitemap": [
                            "template": "sitemap"
                        ]
                    ]
                ]
            ),
            output: .init(
                path: "",
                file: "sitemap",
                ext: "xml"
            )
        )
    }

    static func context() -> Pipeline {
        .init(
            id: "context",
            scopes: [
                "*": [
                    "reference": .init(
                        context: .reference,
                        fields: []
                    ),
                    "list": .init(
                        context: .list,
                        fields: []
                    ),
                    "detail": .init(
                        context: .detail,
                        fields: []
                    ),
                    "custom": .init(
                        context: .properties,
                        fields: ["id"]
                    ),
                ]
            ],
            queries: [
                "featured": .init(
                    contentType: "post",
                    scope: "list",
                    filter: .field(
                        key: "featured",
                        operator: .equals,
                        value: true
                    )
                )
            ],
            dataTypes: .init(
                date: .init(
                    dateFormats: [
                        "full": .init(format: "y.m.d.")
                    ]
                )
            ),
            contentTypes: .defaults,
            iterators: [
                "post.pagination": .init(
                    contentType: "post",
                    limit: 2
                )
            ],
            assets: .defaults,
            transformers: [:],
            engine: .init(
                id: "context",
                options: [:]
            ),
            output: .init(
                path: "_contexts/{{slug}}",
                file: "context",
                ext: "json"
            )
        )
    }
}
