//
//  Config+RendererConfig.swift
//  Toucan
//
//  Created by gerp83 on 2025. 03. 28..
//

public extension Config {
    /// Defines default configurations used when rendering content,
    /// including reading time settings, outline parsing depth, and
    /// paragraph styling rules for directive blocks.
    struct RendererConfig: Codable, Equatable {
        // MARK: - Nested Types

        // MARK: - Coding Keys

        private enum CodingKeys: CodingKey {
            case wordsPerMinute
            case outlineLevels
            case paragraphStyles
        }

        // MARK: - Static Computed Properties

        // MARK: - Defaults

        /// Returns a `ContentConfigurations` instance with sensible default values.
        public static var defaults: Self {
            .init(
                wordsPerMinute: 238,
                outlineLevels: [2, 3],
                paragraphStyles: .defaults
            )
        }

        // MARK: - Properties

        /// The average reading speed used to estimate reading time (words per minute).
        ///
        /// Common default is 238 wpm, based on tested averages for fluent readers.
        public var wordsPerMinute: Int

        /// The heading levels to extract for outlines (e.g., `[2, 3]` means `##` and `###` in Markdown).
        ///
        /// These levels are used when generating tables of contents or section overviews.
        public var outlineLevels: [Int]

        /// Aliases for styled paragraph blocks (e.g., "note", "tip", "error").
        public var paragraphStyles: ParagraphStyles

        // MARK: - Lifecycle

        // MARK: - Initialization

        /// Initializes a custom `ContentConfigurations` instance.
        ///
        /// - Parameters:
        ///   - wordsPerMinute: The average reading speed for estimating read time.
        ///   - outlineLevels: Heading levels to extract for outline/toc generation.
        ///   - paragraphStyles: Mappings for styled block directives.
        public init(
            wordsPerMinute: Int,
            outlineLevels: [Int],
            paragraphStyles: ParagraphStyles
        ) {
            self.wordsPerMinute = wordsPerMinute
            self.outlineLevels = outlineLevels
            self.paragraphStyles = paragraphStyles
        }

        // MARK: - Decoding

        /// Decodes a `ContentConfigurations` instance, applying defaults for missing fields.
        ///
        /// Gracefully falls back to `.defaults` if the decoding container is missing or incomplete.
        public init(
            from decoder: any Decoder
        ) throws {
            let defaults = Self.defaults

            guard
                let container = try? decoder.container(keyedBy: CodingKeys.self)
            else {
                self = defaults
                return
            }

            self.wordsPerMinute =
                try container.decodeIfPresent(Int.self, forKey: .wordsPerMinute)
                ?? defaults.wordsPerMinute

            self.outlineLevels =
                try container.decodeIfPresent(
                    [Int].self,
                    forKey: .outlineLevels
                )
                ?? defaults.outlineLevels

            self.paragraphStyles =
                try container.decodeIfPresent(
                    ParagraphStyles.self,
                    forKey: .paragraphStyles
                )
                ?? defaults.paragraphStyles
        }
    }
}
