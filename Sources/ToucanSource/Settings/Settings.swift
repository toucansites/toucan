//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 02. 11..
//

import ToucanModels
import ToucanCodable

public struct Settings: Codable {

    enum CodingKeys: CodingKey, CaseIterable {
        case baseUrl
        case name
        case locale
        case timezone
    }

    public var baseUrl: String?
    public var name: String?
    public var locale: String?
    public var timezone: String?
    public var userDefined: [String: AnyCodable]

    public init(
        baseUrl: String,
        name: String?,
        locale: String?,
        timezone: String?,
        userDefined: [String: AnyCodable]
    ) {
        self.baseUrl = baseUrl
        self.name = name
        self.locale = locale
        self.timezone = timezone
        self.userDefined = userDefined
    }

    public static var defaults: Self {
        .init(
            baseUrl: "http://localhost:3000/",
            name: nil,
            locale: nil,
            timezone: nil,
            userDefined: [:]
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
        self.baseUrl =
            try container.decodeIfPresent(
                String.self,
                forKey: .baseUrl
            ) ?? defaults.baseUrl

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

        self.timezone =
            try container.decodeIfPresent(
                String.self,
                forKey: .timezone
            ) ?? defaults.timezone

        var result = try decoder.singleValueContainer()
            .decode([String: AnyCodable].self)
        for key in CodingKeys.allCases {
            result.removeValue(forKey: key.stringValue)
        }
        self.userDefined = result
    }
}
