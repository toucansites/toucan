//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 02. 21..
//

//
//  File.swift
//  toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 02. 20..
//

import Foundation
import Testing
import ToucanModels
import ToucanTesting
@testable import ToucanSource

@Suite
struct SourceBundleScopeTestSuite {

    @Test
    func testScopes() throws {
        let now = Date()
        let formatter = DateFormatter()
        formatter.locale = .init(identifier: "en_US")
        formatter.timeZone = .init(secondsFromGMT: 0)

        //        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        //        let nowString = formatter.string(from: now)

        let pipelines: [Pipeline] = [
            .init(
                scopes: [
                    "post": [
                        "minimal": .init(
                            context: .properties,
                            fields: [
                                "slug"
                            ]
                        )
                    ]
                ],
                queries: [
                    "featured": .init(
                        contentType: "post",
                        scope: "minimal"
                    )
                ],
                dataTypes: .defaults,
                contentTypes: .init(
                    include: [],
                    exclude: [],
                    lastUpdate: []
                ),
                iterators: [:],
                transformers: [:],
                engine: .init(
                    id: "json",
                    options: [:]
                ),
                output: .init(
                    path: "",
                    file: "context",
                    ext: "json"
                )
            )
        ]

        // posts
        let postDefinition = ContentDefinition.Mocks.post()
        let rawPostContents = RawContent.Mocks.posts(
            max: 1,
            now: now,
            formatter: formatter
        )
        let postContents = rawPostContents.map {
            postDefinition.convert(
                rawContent: $0,
                definition: postDefinition,
                using: formatter
            )
        }
        // pages
        let pageDefinition = ContentDefinition.Mocks.page()
        let rawPageContents: [RawContent] = [
            .init(
                origin: .init(
                    path: "",
                    slug: ""
                ),
                frontMatter: [
                    "title": "Home",
                    "description": "Home description",
                    "foo": ["bar": "baz"],
                ],
                markdown: """
                    # Home

                    Lorem ipsum dolor sit amet
                    """,
                lastModificationDate: Date().timeIntervalSince1970,
                assets: []
            )
        ]
        let pageContents = rawPageContents.map {
            pageDefinition.convert(
                rawContent: $0,
                definition: pageDefinition,
                using: formatter
            )
        }

        let contentBundles: [ContentBundle] = [
            .init(definition: postDefinition, contents: postContents),
            .init(definition: pageDefinition, contents: pageContents),
        ]

        let sourceBundle = SourceBundle(
            location: .init(filePath: ""),
            config: .defaults,
            settings: .defaults,
            pipelines: pipelines,
            contentBundles: contentBundles
        )

        let results = try sourceBundle.generatePipelineResults(
            templates: [:]
        )

        #expect(results.count == 2)

        print(results[0].contents)
        print(results[1].contents)

        let decoder = JSONDecoder()

        struct Exp0: Decodable {
            struct Item: Decodable {
                let isCurrentURL: Bool
            }
            struct Post: Decodable {
                let isCurrentURL: Bool
            }
            let post: Post
            let featured: [Item]
        }

        let data0 = try #require(results[0].contents.data(using: .utf8))
        let exp0 = try decoder.decode(Exp0.self, from: data0)

        struct Exp1: Decodable {
            struct Item: Decodable {
                let isCurrentURL: Bool
            }
            struct Page: Decodable {
                let isCurrentURL: Bool
            }
            let page: Page
            let featured: [Item]
        }

        let data1 = try #require(results[1].contents.data(using: .utf8))
        let exp1 = try decoder.decode(Exp1.self, from: data1)

    }

}
