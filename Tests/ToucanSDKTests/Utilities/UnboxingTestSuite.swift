//
//  UnboxingTestSuite.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 05. 09..
//
//

import Foundation
import Testing
import ToucanSource
import ToucanSDK
import ToucanMarkdown

@Suite
struct UnboxingTests {

    @Test
    func unboxing() throws {
        let value: [String: AnyCodable] = [
            RootContextKeys.context.rawValue: [
                "posts": [
                    [
                        "publication": AnyCodable(
                            Optional(
                                DateContext(
                                    date: .init(
                                        full: "Tuesday, April 15, 2025",
                                        long: "April 15, 2025",
                                        medium: "Apr 15, 2025",
                                        short: "4/15/25"
                                    ),
                                    time: .init(
                                        full: "2:00:00 PM Greenwich Mean Time",
                                        long: "2:00:00 PM GMT",
                                        medium: "2:00:00 PM",
                                        short: "2:00 PM"
                                    ),
                                    timestamp: 1744725600.0,
                                    iso8601: "2025-04-15T14:00:00.000Z",
                                    formats: [
                                        "rss":
                                            "Tue, 15 Apr 2025 14:00:00 +0000",
                                        "sitemap": "2025-04-15",
                                        "year": "2025",
                                    ]
                                )
                            )
                        ),
                        "description": AnyCodable(
                            "Migration guide for Toucan Beta 3: covering changes to content structure, template changes and rendering features."
                        ),
                        "featured": AnyCodable(true),
                        PageContextKeys.contents.rawValue: AnyCodable([
                            PageContentsKeys.readingTime.rawValue: AnyCodable(
                                2
                            ),
                            PageContentsKeys.outline.rawValue: AnyCodable([
                                AnyCodable(
                                    Optional(
                                        Outline(
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
                                        Outline(
                                            level: 2,
                                            text: "Changes in templates",
                                            fragment: Optional(
                                                "changes-in-templates"
                                            ),
                                            children: []
                                        )
                                    )
                                ),
                                AnyCodable(
                                    Optional(
                                        Outline(
                                            level: 2,
                                            text: "Pipelines",
                                            fragment: Optional("pipelines"),
                                            children: []
                                        )
                                    )
                                ),
                                AnyCodable(
                                    Optional(
                                        Outline(
                                            level: 2,
                                            text: "Useful links",
                                            fragment: Optional("useful-links"),
                                            children: []
                                        )
                                    )
                                ),
                            ]),
                            PageContentsKeys.html.rawValue: AnyCodable(
                                "<p></p>"
                            ),
                        ]),
                        "authors": AnyCodable([
                            [
                                PageContextKeys.contents.rawValue: AnyCodable([
                                    PageContentsKeys.outline.rawValue:
                                        AnyCodable([]),
                                    PageContentsKeys.html.rawValue: AnyCodable(
                                        ""
                                    ),
                                    PageContentsKeys.readingTime.rawValue:
                                        AnyCodable(1),
                                ]),
                                PageContextKeys.permalink.rawValue: AnyCodable(
                                    "https://toucansites.com/authors/gabor-lengyel/"
                                ),
                                "description": AnyCodable(
                                    "Former Android Developer, co-founder of Binary Birds Kft."
                                ),
                                "slug": AnyCodable(
                                    Optional(
                                        Slug(
                                            "authors/gabor-lengyel"
                                        )
                                    )
                                ),
                                "image": AnyCodable(
                                    "https://toucansites.com/assets/authors/gabor-lengyel/gabor-lengyel.jpg"
                                ),
                                "title": AnyCodable("Gábor Lengyel"),
                                "order": AnyCodable(10),
                                SystemPropertyKeys.lastUpdate.rawValue:
                                    AnyCodable(
                                        Optional(
                                            DateContext(
                                                date: .init(
                                                    full:
                                                        "Friday, April 18, 2025",
                                                    long: "April 18, 2025",
                                                    medium: "Apr 18, 2025",
                                                    short: "4/18/25"
                                                ),
                                                time:
                                                    .init(
                                                        full:
                                                            "12:45:44 PM Greenwich Mean Time",
                                                        long: "12:45:44 PM GMT",
                                                        medium: "12:45:44 PM",
                                                        short: "12:45 PM"
                                                    ),
                                                timestamp: 1744980344.8431244,
                                                iso8601:
                                                    "2025-04-18T12:45:44.843Z",
                                                formats: [
                                                    "rss":
                                                        "Fri, 18 Apr 2025 12:45:44 +0000",
                                                    "sitemap": "2025-04-18",

                                                    "year": "2025",
                                                ]
                                            )
                                        )
                                    ),
                            ]
                        ]),
                        "image": AnyCodable(nil),
                        "slug": AnyCodable(
                            Optional(Slug("beta-3-migration-guide"))
                        ),
                        "title": AnyCodable("Beta 3 migration guide"),
                        PageContextKeys.permalink.rawValue: AnyCodable(
                            "https://toucansites.com/beta-3-migration-guide/"
                        ),
                    ]
                ]
            ]
        ]

        let encoder = JSONEncoder()
        let result = value.unboxed(encoder)

        let firstAuthorSlugValue = result.value(
            forKeyPath: "context.posts.0.authors.0.slug"
        )
        let slug = try #require(firstAuthorSlugValue as? Slug)
        #expect(slug.value == "authors/gabor-lengyel")

        let publicationDateFullValue = result.value(
            forKeyPath: "context.posts.0.publication.date.full"
        )
        let publicationDateFull = try #require(
            publicationDateFullValue as? String
        )
        #expect(publicationDateFull == "Tuesday, April 15, 2025")
    }
}
