import Foundation
import Testing
import ToucanModels
import ToucanSource
import ToucanTesting
import Testing
import Logging
@testable import ToucanSDK

@Suite
struct DateFormatterTestSuite {

    @Test
    func locale_DE_Formatter() throws {
        var settings = Settings.defaults
        settings.locale = "de_DE"

        let sourceBundle = SourceBundle(
            location: .init(filePath: ""),
            config: .defaults,
            sourceConfig: SourceConfig(
                sourceUrl: .init(fileURLWithPath: ""),
                config: .defaults
            ),
            settings: settings,
            pipelines: [],
            contents: [],
            blockDirectives: [],
            templates: [:],
            baseUrl: ""
        )

        let date = Date.init(timeIntervalSinceReferenceDate: 0)
        let formatter = sourceBundle.settings.dateFormatter()
        formatter.dateStyle = .full

        #expect(formatter.locale.identifier == "de_DE")
        #expect(formatter.string(from: date) == "Montag, 1. Januar 2001")
    }

    @Test
    func locale_DE_HtmlOutput_DefaultDateFormat() throws {
        let logger = Logger(label: "DateFormatterTestSuite")
        let now = Date()
        let publication = Date.init(timeIntervalSinceReferenceDate: 99_887_766)

        var settings = Settings.defaults
        settings.locale = "de_DE"

        let sourceConfig = SourceConfig(
            sourceUrl: .init(fileURLWithPath: ""),
            config: .defaults
        )

        let inputFormatter = settings.dateFormatter(
            sourceConfig.config.dateFormats.input
        )

        let postDefinition = ContentDefinition(
            id: "post",
            paths: ["blog/posts"],
            properties: [
                "title": .init(
                    type: .string,
                    required: true,
                    default: nil
                ),
                "publication": .init(
                    type: .date(format: nil),
                    required: true,
                    default: nil
                ),
            ],
            relations: [:],
            queries: [:]
        )
        let rawPostContent = RawContent(
            origin: .init(
                path: "blog/posts/post",
                slug: "blog/posts/post"
            ),
            frontMatter: [
                "title": "Post",
                "publication": .init(inputFormatter.string(from: publication)),
            ],
            markdown: """
                # Post

                Lorem ipsum dolor sit amet
                """,
            lastModificationDate: now.timeIntervalSince1970,
            assets: []
        )
        let converter = ContentDefinitionConverter(
            contentDefinition: postDefinition,
            dateFormatter: inputFormatter,
            defaultDateFormat: sourceConfig.config.dateFormats.input.format,
            logger: logger
        )
        let postContent = converter.convert(rawContent: rawPostContent)

        let templates: [String: String] = [
            "post.default": Templates.Mocks.post()
        ]

        let sourceBundle = SourceBundle(
            location: .init(filePath: ""),
            config: sourceConfig.config,
            sourceConfig: sourceConfig,
            settings: settings,
            pipelines: [Pipeline.Mocks.html()],
            contents: [postContent],
            blockDirectives: [],
            templates: templates,
            baseUrl: ""
        )

        var sourceBundleRenderer = SourceBundleRenderer(
            sourceBundle: sourceBundle,
            fileManager: FileManager.default,
            logger: logger
        )

        let results = try sourceBundleRenderer.render(now: now)
        #expect(results.count == 1)
        let first = try #require(results.first)

        let expected = """
            <html>
                <head>
                </head>
                <body>
                    Post<br>
                    Date<br>
                    Dienstag, 2. März 2004<br>
                    Time<br>
                    02:36<br>
                </body>
            </html>
            """
        #expect(first.contents == expected)
    }

