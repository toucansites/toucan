//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 02. 20..
//

import Logging
import ToucanModels
import FileManagerKit

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
        public var transformerPipeline: TransformerPipeline?

        public init(
            markdown: Markdown,
            outline: Outline,
            readingTime: ReadingTime,
            transformerPipeline: TransformerPipeline?
        ) {
            self.markdown = markdown
            self.outline = outline
            self.readingTime = readingTime
            self.transformerPipeline = transformerPipeline
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
    public var fileManager: FileManagerKit
    public var logger: Logger

    public init(
        configuration: Configuration,
        fileManager: FileManagerKit,
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

        self.fileManager = fileManager
        self.logger = logger
    }

    public func render(
        content: String,
        slug: String,
        assetsPath: String,
        baseUrl: String
    ) -> Output {
        var finalHtml = content
        var shouldRenderMarkdown = true

        if let transformerPipeline = configuration.transformerPipeline {
            if !transformerPipeline.run.isEmpty {
                shouldRenderMarkdown = transformerPipeline.isMarkdownResult
                let executor = TransformerExecutor(
                    pipeline: transformerPipeline,
                    fileManager: fileManager,
                    logger: logger
                )
                do {
                    finalHtml = try executor.transform(
                        contents: finalHtml,
                        slug: slug
                    )
                }
                catch {
                    logger.error("\(String(describing: error))")
                }
            }
            else {
                logger.warning("Empty transformer pipeline.")
            }
        }

        if shouldRenderMarkdown {
            finalHtml = markdownToHTMLRenderer.renderHTML(
                markdown: content,
                slug: slug,
                assetsPath: assetsPath,
                baseUrl: baseUrl
            )
        }

        let readingTime = readingTimeCalculator.calculate(for: finalHtml)
        let outline = outlineParser.parseHTML(finalHtml)

        return .init(
            html: finalHtml,
            readingTime: readingTime,
            outline: outline
        )
    }
}
