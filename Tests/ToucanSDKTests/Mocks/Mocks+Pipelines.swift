//
//  Mocks+Pipelines.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 21..
//

import ToucanSource

extension Mocks.Pipelines {
    static func html() -> Pipeline {
        .init(
            id: "html",
            definesType: false,
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
                    output: .defaults,
                    formats: [
                        "rss": .init(
                            localization: .defaults,
                            format: "EEE, dd MMM yyyy HH:mm:ss Z"
                        ),
                        "sitemap": .init(
                            localization: .defaults,
                            format: "yyyy-MM-dd"
                        ),
                        "year": .init(
                            localization: .defaults,
                            format: "y"
                        ),
                    ]
                )
            ),
            contentTypes: .init(
                include: [],
                exclude: [
                    "rss",
                    "sitemap",
                    "redirect",
                    "not-found",
                ],
                lastUpdate: [
                    "page",
                    "author",
                    "tag",
                    "post",
                    "guide",
                    "category",
                ],
                filterRules: [
                    "*": .field(
                        key: "draft",
                        operator: .equals,
                        value: false
                    ),
                    "post": .and(
                        [
                            .field(
                                key: "draft",
                                operator: .equals,
                                value: false
                            ),
                            .field(
                                key: "publication",
                                operator: .lessThanOrEquals,
                                value: "{{date.now}}"
                            ),
                            .field(
                                key: "expiration",
                                operator: .greaterThanOrEquals,
                                value: "{{date.now}}"
                            ),
                        ]
                    ),
                ]
            ),
            iterators: [
                "post.pagination": .init(
                    contentType: "post",
                    limit: 2
                )
            ],
            assets: .init(
                behaviors: [
                    .init(
                        id: "copy",
                        input: .init(name: "*", ext: "*"),
                        output: .init(name: "*", ext: "*")
                    )
                ],
                properties: [
                    .init(
                        action: .add,
                        property: "css",
                        resolvePath: true,
                        input: .init(name: "style", ext: "css")
                    ),
                    .init(
                        action: .add,
                        property: "js",
                        resolvePath: false,
                        input: .init(name: "main", ext: "js")
                    ),
                    .init(
                        action: .set,
                        property: "image",
                        resolvePath: true,
                        input: .init(name: "cover", ext: "jpg")
                    ),
                    .init(
                        action: .load,
                        property: "svg",
                        resolvePath: false,
                        input: .init(
                            name: "icon",
                            ext: "svg"
                        )
                    ),
                    .init(
                        action: .load,
                        property: "svgs",
                        resolvePath: true,
                        input: .init(
                            path: "icons",
                            name: "*",
                            ext: "svg"
                        )
                    ),
                    .init(
                        action: .parse,
                        property: "yaml",
                        resolvePath: false,
                        input: .init(
                            name: "data",
                            ext: "yml"
                        )
                    ),
                    .init(
                        action: .parse,
                        property: "yamls",
                        resolvePath: true,
                        input: .init(
                            path: "dataset",
                            name: "*",
                            ext: "yaml"
                        )
                    ),
                ]
            ),
            transformers: [:],
            engine: .init(
                id: "mustache",
                options: [
                    "contentTypes": [
                        "page": [
                            "view": "pages.default"
                        ],
                        "post": [
                            "view": "blog.post.default"
                        ],
                        "author": [
                            "view": "blog.author.default"
                        ],
                        "tag": [
                            "view": "blog.tag.default"
                        ],
                        "category": [
                            "view": "docs.category.default"
                        ],
                        "guide": [
                            "view": "docs.guide.default"
                        ],
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

    static func notFound() -> Pipeline {
        .init(
            id: "not-found",
            definesType: true,
            scopes: [:],
            queries: [:],
            dataTypes: .defaults,
            contentTypes: .init(
                include: [
                    "not-found"
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
                        "not-found": [
                            "view": "pages.404"
                        ]
                    ]
                ]
            ),
            output: .init(
                path: "",
                file: "404",
                ext: "html"
            )
        )
    }

    static func redirect() -> Pipeline {
        .init(
            id: "redirect",
            definesType: true,
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
                            "view": "redirect"
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
            definesType: true,
            scopes: [:],
            queries: [
                "posts": .init(
                    contentType: "post",
                    scope: "list",
                    orderBy: [
                        .init(key: "lastUpdate", direction: .desc)
                    ]
                )
            ],
            dataTypes: .init(
                date: .init(
                    output: .defaults,
                    formats: [
                        "rss": .init(
                            localization: .defaults,
                            format: "EEE, dd MMM yyyy HH:mm:ss Z"
                        )
                    ]
                )
            ),
            contentTypes: .init(
                include: [
                    "rss"
                ],
                exclude: [],
                lastUpdate: [
                    "post"
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
                            "view": "rss"
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
            definesType: true,
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
            ],
            dataTypes: .init(
                date: .init(
                    output: .defaults,
                    formats: [
                        "sitemap": .init(
                            localization: .defaults,
                            format: "yyyy-MM-dd"
                        )
                    ]
                )
            ),
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
            assets: .init(
                behaviors: [],
                properties: []
            ),
            transformers: [:],
            engine: .init(
                id: "mustache",
                options: [
                    "contentTypes": [
                        "sitemap": [
                            "view": "sitemap"
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

    static func api() -> Pipeline {
        .init(
            id: "api",
            definesType: true,
            scopes: [:],
            queries: [
                "posts": .init(
                    contentType: "post",
                    scope: "list",
                    orderBy: [
                        .init(
                            key: "publication",
                            direction: .desc
                        )
                    ]
                )
            ],
            dataTypes: .defaults,
            contentTypes: .init(
                include: ["api"],
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
                id: "json",
                options: [
                    "keyPath": "context.posts"
                ]
            ),
            output: .init(
                path: "api",
                file: "posts",
                ext: "json"
            )
        )
    }
}
