//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 02. 20..
//

import Logging

// TODO: transformers
public struct ContentRenderer {

    // MARK: - config

    public struct Configuration {

        public struct Markdown {

            public var customBlockDirectives: [MarkdownBlockDirective]

            public init(
                customBlockDirectives: [MarkdownBlockDirective]
            ) {
                self.customBlockDirectives = customBlockDirectives
            }
        }

        public struct Outline {

            public var levels: [Int]

            public init(
                levels: [Int]
            ) {
                self.levels = levels
            }
        }

        public struct ReadingTime {

            public var wordsPerMinute: Int

            public init(
                wordsPerMinute: Int
            ) {
                self.wordsPerMinute = wordsPerMinute
            }
        }

        public var markdown: Markdown
        public var outline: Outline
        public var readingTime: ReadingTime

        public init(
            markdown: Markdown,
            outline: Outline,
            readingTime: ReadingTime
        ) {
            self.markdown = markdown
            self.outline = outline
            self.readingTime = readingTime
        }
    }

    // MARK: - output

    public struct Output {
        public var html: String
        public var readingTime: Int
        public var outline: [Outline]
    }

    public var configuration: Configuration
    public var markdownToHTMLRenderer: MarkdownToHTMLRenderer
    public var outlineParser: OutlineParser
    public var readingTimeCalculator: ReadingTimeCalculator
    public var logger: Logger

    public init(
        configuration: Configuration,
        logger: Logger = .init(label: "ContentRenderer")
    ) {
        self.configuration = configuration

        self.markdownToHTMLRenderer = MarkdownToHTMLRenderer(
            customBlockDirectives: configuration.markdown.customBlockDirectives,
            logger: logger
        )

        self.outlineParser = OutlineParser(
            levels: configuration.outline.levels,
            logger: logger
        )

        self.readingTimeCalculator = ReadingTimeCalculator(
            wordsPerMinute: configuration.readingTime.wordsPerMinute,
            logger: logger
        )

        self.logger = logger
        
    }

    public func render(
        content: String,
        slug: String,
        assetsPath: String,
        baseUrl: String
    ) -> Output {
        let html = markdownToHTMLRenderer.renderHTML(
            markdown: content,
            slug: slug,
            assetsPath: assetsPath,
            baseUrl: baseUrl)
        let readingTime = readingTimeCalculator.calculate(for: html)
        let outline = outlineParser.parseHTML(html)

        return .init(
            html: html,
            readingTime: readingTime,
            outline: outline
        )
    }
}
