//
//  RawContent+Guide.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 02. 21..

import Foundation
import ToucanModels

extension RawContent.Mocks {

    static func guides(
        max: Int = 10
    ) -> [RawContent] {
        (1...max)
            .map { i in
                .init(
                    origin: .init(
                        path: "docs/guides/guide-\(i)",
                        slug: "docs/guides/guide-\(i)"
                    ),
                    frontMatter: [
                        "title": "Guide #\(i)",
                        "category": "category-\(i)",
                        "order": .init(i),
                    ],
                    markdown: """
                        # Guide #\(i)

                        Lorem ipsum dolor sit amet
                        """,
                    lastModificationDate: Date().timeIntervalSince1970,
                    assets: []
                )
            }
    }
}
