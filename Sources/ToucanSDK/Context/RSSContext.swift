//
//  File.swift
//
//
//  Created by Tibor Bodecs on 14/05/2024.
//

struct RSSContext {

    struct Item {
        let permalink: String
        let title: String
        let description: String
        let publicationDate: String

        let userDefined: [String: Any]

        var context: [String: Any] {
            userDefined.recursivelyMerged(
                with: [
                    "permalink": permalink,
                    "title": title,
                    "description": description,
                    "publicationDate": publicationDate,
                ]
            )
            .sanitized()
        }
    }

    let title: String
    let description: String
    let baseUrl: String
    let language: String?
    let lastBuildDate: String
    let publicationDate: String
    let items: [Item]
    let userDefined: [String: Any]

    var context: [String: Any] {
        userDefined.recursivelyMerged(
            with: [
                "title": title,
                "description": description,
                "baseUrl": baseUrl,
                "language": language as Any,
                "lastBuildDate": lastBuildDate,
                "publicationDate": publicationDate,
                "items": items.map(\.context),
            ]
        )
        .sanitized()
    }
}
