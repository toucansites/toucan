//
//  Mocks+BuildTargetSources.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 21..
//

import Foundation
import ToucanSDK
import ToucanSource
import Testing

extension Mocks {

    static func buildTargetSource(
        location: URL = .init(filePath: ""),
        now: Date,
        target: Target = .standard,
        config: Config = .defaults,
        settings: Settings = .defaults
    ) -> BuildTargetSource {

        let formatter = ToucanInputDateFormatter(
            dateConfig: config.dataTypes.date
        )

        let postType = Mocks.ContentDefinitions.post()
        guard
            case let .date(
                publicationConfig
            ) = postType.properties["publication"]?.type
        else {
            fatalError(
                "Mock post type issue: publication is not a date property."
            )
        }
        guard
            case let .date(
                expirationConfig
            ) = postType.properties["expiration"]?.type
        else {
            fatalError(
                "Mock post type issue: expiration is not a date property."
            )
        }

        return .init(
            location: location,
            target: target,
            config: config,
            settings: settings,
            pipelines: [
                Mocks.Pipelines.html(),
                Mocks.Pipelines.notFound(),
                Mocks.Pipelines.redirect(),
                Mocks.Pipelines.sitemap(),
                Mocks.Pipelines.rss(),
                Mocks.Pipelines.api(),
            ],
            contentDefinitions: [
                Mocks.ContentDefinitions.page(),
                postType,
                Mocks.ContentDefinitions.author(),
                Mocks.ContentDefinitions.tag(),
                Mocks.ContentDefinitions.category(),
                Mocks.ContentDefinitions.guide(),
                Mocks.ContentDefinitions.redirect(),
            ],
            rawContents: [
                Mocks.RawContents.homePage(now: now),
                Mocks.RawContents.aboutPage(now: now),
                Mocks.RawContents.notFoundPage(now: now),
                Mocks.RawContents.page(id: 1, now: now),
                Mocks.RawContents.page(id: 2, now: now),
                Mocks.RawContents.page(id: 3, now: now),

                Mocks.RawContents.redirectHome(now: now),
                Mocks.RawContents.redirectAbout(now: now),

                Mocks.RawContents.sitemapXML(now: now),
                Mocks.RawContents.rssXML(now: now),

                Mocks.RawContents.author(id: 1, age: 18, now: now),
                Mocks.RawContents.author(id: 2, age: 21, now: now),
                Mocks.RawContents.author(id: 3, age: 42, now: now),

                Mocks.RawContents.tag(id: 1, now: now),
                Mocks.RawContents.tag(id: 2, now: now),
                Mocks.RawContents.tag(id: 3, now: now),

                Mocks.RawContents.post(
                    id: 1,
                    now: now,
                    // near past
                    publication: formatter.string(
                        from: now.addingTimeInterval(-86_400),
                        using: publicationConfig
                    ),
                    // near future
                    expiration: formatter.string(
                        from: now.addingTimeInterval(86_400),
                        using: expirationConfig
                    ),
                    featured: false,
                    authorIds: [1, 2],
                    tagIds: [1, 2]
                ),
                Mocks.RawContents.post(
                    id: 2,
                    now: now,
                    // past
                    publication: formatter.string(
                        from: now.addingTimeInterval(-86_400 * 2),
                        using: publicationConfig
                    ),
                    // future
                    expiration: formatter.string(
                        from: now.addingTimeInterval(86_400 * 2),
                        using: expirationConfig
                    ),
                    featured: true,
                    authorIds: [1, 2, 3],
                    tagIds: [2]
                ),
                Mocks.RawContents.post(
                    id: 3,
                    now: now,
                    // distant past
                    publication: formatter.string(
                        from: now.addingTimeInterval(-86_400 * 3),
                        using: publicationConfig
                    ),
                    // distant future
                    expiration: formatter.string(
                        from: now.addingTimeInterval(86_400 * 3),
                        using: expirationConfig
                    ),
                    featured: false,
                    authorIds: [2, 3],
                    tagIds: [2, 3]
                ),
                Mocks.RawContents.postPagination(now: now),

                Mocks.RawContents.category(id: 1, now: now),
                Mocks.RawContents.category(id: 2, now: now),
                Mocks.RawContents.category(id: 3, now: now),

                Mocks.RawContents.guide(id: 1, categoryId: 1, now: now),
                Mocks.RawContents.guide(id: 2, categoryId: 1, now: now),
                Mocks.RawContents.guide(id: 3, categoryId: 1, now: now),
                Mocks.RawContents.guide(id: 4, categoryId: 2, now: now),
                Mocks.RawContents.guide(id: 5, categoryId: 2, now: now),
                Mocks.RawContents.guide(id: 6, categoryId: 2, now: now),
                Mocks.RawContents.guide(id: 7, categoryId: 3, now: now),
                Mocks.RawContents.guide(id: 8, categoryId: 3, now: now),
                Mocks.RawContents.guide(id: 9, categoryId: 3, now: now),
            ],
            blockDirectives: [
                Mocks.Blocks.link()
            ]
        )
    }
}
