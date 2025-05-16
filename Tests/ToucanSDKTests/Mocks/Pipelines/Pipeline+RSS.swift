//
//  Pipeline+RSS.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 03. 30..

import ToucanModels

public extension Pipeline.Mocks {

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
}