    @Test
    func locale_DE_ContextOutput_CustomDateFormat() throws {
        let logger = Logger(label: "DateFormatterTestSuite")
        let now = Date()
        let publication = Date.init(timeIntervalSinceReferenceDate: 99_887_766)

        var settings = Settings.defaults
        settings.locale = "de_DE"

        var config = Config.defaults
        config.dateFormats.output = [
            "my-date-format": .init(format: "y | MM | dd"),
            "my-time-format": .init(
                locale: "hu_HU",
                timeZone: "CET",
                format: "HH | mm | ss"
            ),
        ]

        let sourceConfig = SourceConfig(
            sourceUrl: .init(fileURLWithPath: ""),
            config: config
        )

        let inputFormatter = settings.dateFormatter(config.dateFormats.input)

        let postDefinition = ContentDefinition(
            id: "post",
            paths: ["blog/posts"],
            properties: [
                "title": .init(
                    type: .string,
                    required: true,
                    default: nil
                ),
                "publication": .init(
                    type: .date(format: nil),
                    required: true,
                    default: nil
                ),
            ],
            relations: [:],
            queries: [:]
        )
        let rawPostContent = RawContent(
            origin: .init(
                path: "blog/posts/post",
                slug: "blog/posts/post"
            ),
            frontMatter: [
                "title": "Post",
                "publication": .init(inputFormatter.string(from: publication)),
            ],
            markdown: """
                # Post

                Lorem ipsum dolor sit amet
                """,
            lastModificationDate: now.timeIntervalSince1970,
            assets: []
        )
        let converter = ContentDefinitionConverter(
            contentDefinition: postDefinition,
            dateFormatter: inputFormatter,
            defaultDateFormat: config.dateFormats.input.format,
            logger: logger
        )
        let postContent = converter.convert(rawContent: rawPostContent)

        let templates: [String: String] = [
            "post.default": """
            <html>
                <head>
                </head>
                <body>
                    {{page.title}}
                    Date
                    {{page.publication.formats.my-date-format}}
                    Time
                    {{page.publication.formats.my-time-format}}
                </body>
            </html>
            """
        ]

        let sourceBundle = SourceBundle(
            location: .init(filePath: ""),
            config: config,
            sourceConfig: sourceConfig,
            settings: settings,
            pipelines: [Pipeline.Mocks.html()],
            contents: [postContent],
            blockDirectives: [],
            templates: templates,
            baseUrl: ""
        )

        var sourceBundleRenderer = SourceBundleRenderer(
            sourceBundle: sourceBundle,
            fileManager: FileManager.default,
            logger: logger
        )

        let results = try sourceBundleRenderer.render(now: now)
        #expect(results.count == 1)
        let first = try #require(results.first)

        let expected = """
            <html>
                <head>
                </head>
                <body>
                    Post
                    Date
                    2004 | 03 | 02
                    Time
                    03 | 36 | 06
                </body>
            </html>
            """
        #expect(first.contents == expected)
    }

    @Test
    func locale_DE_ContextOutput_DateFormatOverride() throws {
        let logger = Logger(label: "DateFormatterTestSuite")
        let now = Date()
        let publication = Date.init(timeIntervalSinceReferenceDate: 99_887_766)

        var settings = Settings.defaults
        settings.locale = "de_DE"

        var config = Config.defaults
        config.dateFormats.output = [
            "date.full": .init(format: "y | MM | dd"),
            "time.short": .init(format: "HH | mm | ss"),
        ]

        let sourceConfig = SourceConfig(
            sourceUrl: .init(fileURLWithPath: ""),
            config: config
        )

        let inputFormatter = settings.dateFormatter(config.dateFormats.input)

        let postDefinition = ContentDefinition(
            id: "post",
            paths: ["blog/posts"],
            properties: [
                "title": .init(
                    type: .string,
                    required: true,
                    default: nil
                ),
                "publication": .init(
                    type: .date(format: nil),
                    required: true,
                    default: nil
                ),
            ],
            relations: [:],
            queries: [:]
        )
        let rawPostContent = RawContent(
            origin: .init(
                path: "blog/posts/post",
                slug: "blog/posts/post"
            ),
            frontMatter: [
                "title": "Post",
                "publication": .init(inputFormatter.string(from: publication)),
            ],
            markdown: """
                # Post

                Lorem ipsum dolor sit amet
                """,
            lastModificationDate: now.timeIntervalSince1970,
            assets: []
        )
        let converter = ContentDefinitionConverter(
            contentDefinition: postDefinition,
            dateFormatter: inputFormatter,
            defaultDateFormat: config.dateFormats.input.format,
            logger: logger
        )
        let postContent = converter.convert(rawContent: rawPostContent)

        let templates: [String: String] = [
            "post.default": """
            <html>
                <head>
                </head>
                <body>
                    {{page.title}}
                    Date
                    {{page.publication.date.full}}
                    Time
                    {{page.publication.time.short}}
                </body>
            </html>
            """
        ]

        let sourceBundle = SourceBundle(
            location: .init(filePath: ""),
            config: config,
            sourceConfig: sourceConfig,
            settings: settings,
            pipelines: [Pipeline.Mocks.html()],
            contents: [postContent],
            blockDirectives: [],
            templates: templates,
            baseUrl: ""
        )

        var sourceBundleRenderer = SourceBundleRenderer(
            sourceBundle: sourceBundle,
            fileManager: FileManager.default,
            logger: logger
        )

        let results = try sourceBundleRenderer.render(now: now)
        #expect(results.count == 1)
        let first = try #require(results.first)

        let expected = """
            <html>
                <head>
                </head>
                <body>
                    Post
                    Date
                    2004 | 03 | 02
                    Time
                    02 | 36 | 06
                </body>
            </html>
            """
        #expect(first.contents == expected)
    }
}
