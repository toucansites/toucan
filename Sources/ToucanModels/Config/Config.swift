//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 01. 29..
//

import Foundation

public struct Config: Decodable, Equatable {

    enum CodingKeys: CodingKey {
        case pipelines
        case contents
        case themes
        case dateFormats
    }

    public var pipelines: Pipelines
    public var contents: Contents
    public var themes: Themes
    public var dateFormats: DateFormats

    // MARK: - defaults

    public static var defaults: Self {
        .init(
            pipelines: .defaults,
            contents: .defaults,
            themes: .defaults,
            dateFormats: .defaults
        )
    }

    // MARK: - init

    public init(
        pipelines: Pipelines,
        contents: Contents,
        themes: Themes,
        dateFormats: DateFormats
    ) {
        self.pipelines = pipelines
        self.contents = contents
        self.themes = themes
        self.dateFormats = dateFormats
    }

    // MARK: - decoder

    public init(from decoder: any Decoder) throws {
        let defaults = Self.defaults
        let container = try? decoder.container(keyedBy: CodingKeys.self)

        guard let container else {
            self = defaults
            return
        }

        self.pipelines =
            try container.decodeIfPresent(
                Pipelines.self,
                forKey: .pipelines
            ) ?? defaults.pipelines

        self.contents =
            try container.decodeIfPresent(
                Contents.self,
                forKey: .contents
            ) ?? defaults.contents

        self.themes =
            try container.decodeIfPresent(
                Themes.self,
                forKey: .themes
            ) ?? defaults.themes

        self.dateFormats =
            try container.decodeIfPresent(
                DateFormats.self,
                forKey: .dateFormats
            ) ?? defaults.dateFormats
    }
}

//extension Config: Equatable {
//
//    public static func == (lhs: Config, rhs: Config) -> Bool {
//        lhs.pipelines == rhs.pipelines && lhs.contents == rhs.contents
//            && lhs.dateFormats == rhs.dateFormats
//    }
//}

extension Config {

    public func inputDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormats.input

        return formatter
    }
}
