//
//  rc.swift
//  TestApp
//
//  Created by Tibor Bodecs on 2025. 01. 19..
//

@testable import ToucanModels

extension RendererConfig {

    static var mock: RendererConfig {

        .init(
            queries: [
                "posts": .init(
                    contentType: "post",
                    scope: "list",
                    limit: nil,
                    offset: nil,
                    filter: nil,
                    orderBy: []
                ),
                "featured_posts": .init(
                    contentType: "post",
                    scope: "list",
                    limit: nil,
                    offset: nil,
                    filter: .field(
                        key: "featured",
                        operator: .equals,
                        value: true
                    ),
                    orderBy: [
                        .init(key: "date", direction: .desc)
                    ]
                ),
                // featured... etc.
            ],
            renders: .pageBundle,
            template: .init(
                engine: "mustache",  // mustache|json|swift|...
                options: [  //mustache-renderer-config
                    "dataTypes": [
                        "date": [
                            "formats": [
                                "full": "...",
                                "medium": "...",
                                    //                        "iso886"
                                    //                        "rss"
                                    //                        "sitemap"
                            ]
                        ]
                    ],
                    "contentTypes": [
                        "post": [
                            "template": "post.default.template",
                            "properties": [
                                "date": [
                                    "formats": [
                                        "custom": "y.md."
                                    ]
                                ]
                            ],
                            "scopes": [  // views?
                                //...
                                "reference": ["id", "title"],
                                "list": [
                                    "id", "title", "description", "authors",
                                ],
                                "detail": ["*"],
                            ],
                        ]
                    ],
                ],
                output: "{{slug}}/index.html"
            )
        )
    }
}
