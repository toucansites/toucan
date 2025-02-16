//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 01. 29..
//

// TODO: codable -> decodable, split implementation into files
public struct Config: Codable {

    enum CodingKeys: CodingKey {
        case pipelines
        case contents
        case dateFormats
    }

    public var pipelines: Pipelines
    public var contents: Contents
    public var dateFormats: DateFormats

    public static var defaults: Self {
        .init(
            pipelines: .defaults,
            contents: .defaults,
            dateFormats: .defaults
        )
    }

    public init(
        pipelines: Pipelines,
        contents: Contents,
        dateFormats: DateFormats
    ) {
        self.pipelines = pipelines
        self.contents = contents
        self.dateFormats = dateFormats
    }

    public init(from decoder: any Decoder) throws {
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

// MARK: -

extension Config {

    public struct Location: Codable {
        public var path: String
    }
}

// MARK: -

extension Config {

    public struct Pipelines: Codable {

        enum CodingKeys: CodingKey {
            case path
        }

        public var path: String

        public static var defaults: Self {
            .init(
                path: "pipelines"
            )
        }

        public init(
            path: String
        ) {
            self.path = path
        }

        public init(from decoder: any Decoder) throws {
            let defaults = Self.defaults
            guard
                let container = try? decoder.container(
                    keyedBy: CodingKeys.self
                )
            else {
                self = defaults
                return
            }
            self.path =
                try container.decodeIfPresent(
                    String.self,
                    forKey: .path
                ) ?? defaults.path
        }
    }
}

// MARK: -

extension Config {

    public struct Contents: Codable {

        enum CodingKeys: CodingKey {
            case path
            case assets
        }

        public var path: String
        public var assets: Location

        public init(
            path: String,
            assets: Location
        ) {
            self.path = path
            self.assets = assets
        }

        public static var defaults: Self {
            .init(
                path: "contents",
                assets: .init(
                    path: "assets"
                )
            )
        }

        public init(from decoder: any Decoder) throws {
            let defaults = Self.defaults
            guard
                let container = try? decoder.container(
                    keyedBy: CodingKeys.self
                )
            else {
                self = defaults
                return
            }

            self.path =
                try container.decodeIfPresent(
                    String.self,
                    forKey: .path
                ) ?? defaults.path

            self.assets =
                try container.decodeIfPresent(
                    Location.self,
                    forKey: .assets
                ) ?? defaults.assets
        }
    }
}

// MARK: -

extension Config {

    public struct DateFormats: Codable {

        enum CodingKeys: CodingKey {
            case input
            case output
        }

        public var input: String
        public var output: [String: String]

        public static var defaults: Self {
            .init(
                input: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
                output: [:]
            )
        }

        public init(
            input: String,
            output: [String: String]
        ) {
            self.input = input
            self.output = output
        }

        public init(from decoder: any Decoder) throws {
            let defaults = Self.defaults
            guard
                let container = try? decoder.container(
                    keyedBy: CodingKeys.self
                )
            else {
                self = defaults
                return
            }

            self.input =
                try container.decodeIfPresent(
                    String.self,
                    forKey: .input
                ) ?? defaults.input

            self.output =
                try container.decodeIfPresent(
                    [String: String].self,
                    forKey: .output
                ) ?? defaults.output
        }
    }

}
