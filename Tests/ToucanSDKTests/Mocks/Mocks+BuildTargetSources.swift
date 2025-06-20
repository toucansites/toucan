//
//  Mocks+BuildTargetSources.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 21..
//

import Foundation
import Testing
import ToucanSDK
import ToucanSource

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

        let postType = Mocks.ContentTypes.post()

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
            locations: .init(
                sourceURL: location,
                config: config
            ),
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
            types: [
                Mocks.ContentTypes.page(),
                postType,
                Mocks.ContentTypes.author(),
                Mocks.ContentTypes.tag(),
                Mocks.ContentTypes.category(),
                Mocks.ContentTypes.guide(),
                Mocks.ContentTypes.redirect(),
            ],
            rawContents: [
                Mocks.RawContents.homePage(now: now),
                Mocks.RawContents.aboutPage(now: now),
                Mocks.RawContents.contextPage(now: now),
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
                        from: now.addingTimeInterval(-86400),
                        using: publicationConfig
                    ),
                    // near future
                    expiration: formatter.string(
                        from: now.addingTimeInterval(86400),
                        using: expirationConfig
                    ),
                    featured: false,
                    authorIDs: [1, 2],
                    tagIDs: [1, 2]
                ),
                Mocks.RawContents.post(
                    id: 2,
                    now: now,
                    // past
                    publication: formatter.string(
                        from: now.addingTimeInterval(-86400 * 2),
                        using: publicationConfig
                    ),
                    // future
                    expiration: formatter.string(
                        from: now.addingTimeInterval(86400 * 2),
                        using: expirationConfig
                    ),
                    featured: true,
                    authorIDs: [1, 2, 3],
                    tagIDs: [2]
                ),
                Mocks.RawContents.post(
                    id: 3,
                    now: now,
                    // distant past
                    publication: formatter.string(
                        from: now.addingTimeInterval(-86400 * 3),
                        using: publicationConfig
                    ),
                    // distant future
                    expiration: formatter.string(
                        from: now.addingTimeInterval(86400 * 3),
                        using: expirationConfig
                    ),
                    featured: false,
                    authorIDs: [2, 3],
                    tagIDs: [2, 3]
                ),
                Mocks.RawContents.postPagination(now: now),

                Mocks.RawContents.category(id: 1, now: now),
                Mocks.RawContents.category(id: 2, now: now),
                Mocks.RawContents.category(id: 3, now: now),

                Mocks.RawContents.guide(id: 1, categoryID: 1, now: now),
                Mocks.RawContents.guide(id: 2, categoryID: 1, now: now),
                Mocks.RawContents.guide(id: 3, categoryID: 1, now: now),
                Mocks.RawContents.guide(id: 4, categoryID: 2, now: now),
                Mocks.RawContents.guide(id: 5, categoryID: 2, now: now),
                Mocks.RawContents.guide(id: 6, categoryID: 2, now: now),
                Mocks.RawContents.guide(id: 7, categoryID: 3, now: now),
                Mocks.RawContents.guide(id: 8, categoryID: 3, now: now),
                Mocks.RawContents.guide(id: 9, categoryID: 3, now: now),
            ],
            blockDirectives: [
                Mocks.Blocks.link()
            ]
        )
    }
}
