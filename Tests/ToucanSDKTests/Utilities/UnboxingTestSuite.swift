//
//  UnboxingTestSuite.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 05. 09..
//

import Foundation
import Testing
@testable import ToucanModels
@testable import ToucanContent

@Suite
struct UnboxingTests {

    @Test
    func unboxing() throws {
        let value: [String: AnyCodable] = [
            "context": [
                "posts": [
                    [
                        "publication": AnyCodable(
                            Optional(
                                ToucanModels.DateFormats(
                                    date: ToucanModels.DateFormats.Standard(
                                        full: "Tuesday, April 15, 2025",
                                        long: "April 15, 2025",
                                        medium: "Apr 15, 2025",
                                        short: "4/15/25"
                                    ),
                                    time: ToucanModels.DateFormats.Standard(
                                        full: "2:00:00 PM Greenwich Mean Time",
                                        long: "2:00:00 PM GMT",
                                        medium: "2:00:00 PM",
                                        short: "2:00 PM"
                                    ),
                                    timestamp: 1744725600.0,
                                    formats: [
                                        "rss":
                                            "Tue, 15 Apr 2025 14:00:00 +0000",
                                        "sitemap": "2025-04-15",
                                        "iso8601": "2025-04-15T14:00:00.000Z",
                                        "year": "2025",
                                    ]
                                )
                            )
                        ),
                        "description": AnyCodable(
                            "Migration guide for Toucan Beta 3: covering changes to content structure, theme changes and rendering features."
                        ),
                        "featured": AnyCodable(true),
                        "contents": AnyCodable([
                            "readingTime": AnyCodable(2),
                            "outline": AnyCodable([
                                AnyCodable(
                                    Optional(
                                        ToucanContent.Outline(
                                            level: 2,
                                            text: "Changes in contents",
                                            fragment: Optional(
                                                "changes-in-contents"
                                            ),
                                            children: []
                                        )
                                    )
                                ),
                                AnyCodable(
                                    Optional(
                                        ToucanContent.Outline(
                                            level: 2,
                                            text: "Changes in theme",
                                            fragment: Optional(
                                                "changes-in-theme"
                                            ),
                                            children: []
                                        )
                                    )
                                ),
                                AnyCodable(
                                    Optional(
                                        ToucanContent.Outline(
                                            level: 2,
                                            text: "Pipelines",
                                            fragment: Optional("pipelines"),
                                            children: []
                                        )
                                    )
                                ),
                                AnyCodable(
                                    Optional(
                                        ToucanContent.Outline(
                                            level: 2,
                                            text: "Useful links",
                                            fragment: Optional("useful-links"),
                                            children: []
                                        )
                                    )
                                ),
                            ]),
                            "html": AnyCodable("<p></p>"),
                        ]),
                        "authors": AnyCodable([
                            [
                                "contents": AnyCodable([
                                    "outline": AnyCodable([]),
                                    "html": AnyCodable(""),
                                    "readingTime": AnyCodable(1),
                                ]),
                                "permalink": AnyCodable(
                                    "https://toucansites.com/authors/gabor-lengyel/"
                                ),
                                "description": AnyCodable(
                                    "Former Android Developer, co-founder of Binary Birds Kft."
                                ),
                                "slug": AnyCodable(
                                    Optional(
                                        ToucanModels.Slug(
                                            value: "authors/gabor-lengyel"
                                        )
                                    )
                                ),
                                "image": AnyCodable(
                                    "https://toucansites.com/assets/authors/gabor-lengyel/gabor-lengyel.jpg"
                                ),
                                "title": AnyCodable("Gábor Lengyel"),
                                "order": AnyCodable(10),
                                "lastUpdate": AnyCodable(
                                    Optional(
                                        ToucanModels.DateFormats(
                                            date: ToucanModels.DateFormats
                                                .Standard(
                                                    full:
                                                        "Friday, April 18, 2025",
                                                    long: "April 18, 2025",
                                                    medium: "Apr 18, 2025",
                                                    short: "4/18/25"
                                                ),
                                            time: ToucanModels.DateFormats
                                                .Standard(
                                                    full:
                                                        "12:45:44 PM Greenwich Mean Time",
                                                    long: "12:45:44 PM GMT",
                                                    medium: "12:45:44 PM",
                                                    short: "12:45 PM"
                                                ),
                                            timestamp: 1744980344.8431244,
                                            formats: [
                                                "rss":
                                                    "Fri, 18 Apr 2025 12:45:44 +0000",
                                                "sitemap": "2025-04-18",
                                                "iso8601":
                                                    "2025-04-18T12:45:44.843Z",
                                                "year": "2025",
                                            ]
                                        )
                                    )
                                ),
                            ]
                        ]),
                        "image": AnyCodable(nil),
                        "slug": AnyCodable(
                            Optional(
                                ToucanModels.Slug(
                                    value: "beta-3-migration-guide"
                                )
                            )
                        ),
                        "title": AnyCodable("Beta 3 migration guide"),
                        "permalink": AnyCodable(
                            "https://toucansites.com/beta-3-migration-guide/"
                        ),
                    ]
                ]
            ]
        ]

        let encoder = JSONEncoder()
        let result = value.unboxed(encoder)

        let firstAuthorSlugValue = result.value(
            forKeyPath: "context.posts.0.authors.0.slug.value"
        )
        let slug = try #require(firstAuthorSlugValue as? String)
        #expect(slug == "authors/gabor-lengyel")

        let publicationDateFullValue = result.value(
            forKeyPath: "context.posts.0.publication.date.full"
        )
        let publicationDateFull = try #require(
            publicationDateFullValue as? String
        )
        #expect(publicationDateFull == "Tuesday, April 15, 2025")
    }
}
