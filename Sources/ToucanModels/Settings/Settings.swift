//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 02. 11..
//

public struct Settings: Decodable, Equatable {

    enum CodingKeys: CodingKey, CaseIterable {
        case baseUrl
        case name
        case locale
        case timeZone
    }

    public var baseUrl: String
    public var name: String
    public var locale: String
    public var timeZone: String
    public var userDefined: [String: AnyCodable]

    // MARK: - defaults

    public static var defaults: Self {
        .init(
            baseUrl: "http://localhost:3000",
            name: "localhost",
            locale: "en_US",
            timeZone: "UTC",
            userDefined: [:]
        )
    }

    // MARK: - init

    public init(
        baseUrl: String,
        name: String,
        locale: String,
        timeZone: String,
        userDefined: [String: AnyCodable]
    ) {
        self.baseUrl = baseUrl.dropTrailingSlash()
        self.name = name
        self.locale = locale
        self.timeZone = timeZone
        self.userDefined = userDefined
    }

    // MARK: - decoding

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

        self.baseUrl =
            try container.decodeIfPresent(
                String.self,
                forKey: .baseUrl
            )?
            .dropTrailingSlash() ?? defaults.baseUrl.dropTrailingSlash()

        self.name =
            try container.decodeIfPresent(
                String.self,
                forKey: .name
            ) ?? defaults.name

        self.locale =
            try container.decodeIfPresent(
                String.self,
                forKey: .locale
            ) ?? defaults.locale

        self.timeZone =
            try container.decodeIfPresent(
                String.self,
                forKey: .timeZone
            ) ?? defaults.timeZone

        var result = try decoder.singleValueContainer()
            .decode([String: AnyCodable].self)
        for key in CodingKeys.allCases {
            result.removeValue(forKey: key.stringValue)
        }
        self.userDefined = result
    }
}
