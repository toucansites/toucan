//
//  ToucanDateFormatterTestSuite.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 04. 17..
//

import Foundation
import Logging
import Testing
@testable import ToucanSDK
import ToucanSource

@Suite
struct ToucanDateFormatterTestSuite {
    @Test
    func input() throws {
        let config = Config.defaults

        let dateFormatter = ToucanInputDateFormatter(
            dateConfig: config.dataTypes.date,
        )

        let dateString = "2001-01-01T00:00:00.000Z"

        let inputDate = try #require(
            dateFormatter.date(from: dateString)
        )
        #expect(inputDate.timeIntervalSinceReferenceDate == 0)

        let localizedInputDate = try #require(
            dateFormatter.date(
                from: dateString,
                using: .init(
                    localization: .init(
                        locale: "hu-HU",
                        timeZone: "CET"
                    ),
                    format: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                )
            )
        )
        #expect(localizedInputDate.timeIntervalSinceReferenceDate == -3600)
    }

    @Test
    func output() throws {
        let config = Config.defaults
        var pipeline = Mocks.Pipelines.html()
        pipeline.dataTypes.date.output = .init(
            locale: "hu-HU",
            timeZone: "CET"
        )

        let dateFormatter = ToucanOutputDateFormatter(
            dateConfig: config.dataTypes.date,
            pipelineDateConfig: pipeline.dataTypes.date
        )

        let date = Date(timeIntervalSinceReferenceDate: 0)
        let ctx = dateFormatter.format(date)
        dump(ctx)

        #expect(ctx.date.full == "2001. január 1., hétfő")
        #expect(ctx.date.long == "2001. január 1.")
        #expect(ctx.date.medium == "2001. jan. 1.")
        #expect(ctx.date.short == "2001. 01. 01.")

        #expect(ctx.time.full == "1:00:00 közép-európai téli idő")
        #expect(ctx.time.long == "1:00:00 CET")
        #expect(ctx.time.medium == "1:00:00")
        #expect(ctx.time.short == "1:00")

        #expect(ctx.timestamp == 978_307_200)
        #expect(ctx.iso8601 == "2001-01-01T01:00:00.000Z")

        #expect(ctx.formats["rss"] == "Mon, 01 Jan 2001 00:00:00 +0000")
        #expect(ctx.formats["year"] == "2001")
        #expect(ctx.formats["sitemap"] == "2001-01-01")
    }

    //    @Test
    //    func locale_DE_HtmlOutput_DefaultDateFormat() throws {
    //        let logger = Logger(label: "DateFormatterTestSuite")
    //        let now = Date()
    //        let publication = Date.init(timeIntervalSinceReferenceDate: 99_887_766)
    //
    //        var target = Target.standard
    //        target.locale = "de-DE"
    //
    //        let sourceConfig = SourceLocations(
    //            sourceUrl: .init(fileURLWithPath: ""),
    //            config: .defaults
    //        )
    //
    //        let inputFormatter = target.dateFormatter(
    //            sourceConfig.config.dateFormats.input
    //        )
    //
    //        let postDefinition = ContentDefinition(
    //            id: "post",
    //            paths: ["blog/posts"],
    //            properties: [
    //                "title": .init(
    //                    propertyType: .string,
    //                    isRequired: true,
    //                    defaultValue: nil
    //                ),
    //                "publication": .init(
    //                    propertyType: .date(format: nil),
    //                    isRequired: true,
    //                    defaultValue: nil
    //                ),
    //            ],
    //            relations: [:],
    //            queries: [:]
    //        )
    //        let rawPostContent = RawContent(
    //            origin: .init(
    //                path: "blog/posts/post",
    //                slug: "blog/posts/post"
    //            ),
    //            frontMatter: [
    //                "title": "Post",
    //                "publication": .init(inputFormatter.string(from: publication)),
    //            ],
    //            markdown: """
    //                # Post
    //
    //                Lorem ipsum dolor sit amet
    //                """,
    //            lastModificationDate: now.timeIntervalSince1970,
    //            assets: []
    //        )
    //        let converter = ContentDefinitionConverter(
    //            contentDefinition: postDefinition,
    //            dateFormatter: inputFormatter,
    //            logger: logger
    //        )
    //        let postContent = converter.convert(rawContent: rawPostContent)
    //
    //        let templates: [String: String] = [
    //            "post.default": Templates.Mocks.post()
    //        ]
    //
    //        let buildTargetSource = BuildTargetSource(
    //            location: .init(filePath: ""),
    //            target: target,
    //            config: sourceConfig.config,
    //            sourceConfig: sourceConfig,
    //            settings: .standard,
    //            pipelines: [Pipeline.Mocks.html()],
    //            contents: [postContent],
    //            blockDirectives: [],
    //            templates: templates,
    //            baseUrl: ""
    //        )
    //
    //        var buildTargetSourceRenderer = BuildTargetSourceRenderer(
    //            buildTargetSource: buildTargetSource,
    //            fileManager: FileManager.default,
    //            logger: logger
    //        )
    //
    //        let results = try buildTargetSourceRenderer.render(now: now)
    //        #expect(results.count == 1)
    //
    //        let expectation = """
    //            <html>
    //                <head>
    //                </head>
    //                <body>
    //                    Post<br>
    //                    Date<br>
    //                    Dienstag, 2. März 2004<br>
    //                    Time<br>
    //                    02:36<br>
    //                </body>
    //            </html>
    //            """
    //
    //        switch results[0].source {
    //        case .assetFile(_), .asset(_):
    //            #expect(Bool(false))
    //        case .content(let value):
    //            #expect(value == expectation)
    //        }
    //    }
    //
    //    @Test
    //    func locale_DE_ContextOutput_CustomDateFormat() throws {
    //        let logger = Logger(label: "DateFormatterTestSuite")
    //        let now = Date()
    //        let publication = Date.init(timeIntervalSinceReferenceDate: 99_887_766)
    //
    //        var target = Target.standard
    //        target.locale = "de-DE"
    //
    //        var config = Config.defaults
    //        config.dateFormats.output = [
    //            "my-date-format": .init(format: "y | MM | dd"),
    //            "my-time-format": .init(
    //                locale: "hu-HU",
    //                timeZone: "CET",
    //                format: "HH | mm | ss"
    //            ),
    //        ]
    //
    //        let sourceConfig = SourceLocations(
    //            sourceUrl: .init(fileURLWithPath: ""),
    //            config: config
    //        )
    //
    //        let inputFormatter = target.dateFormatter(config.dateFormats.input)
    //
    //        let postDefinition = ContentDefinition(
    //            id: "post",
    //            paths: ["blog/posts"],
    //            properties: [
    //                "title": .init(
    //                    propertyType: .string,
    //                    isRequired: true,
    //                    defaultValue: nil
    //                ),
    //                "publication": .init(
    //                    propertyType: .date(format: nil),
    //                    isRequired: true,
    //                    defaultValue: nil
    //                ),
    //            ],
    //            relations: [:],
    //            queries: [:]
    //        )
    //        let rawPostContent = RawContent(
    //            origin: .init(
    //                path: "blog/posts/post",
    //                slug: "blog/posts/post"
    //            ),
    //            frontMatter: [
    //                "title": "Post",
    //                "publication": .init(inputFormatter.string(from: publication)),
    //            ],
    //            markdown: """
    //                # Post
    //
    //                Lorem ipsum dolor sit amet
    //                """,
    //            lastModificationDate: now.timeIntervalSince1970,
    //            assets: []
    //        )
    //        let converter = ContentDefinitionConverter(
    //            contentDefinition: postDefinition,
    //            dateFormatter: inputFormatter,
    //            logger: logger
    //        )
    //        let postContent = converter.convert(rawContent: rawPostContent)
    //
    //        let templates: [String: String] = [
    //            "post.default": """
    //            <html>
    //                <head>
    //                </head>
    //                <body>
    //                    {{page.title}}
    //                    Date
    //                    {{page.publication.formats.my-date-format}}
    //                    Time
    //                    {{page.publication.formats.my-time-format}}
    //                </body>
    //            </html>
    //            """
    //        ]
    //
    //        let buildTargetSource = BuildTargetSource(
    //            location: .init(filePath: ""),
    //            target: target,
    //            config: config,
    //            sourceConfig: sourceConfig,
    //            settings: .standard,
    //            pipelines: [Pipeline.Mocks.html()],
    //            contents: [postContent],
    //            blockDirectives: [],
    //            templates: templates,
    //            baseUrl: ""
    //        )
    //
    //        var buildTargetSourceRenderer = BuildTargetSourceRenderer(
    //            buildTargetSource: buildTargetSource,
    //            fileManager: FileManager.default,
    //            logger: logger
    //        )
    //
    //        let results = try buildTargetSourceRenderer.render(now: now)
    //        #expect(results.count == 1)
    //
    //        let expectation = """
    //            <html>
    //                <head>
    //                </head>
    //                <body>
    //                    Post
    //                    Date
    //                    2004 | 03 | 02
    //                    Time
    //                    03 | 36 | 06
    //                </body>
    //            </html>
    //            """
    //        switch results[0].source {
    //        case .assetFile(_), .asset(_):
    //            #expect(Bool(false))
    //        case .content(let value):
    //            #expect(value == expectation)
    //        }
    //    }
    //
    //    @Test
    //    func locale_DE_ContextOutput_DateFormatOverride() throws {
    //        let logger = Logger(label: "DateFormatterTestSuite")
    //        let now = Date()
    //        let publication = Date.init(timeIntervalSinceReferenceDate: 99_887_766)
    //
    //        var target = Target.standard
    //        target.locale = "de-DE"
    //
    //        var config = Config.defaults
    //        config.dateFormats.output = [
    //            "date.full": .init(format: "y | MM | dd"),
    //            "time.short": .init(format: "HH | mm | ss"),
    //        ]
    //
    //        let sourceConfig = SourceLocations(
    //            sourceUrl: .init(fileURLWithPath: ""),
    //            config: config
    //        )
    //
    //        let inputFormatter = target.dateFormatter(config.dateFormats.input)
    //
    //        let postDefinition = ContentDefinition(
    //            id: "post",
    //            paths: ["blog/posts"],
    //            properties: [
    //                "title": .init(
    //                    propertyType: .string,
    //                    isRequired: true,
    //                    defaultValue: nil
    //                ),
    //                "publication": .init(
    //                    propertyType: .date(format: nil),
    //                    isRequired: true,
    //                    defaultValue: nil
    //                ),
    //            ],
    //            relations: [:],
    //            queries: [:]
    //        )
    //        let rawPostContent = RawContent(
    //            origin: .init(
    //                path: "blog/posts/post",
    //                slug: "blog/posts/post"
    //            ),
    //            frontMatter: [
    //                "title": "Post",
    //                "publication": .init(inputFormatter.string(from: publication)),
    //            ],
    //            markdown: """
    //                # Post
    //
    //                Lorem ipsum dolor sit amet
    //                """,
    //            lastModificationDate: now.timeIntervalSince1970,
    //            assets: []
    //        )
    //        let converter = ContentDefinitionConverter(
    //            contentDefinition: postDefinition,
    //            dateFormatter: inputFormatter,
    //            logger: logger
    //        )
    //        let postContent = converter.convert(rawContent: rawPostContent)
    //
    //        let templates: [String: String] = [
    //            "post.default": """
    //            <html>
    //                <head>
    //                </head>
    //                <body>
    //                    {{page.title}}
    //                    Date
    //                    {{page.publication.date.full}}
    //                    Time
    //                    {{page.publication.time.short}}
    //                </body>
    //            </html>
    //            """
    //        ]
    //
    //        let buildTargetSource = BuildTargetSource(
    //            location: .init(filePath: ""),
    //            target: target,
    //            config: config,
    //            sourceConfig: sourceConfig,
    //            settings: .standard,
    //            pipelines: [Pipeline.Mocks.html()],
    //            contents: [postContent],
    //            blockDirectives: [],
    //            templates: templates,
    //            baseUrl: ""
    //        )
    //
    //        var buildTargetSourceRenderer = BuildTargetSourceRenderer(
    //            buildTargetSource: buildTargetSource,
    //            fileManager: FileManager.default,
    //            logger: logger
    //        )
    //
    //        let results = try buildTargetSourceRenderer.render(now: now)
    //        #expect(results.count == 1)
    //
    //        let expectation = """
    //            <html>
    //                <head>
    //                </head>
    //                <body>
    //                    Post
    //                    Date
    //                    2004 | 03 | 02
    //                    Time
    //                    02 | 36 | 06
    //                </body>
    //            </html>
    //            """
    //        switch results[0].source {
    //        case .assetFile(_), .asset(_):
    //            #expect(Bool(false))
    //        case .content(let value):
    //            #expect(value == expectation)
    //        }
    //    }
}
