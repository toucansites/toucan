//
//  Pipeline+Redirect.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 03. 11..

import ToucanModels
import ToucanSource

public extension Pipeline.Mocks {

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
}
