//
//  RSSPipelineTestSuite.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 02. 20..
//
//
import Foundation
import Testing
import Logging
import ToucanSource
import FileManagerKitBuilder
@testable import ToucanSDK

@Suite
struct RSSPipelineTestSuite {

    @Test
    func rss() throws {
        let now = Date()

        let config: Config = .defaults

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

        try FileManagerPlayground {
            Directory(name: "src") {

                YAMLFile(
                    name: "site",
                    contents: [
                        "name": "Test"
                    ] as [String: AnyCodable]
                )
                Directory(name: "contents") {
                    RawContentBundle(Mocks.RawContents.homePage(now: now))
                    RawContentBundle(Mocks.RawContents.aboutPage(now: now))
                    RawContentBundle(Mocks.RawContents.notFoundPage(now: now))
                    RawContentBundle(Mocks.RawContents.page(id: 1, now: now))
                    RawContentBundle(Mocks.RawContents.page(id: 2, now: now))
                    RawContentBundle(Mocks.RawContents.page(id: 3, now: now))

                    RawContentBundle(Mocks.RawContents.redirectHome(now: now))
                    RawContentBundle(Mocks.RawContents.redirectAbout(now: now))
                    RawContentBundle(Mocks.RawContents.sitemapXML(now: now))
                    RawContentBundle(Mocks.RawContents.rssXML(now: now))

                    Directory(name: "blog") {
                        Directory(name: "posts") {
                            RawContentBundle(
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
                                )
                            )
                            RawContentBundle(
                                Mocks.RawContents.post(
                                    id: 2,
                                    now: now,
                                    // past
                                    publication: formatter.string(
                                        from: now.addingTimeInterval(
                                            -86_400 * 2
                                        ),
                                        using: publicationConfig
                                    ),
                                    // future
                                    expiration: formatter.string(
                                        from: now.addingTimeInterval(
                                            86_400 * 2
                                        ),
                                        using: expirationConfig
                                    ),
                                    featured: true,
                                    authorIds: [1, 2, 3],
                                    tagIds: [2]
                                )
                            )
                            RawContentBundle(
                                Mocks.RawContents.post(
                                    id: 3,
                                    now: now,
                                    // distant past
                                    publication: formatter.string(
                                        from: now.addingTimeInterval(
                                            -86_400 * 3
                                        ),
                                        using: publicationConfig
                                    ),
                                    // distant future
                                    expiration: formatter.string(
                                        from: now.addingTimeInterval(
                                            86_400 * 3
                                        ),
                                        using: expirationConfig
                                    ),
                                    featured: false,
                                    authorIds: [2, 3],
                                    tagIds: [2, 3]
                                )
                            )
                            RawContentBundle(
                                Mocks.RawContents.postPagination(now: now)
                            )
                        }
                        Directory(name: "authors") {
                            RawContentBundle(
                                Mocks.RawContents.author(
                                    id: 1,
                                    age: 18,
                                    now: now
                                )
                            )
                            RawContentBundle(
                                Mocks.RawContents.author(
                                    id: 1,
                                    age: 21,
                                    now: now
                                )
                            )
                            RawContentBundle(
                                Mocks.RawContents.author(
                                    id: 1,
                                    age: 42,
                                    now: now
                                )
                            )
                        }
                        Directory(name: "tags") {
                            RawContentBundle(
                                Mocks.RawContents.tag(id: 1, now: now)
                            )
                            RawContentBundle(
                                Mocks.RawContents.tag(id: 2, now: now)
                            )
                            RawContentBundle(
                                Mocks.RawContents.tag(id: 3, now: now)
                            )
                        }
                    }
                    Directory(name: "docs") {
                        Directory(name: "categories") {
                            RawContentBundle(
                                Mocks.RawContents.category(id: 1, now: now)
                            )
                            RawContentBundle(
                                Mocks.RawContents.category(id: 2, now: now)
                            )
                            RawContentBundle(
                                Mocks.RawContents.category(id: 3, now: now)
                            )
                        }
                        Directory(name: "guides") {
                            RawContentBundle(
                                Mocks.RawContents.guide(
                                    id: 1,
                                    categoryId: 1,
                                    now: now
                                )
                            )
                            RawContentBundle(
                                Mocks.RawContents.guide(
                                    id: 2,
                                    categoryId: 1,
                                    now: now
                                )
                            )
                            RawContentBundle(
                                Mocks.RawContents.guide(
                                    id: 3,
                                    categoryId: 1,
                                    now: now
                                )
                            )
                            RawContentBundle(
                                Mocks.RawContents.guide(
                                    id: 4,
                                    categoryId: 2,
                                    now: now
                                )
                            )
                            RawContentBundle(
                                Mocks.RawContents.guide(
                                    id: 5,
                                    categoryId: 2,
                                    now: now
                                )
                            )
                            RawContentBundle(
                                Mocks.RawContents.guide(
                                    id: 6,
                                    categoryId: 2,
                                    now: now
                                )
                            )
                            RawContentBundle(
                                Mocks.RawContents.guide(
                                    id: 7,
                                    categoryId: 3,
                                    now: now
                                )
                            )
                            RawContentBundle(
                                Mocks.RawContents.guide(
                                    id: 8,
                                    categoryId: 3,
                                    now: now
                                )
                            )
                            RawContentBundle(
                                Mocks.RawContents.guide(
                                    id: 9,
                                    categoryId: 3,
                                    now: now
                                )
                            )
                        }
                    }
                }
                Directory(name: "types") {
                    YAMLFile(
                        name: "page",
                        contents: Mocks.ContentDefinitions.page()
                    )
                    YAMLFile(
                        name: "author",
                        contents: Mocks.ContentDefinitions.author()
                    )
                    YAMLFile(
                        name: "tag",
                        contents: Mocks.ContentDefinitions.tag()
                    )
                    YAMLFile(name: "post", contents: postType)
                    YAMLFile(
                        name: "category",
                        contents: Mocks.ContentDefinitions.category()
                    )
                    YAMLFile(
                        name: "guide",
                        contents: Mocks.ContentDefinitions.guide()
                    )
                }
                Directory(name: "pipelines") {
                    YAMLFile(name: "html", contents: Mocks.Pipelines.html())
                    YAMLFile(name: "html", contents: Mocks.Pipelines.notFound())
                    YAMLFile(name: "html", contents: Mocks.Pipelines.redirect())
                    YAMLFile(name: "html", contents: Mocks.Pipelines.sitemap())
                    YAMLFile(name: "html", contents: Mocks.Pipelines.rss())
                    YAMLFile(name: "html", contents: Mocks.Pipelines.api())

                }
                Directory(name: "blocks") {
                    YAMLFile(
                        name: "faq",
                        contents: Mocks.Blocks.faq()
                    )
                }
            }
        }
        .test {
            let input = $1.appendingPathIfPresent("src")
            let output = $1.appending(path: "docs/")
            let toucan = Toucan(
                input: input.path(),
                targetsToBuild: []
            )

            try toucan.generate()

            print($0.listDirectory(at: output))

            //            let expectation = #"""
            //                <rss xmlns:atom="http://www.w3.org/2005/Atom" version="2.0">
            //                <channel>
            //                    <title></title>
            //                    <description></description>
            //                    <link>http://localhost:3000</link>
            //                    <language>en-US</language>
            //                    <lastBuildDate>\#(nowString)</lastBuildDate>
            //                    <pubDate>\#(nowString)</pubDate>
            //                    <ttl>250</ttl>
            //                    <atom:link href="http://localhost:3000/rss.xml" rel="self" type="application/rss+xml"/>
            //
            //                    <item>
            //                        <guid isPermaLink="true">http://localhost:3000/blog/posts/post-1/</guid>
            //                        <title><![CDATA[ Post #1 ]]></title>
            //                        <description><![CDATA[  ]]></description>
            //                        <link>http://localhost:3000/blog/posts/post-1/</link>
            //                        <pubDate>\#(nowString)</pubDate>
            //                    </item>
            //                </channel>
            //                </rss>
            //                """#
            //
            //            #expect(results[0].destination.path == "")
            //            #expect(results[0].destination.file == "rss")
            //            #expect(results[0].destination.ext == "xml")
        }
    }

}
