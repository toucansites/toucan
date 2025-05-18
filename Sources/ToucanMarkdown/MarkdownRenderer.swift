//
//  MarkdownRenderer.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 02. 20..
//

import Logging

import FileManagerKit

/// A comprehensive content processing engine that renders Markdown content to HTML,
/// applies transformations, computes reading time, and generates an outline structure.
public struct MarkdownRenderer {

    // MARK: - Configuration

    /// Holds all the settings required for rendering and processing content.
    public struct Configuration {

        /// Configuration specific to Markdown processing.
        public struct Markdown {
            /// Custom block directives to extend the Markdown grammar.
            public var customBlockDirectives: [MarkdownBlockDirective]

            /// Initializes a Markdown configuration.
            public init(
                customBlockDirectives: [MarkdownBlockDirective]
            ) {
                self.customBlockDirectives = customBlockDirectives
            }
        }

        /// Configuration for outlining logic, such as which heading levels to parse.
        public struct Outline {
            /// Which heading levels to include in the parsed outline.
            public var levels: [Int]

            /// Initializes an Outline configuration.
            public init(
                levels: [Int]
            ) {
                self.levels = levels
            }
        }

        /// Configuration for estimating reading time.
        public struct ReadingTime {
            /// Estimated words per minute reading speed.
            public var wordsPerMinute: Int

            /// Initializes a ReadingTime configuration.
            public init(
                wordsPerMinute: Int
            ) {
                self.wordsPerMinute = wordsPerMinute
            }
        }

        /// Markdown-specific rendering options.
        public var markdown: Markdown

        /// Outline-parsing preferences.
        public var outline: Outline

        /// Reading time calculation preferences.
        public var readingTime: ReadingTime

        /// Optional transformation pipeline to apply pre-processing on the input.
        public var transformerPipeline: TransformerPipeline?

        /// Paragraph styles for customizing the HTML rendering.
        public var paragraphStyles: [String: [String]]

        /// Initializes a new rendering configuration.
        ///
        /// - Parameters:
        ///   - markdown: Markdown rendering configuration.
        ///   - outline: Outline extraction preferences.
        ///   - readingTime: Reading time estimation settings.
        ///   - transformerPipeline: Optional content transformation pipeline.
        ///   - paragraphStyles: Block-level style customization for HTML rendering.
        public init(
            markdown: Markdown,
            outline: Outline,
            readingTime: ReadingTime,
            transformerPipeline: TransformerPipeline?,
            paragraphStyles: [String: [String]]
        ) {
            self.markdown = markdown
            self.outline = outline
            self.readingTime = readingTime
            self.transformerPipeline = transformerPipeline
            self.paragraphStyles = paragraphStyles
        }
    }

    // MARK: - Output

    /// Final output of the rendering pipeline.
    public struct Output {
        /// The fully rendered HTML output.
        public var html: String

        /// Estimated reading time in minutes.
        public var readingTime: Int

        ///  A hierarchical structure representing the document's headings.
        public var outline: [Outline]
    }

    // MARK: - Properties

    /// Configuration for rendering, including markdown styles, outline levels, and transformation settings.
    public var configuration: Configuration

    /// Responsible for converting Markdown into HTML with support for custom directives and styling.
    public var markdownToHTMLRenderer: MarkdownToHTMLRenderer

    /// Parses the rendered HTML to build a heading outline (used for TOC or navigation).
    public var outlineParser: OutlineParser

    /// Calculates the estimated reading time for a given HTML or Markdown document.
    public var readingTimeCalculator: ReadingTimeCalculator

    /// Interface for file system operations (used by the transformer pipeline).
    public var fileManager: FileManagerKit

    /// Logger for diagnostics and error reporting during rendering.
    public var logger: Logger

    // MARK: - Initialization

    /// Creates a new `ContentRenderer` instance with the provided configuration, file manager, and logger.
    ///
    /// - Parameters:
    ///   - configuration: Rendering configuration including markdown, outline, and reading time options.
    ///   - fileManager: File management utility for use with transformation pipelines.
    ///   - logger: Optional logger for tracking events and issues.
    public init(
        configuration: Configuration,
        fileManager: FileManagerKit,
        logger: Logger = .init(label: "ContentRenderer")
    ) {
        self.configuration = configuration

        self.markdownToHTMLRenderer = MarkdownToHTMLRenderer(
            customBlockDirectives: configuration.markdown.customBlockDirectives,
            paragraphStyles: configuration.paragraphStyles,
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

    // MARK: - Rendering

    /// Processes the input Markdown content, optionally transforms it, renders it as HTML,
    /// calculates reading time, and generates an outline.
    ///
    /// - Parameters:
    ///   - content: The raw Markdown content to process.
    ///   - slug: A unique identifier used for transformation and rendering context.
    ///   - assetsPath: Path to associated assets (e.g., images or includes).
    ///   - baseUrl: The base URL for resolving relative paths or links.
    ///
    /// - Returns: A structured `Output` containing HTML, reading time, and outline.
    public func render(
        content: String,
        slug: String,
        assetsPath: String,
        baseUrl: String
    ) -> Output {
        var finalHtml = content
        var shouldRenderMarkdown = true

        // Step 1: Run transformer pipeline, if defined and non-empty.
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

        // Step 2: If the transformer output isn't already HTML, render Markdown to HTML.
        if shouldRenderMarkdown {
            finalHtml = markdownToHTMLRenderer.renderHTML(
                markdown: content,
                slug: slug,
                assetsPath: assetsPath,
                baseUrl: baseUrl
            )
        }

        // Step 3: Calculate reading time and parse outline from HTML.
        let readingTime = readingTimeCalculator.calculate(for: finalHtml)
        let outline = outlineParser.parseHTML(finalHtml)

        return .init(
            html: finalHtml,
            readingTime: readingTime,
            outline: outline
        )
    }
}
