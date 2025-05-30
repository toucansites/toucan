//
//  BuildTargetSourcePageLinkTestSuite.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 02. 20..
//
//
//import Foundation
//import Testing
//
//import ToucanMarkdown
//
//import Logging
//@testable import ToucanSDK
//
//@Suite
//struct BuildTargetSourcePageLinkTestSuite {
//
//    @Test
//    func testPageLink() throws {
//        let logger = Logger(label: "BuildTargetSourcePageLinkTestSuite")
//        let target = Target.standard
//        let now = Date()
//
//        let pipelines: [Pipeline] = [
//            .init(
//                id: "html",
//                scopes: [
//                    "*": [
//                        "detail": Pipeline.Scope(
//                            context: Pipeline.Scope.Context(rawValue: 31),
//                            fields: []
//                        ),
//                        "list": Pipeline.Scope(
//                            context: Pipeline.Scope.Context(rawValue: 11),
//                            fields: []
//                        ),
//                        "reference": Pipeline.Scope(
//                            context: Pipeline.Scope.Context(rawValue: 3),
//                            fields: []
//                        ),
//                    ]
//                ],
//                queries: [
//                    "featured": .init(
//                        contentType: "post",
//                        scope: "list"
//                    )
//                ],
//                dataTypes: .defaults,
//                contentTypes: .defaults,
//                iterators: [
//                    "post.pagination": Query(
//                        contentType: "post",
//                        scope: "detail",
//                        limit: 9,
//                        offset: nil,
//                        filter: nil,
//                        orderBy: [
//                            Order(
//                                key: "publication",
//                                direction: ToucanModels.Direction.desc
//                            )
//                        ]
//                    )
//                ],
//                assets: .defaults,
//                transformers: [:],
//                engine: .init(
//                    id: "mustache",
//                    options: [:]
//                ),
//                output: .init(
//                    path: "{{slug}}",
//                    file: "index",
//                    ext: "html"
//                )
//            )
//        ]
//
//        let postContent = Content(
//            id: "post",
//            slug: .init(value: "post"),
//            rawValue: RawContent(
//                origin: Origin(path: "", slug: "post"),
//                frontMatter: [
//                    "publication": .init("2025-01-10 01:02:03")
//                ],
//                markdown: "",
//                lastModificationDate: 1742843632.8373249,
//                assets: []
//            ),
//            definition: ContentDefinition(
//                id: "post",
//                default: false,
//                paths: ["posts"],
//                properties: [:],
//                relations: [:],
//                queries: [:]
//            ),
//            properties: [:],
//            relations: [:],
//            userDefined: [:],
//            iteratorInfo: nil
//        )
//
//        let paginationContent = Content(
//            id: "{{post.pagination}}",
//            slug: .init(value: "posts/page/{{post.pagination}}"),
//            rawValue: RawContent(
//                origin: Origin(
//                    path: "posts/{{post.pagination}}/index.md",
//                    slug: "{{post.pagination}}"
//                ),
//                frontMatter: [
//                    "home": .init("posts/page"),
//                    "title": .init("Posts - {{number}} / {{total}}"),
//                    "slug": .init("posts/page/{{post.pagination}}"),
//                    "description": .init("Posts page - {{number}} / {{total}}"),
//                    "css": .init([]),
//                    "js": .init([]),
//                    "type": .init("page"),
//                    "template": .init("posts"),
//                    "image": nil,
//                ],
//                markdown: "Values in markdown: {{number}} / {{total}}",
//                lastModificationDate: 1742843632.8373249,
//                assets: []
//            ),
//            definition: ContentDefinition(
//                id: "page",
//                default: true,
//                paths: [],
//                properties: [
//                    "title": Property(
//                        propertyType: PropertyType.string,
//                        isRequired: true,
//                        defaultValue: nil
//                    )
//                ],
//                relations: [:],
//                queries: [:]
//            ),
//            properties: ["title": AnyCodable("Posts - {{number}} / {{total}}")],
//            relations: [:],
//            userDefined: [
//                "home": .init("posts/page"),
//                "description": .init("Posts page - {{number}} / {{total}}"),
//                "css": .init([]),
//                "js": .init([]),
//                "template": .init("posts"),
//                "image": nil,
//            ],
//            iteratorInfo: nil
//        )
//
//        let contents: [Content] = [postContent, paginationContent]
//        let templates: [String: String] = [
//            "posts": Templates.Mocks.page()
//        ]
//
//        let config = Config.defaults
//        let sourceConfig = SourceLocations(
//            sourceUrl: .init(fileURLWithPath: ""),
//            config: config
//        )
//
//        let buildTargetSource = BuildTargetSource(
//            location: .init(filePath: ""),
//            target: target,
//            config: config,
//            sourceConfig: sourceConfig,
//            settings: .standard,
//            pipelines: pipelines,
//            contents: contents,
//            blockDirectives: [],
//            templates: templates,
//            baseUrl: "http://localhost:3000"
//        )
//
//        var renderer = BuildTargetSourceRenderer(
//            buildTargetSource: buildTargetSource,
//            fileManager: FileManager.default,
//            logger: logger
//        )
//
//        let results = try renderer.render(now: now)
//
//        #expect(results.count == 1)
//        #expect(results[0].destination.path == "posts/page/1")
//
//        switch results[0].source {
//        case .assetFile(_), .asset(_):
//            #expect(Bool(false))
//        case .content(let value):
//            #expect(value.contains("<title>Posts - 1 / 1 - </title>"))
//            #expect(value.contains("Values in markdown: 1 / 1"))
//        }
//    }
//
//}
