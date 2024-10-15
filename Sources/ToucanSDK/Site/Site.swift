//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2024. 10. 14..
//

import Foundation

struct Site {

    enum Keys {
        static let baseUrl = "baseUrl"
        static let title = "title"
        static let description = "description"
        static let language = "language"
        static let dateFormat = "dateFormat"
        static let noindex = "noindex"
        static let hreflang = "hreflang"

        static let allKeys: [String] = [
            Keys.baseUrl,
            Keys.title,
            Keys.description,
            Keys.language,
            Keys.dateFormat,
            Keys.noindex,
            Keys.hreflang,
        ]
    }

    struct Hreflang: Codable {
        let lang: String
        let url: String
    }

    let baseUrl: String
    let title: String
    let description: String
    let language: String?
    let dateFormat: String
    let noindex: Bool
    let hreflang: [Hreflang]
    let userDefined: [String: Any]

    init(
        baseUrl: String,
        title: String,
        description: String,
        language: String?,
        dateFormat: String,
        noindex: Bool,
        hreflang: [Hreflang],
        userDefined: [String: Any]
    ) {
        self.baseUrl = baseUrl
        self.title = title
        self.description = description
        self.language = language
        self.dateFormat = dateFormat
        self.noindex = noindex
        self.hreflang = hreflang
        self.userDefined = userDefined
    }

    init(_ dict: [String: Any]) {
        self.baseUrl =
            (dict.string(Keys.baseUrl)
            ?? Self.defaults.baseUrl)
            .ensureTrailingSlash()

        self.title =
            dict.string(Keys.title)
            ?? Self.defaults.title

        self.description =
            dict.string(Keys.description)
            ?? Self.defaults.description

        self.language = dict.string(Keys.language)

        self.dateFormat =
            dict.string(Keys.dateFormat)
            ?? Self.defaults.dateFormat

        self.noindex =
            dict.bool(Keys.noindex)
            ?? Self.defaults.noindex

        self.hreflang = dict.array(Keys.hreflang, as: Hreflang.self)
        self.userDefined = dict.filter { !Keys.allKeys.contains($0.key) }
    }
}

extension Site {

    static let `defaults` = Site(
        baseUrl: "http://localhost:3000/",
        title: "",
        description: "",
        language: nil,
        dateFormat: "MMMM dd, yyyy",
        noindex: false,
        hreflang: [],
        userDefined: [:]
    )
}
