//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 01. 29..
//


public struct Config: Decodable {

    enum CodingKeys: CodingKey {
        case pipelines
        case contents
        case dateFormats
    }

    public var pipelines: Pipelines
    public var contents: Contents
    public var dateFormats: DateFormats

    // MARK: - defaults

    public static var defaults: Self {
        .init(
            pipelines: .defaults,
            contents: .defaults,
            dateFormats: .defaults
        )
    }

    // MARK: - init
    
    public init(
        pipelines: Pipelines,
        contents: Contents,
        dateFormats: DateFormats
    ) {
        self.pipelines = pipelines
        self.contents = contents
        self.dateFormats = dateFormats
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

        self.dateFormats =
            try container.decodeIfPresent(
                DateFormats.self,
                forKey: .dateFormats
            ) ?? defaults.dateFormats
    }
}
