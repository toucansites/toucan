//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2024. 10. 13..
//

@testable import ToucanSDK

extension ContentType {

    static let post = ContentType(
        id: "post",
        api: nil,
        rss: true,
        location: nil,
        template: "post.default",
        css: nil,
        js: nil,
        pagination: .init(
            bundle: "post.pagination",
            limit: 10,
            sort: "publication",
            order: .asc
        ),
        properties: [
            "featured": .init(
                type: .bool,
                defaultValue: nil
            )
        ],
        relations: [
            "authors": .init(
                references: "author",
                join: .many,
                sort: "title",
                order: .asc,
                limit: nil
            )
        ],
        context: .init(
            site: [
                "posts": .init(
                    sort: "publication",
                    order: .desc,
                    limit: 10,
                    filter: nil
                )
            ],
            local: [
                "moreByAuthors": .init(
                    references: "post",
                    foreignKey: "$same.authors",
                    sort: "publication",
                    order: .desc,
                    limit: 6
                )
            ]
        )
    )

    static let author = ContentType(
        id: "author",
        api: nil,
        rss: false,
        location: nil,
        template: "author.default",
        css: nil,
        js: nil,
        pagination: nil,
        properties: [:],
        relations: [:],
        context: .init(
            site: [
                "authors": .init(
                    sort: "title",
                    order: .asc,
                    limit: 10,
                    filter: nil
                )
            ],
            local: [
                "posts": .init(
                    references: "post",
                    foreignKey: "authors",
                    sort: "publication",
                    order: .desc,
                    limit: nil
                )
            ]
        )
    )
}
