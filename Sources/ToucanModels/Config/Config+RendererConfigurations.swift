//
//  RendererConfig.swift
//  Toucan
//
//  Created by gerp83 on 2025. 03. 28..
//

extension Config {

    public struct RendererConfig: Codable, Equatable {

        enum CodingKeys: CodingKey {
            case wordsPerMinute
            case outlineLevels
            case paragraphStyles
        }

        public var wordsPerMinute: Int
        public var outlineLevels: [Int]
        public var paragraphStyles: ParagraphStyles

        // MARK: - defaults

        public static var defaults: Self {
            .init(
                wordsPerMinute: 238,
                outlineLevels: [2, 3],
                paragraphStyles: .defaults
            )
        }

        // MARK: - init

        public init(
            wordsPerMinute: Int,
            outlineLevels: [Int],
            paragraphStyles: ParagraphStyles
        ) {
            self.wordsPerMinute = wordsPerMinute
            self.outlineLevels = outlineLevels
            self.paragraphStyles = paragraphStyles
        }

        // MARK: - decoder

        public init(
            from decoder: any Decoder
        ) throws {
            let defaults = Self.defaults
            guard
                let container = try? decoder.container(
                    keyedBy: CodingKeys.self
                )
            else {
                self = defaults
                return
            }

            self.wordsPerMinute =
                try container.decodeIfPresent(
                    Int.self,
                    forKey: .wordsPerMinute
                ) ?? defaults.wordsPerMinute

            self.outlineLevels =
                try container.decodeIfPresent(
                    [Int].self,
                    forKey: .outlineLevels
                ) ?? defaults.outlineLevels

            self.paragraphStyles =
                try container.decodeIfPresent(
                    ParagraphStyles.self,
                    forKey: .paragraphStyles
                ) ?? defaults.paragraphStyles
        }
    }
}
