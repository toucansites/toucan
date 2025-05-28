//
//  ToucanDateFormatterTestSuite.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 04. 17..
//

import Foundation
import Testing
import Logging
import ToucanSource
@testable import ToucanSDK

@Suite
struct ToucanDateFormatterTestSuite {

    @Test
    func localizedOutputFormat() throws {

        let config = Config.defaults
        var pipeline = Mocks.Pipelines.html()
        pipeline.dataTypes.date.output = .init(
            locale: "hu-HU",
            timeZone: "CET"
        )

        let dateFormatter = ToucanDateFormatter(
            dateConfig: config.dataTypes.date,
            pipelineDateConfig: pipeline.dataTypes.date
        )

        let date = Date(timeIntervalSinceReferenceDate: 0)
        let ctx = dateFormatter.format(date: date)
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

        let inputDate = dateFormatter.parse(date: "2001-01-01T00:00:00.000Z")
        #expect(inputDate.timeIntervalSinceReferenceDate == 0)

        let localizedInputDate = dateFormatter.parse(
            date: "2001-01-01T01:00:00.000Z",
            using: .init(
                localization: .init(
                    locale: "hu-HU",
                    timeZone: "CET"
                ),
                format: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            )
        )
        #expect(localizedInputDate.timeIntervalSinceReferenceDate == 0)
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
    //        let sourceBundle = BuildTargetSource(
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
    //        var sourceBundleRenderer = SourceBundleRenderer(
    //            sourceBundle: sourceBundle,
    //            fileManager: FileManager.default,
    //            logger: logger
    //        )
    //
    //        let results = try sourceBundleRenderer.render(now: now)
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
    //        let sourceBundle = BuildTargetSource(
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
    //        var sourceBundleRenderer = SourceBundleRenderer(
    //            sourceBundle: sourceBundle,
    //            fileManager: FileManager.default,
    //            logger: logger
    //        )
    //
    //        let results = try sourceBundleRenderer.render(now: now)
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
    //        let sourceBundle = BuildTargetSource(
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
    //        var sourceBundleRenderer = SourceBundleRenderer(
    //            sourceBundle: sourceBundle,
    //            fileManager: FileManager.default,
    //            logger: logger
    //        )
    //
    //        let results = try sourceBundleRenderer.render(now: now)
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
