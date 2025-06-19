//
//  Mocks+E2E.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 06. 08..
//

import FileManagerKitBuilder
import Foundation
import ToucanSDK
import ToucanSource

extension Mocks.E2E {
    static func types(
        postType: ContentDefinition
    ) -> Directory {
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
            YAMLFile(
                name: "post",
                contents: postType
            )
            YAMLFile(
                name: "category",
                contents: Mocks.ContentDefinitions.category()
            )
            YAMLFile(
                name: "guide",
                contents: Mocks.ContentDefinitions.guide()
            )
        }
    }

    static func pipelines() -> Directory {
        Directory(name: "pipelines") {
            YAMLFile(
                name: "html",
                contents: Mocks.Pipelines.html()
            )
            YAMLFile(
                name: "not-found",
                contents: Mocks.Pipelines.notFound()
            )
            YAMLFile(
                name: "redirect",
                contents: Mocks.Pipelines.redirect()
            )
            YAMLFile(
                name: "sitemap",
                contents: Mocks.Pipelines.sitemap()
            )
            YAMLFile(
                name: "rss",
                contents: Mocks.Pipelines.rss()
            )
            YAMLFile(
                name: "api",
                contents: Mocks.Pipelines.api()
            )
        }
    }

    static func blocks() -> Directory {
        Directory(name: "blocks") {
            YAMLFile(
                name: "faq",
                contents: Mocks.Blocks.faq()
            )
        }
    }

    static func templates(
        debugContext: String
    ) -> Directory {
        Directory(name: "templates") {
            Directory(name: "default") {
                YAMLFile(
                    name: "template",
                    contents: Mocks.Templates.metadata()
                )
                Directory(name: "assets") {
                    Directory(name: "css") {
                        File(
                            name: "template.css",
                            string: """
                            body { background: #000; }
                            """
                        )
                    }
                }
                Directory(name: "views") {
                    MustacheFile(
                        name: "test",
                        template: Mocks.Views.page()
                    )
                    Directory(name: "docs") {
                        Directory(name: "category") {
                            MustacheFile(
                                name: "default",
                                template: Mocks.Views.category()
                            )
                        }
                        Directory(name: "guide") {
                            MustacheFile(
                                name: "default",
                                template: Mocks.Views.guide()
                            )
                        }
                    }
                    Directory(name: "pages") {
                        MustacheFile(
                            name: "default",
                            template: Mocks.Views.page()
                        )
                        MustacheFile(
                            name: "404",
                            template: Mocks.Views.notFound()
                        )
                        MustacheFile(
                            name: "context",
                            template: Mocks.Views.context(
                                value: debugContext
                            )
                        )
                    }
                    Directory(name: "blog") {
                        Directory(name: "tag") {
                            MustacheFile(
                                name: "default",
                                template: Mocks.Views.tag()
                            )
                        }
                        Directory(name: "post") {
                            MustacheFile(
                                name: "default",
                                template: Mocks.Views.post()
                            )
                        }
                        Directory(name: "author") {
                            MustacheFile(
                                name: "default",
                                template: Mocks.Views.author()
                            )
                        }
                    }
                    Directory(name: "partials") {
                        Directory(name: "blog") {
                            MustacheFile(
                                name: "author",
                                template: Mocks.Views.partialAuthor()
                            )
                            MustacheFile(
                                name: "tag",
                                template: Mocks.Views.partialTag()
                            )
                            MustacheFile(
                                name: "post",
                                template: Mocks.Views.partialPost()
                            )
                        }
                        Directory(name: "docs") {
                            MustacheFile(
                                name: "category",
                                template: Mocks.Views.partialCategory()
                            )
                            MustacheFile(
                                name: "guide",
                                template: Mocks.Views.partialGuide()
                            )
                        }
                    }
                    MustacheFile(
                        name: "html",
                        template: Mocks.Views.html()
                    )
                    MustacheFile(
                        name: "redirect",
                        template: Mocks.Views.redirect()
                    )
                    MustacheFile(
                        name: "rss",
                        template: Mocks.Views.rss()
                    )
                    MustacheFile(
                        name: "sitemap",
                        template: Mocks.Views.sitemap()
                    )
                }
            }
        }
    }

    static func src(
        now: Date,
        debugContext: String = "{{.}}"
    ) -> Directory {
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

        return Directory(name: "src") {
            YAMLFile(
                name: "site",
                contents: [
                    "name": "Test site name",
                    "description": "Test site description",
                    "language": "en-US",
                ] as [String: AnyCodable]
            )
            Directory(name: "contents") {
                RawContentBundle(
                    name: "",
                    rawContent: Mocks.RawContents.homePage(now: now)
                )
                RawContentBundle(
                    name: "about",
                    rawContent: Mocks.RawContents.aboutPage(now: now)
                )
                RawContentBundle(
                    name: "context",
                    rawContent: Mocks.RawContents.contextPage(now: now)
                )
                RawContentBundle(
                    name: "404",
                    rawContent: Mocks.RawContents.notFoundPage(now: now)
                )

                Directory(name: "pages") {
                    RawContentBundle(
                        name: "page-1",
                        rawContent: Mocks.RawContents.page(id: 1, now: now)
                    )
                    RawContentBundle(
                        name: "page-2",
                        rawContent: Mocks.RawContents.page(id: 2, now: now)
                    )
                    RawContentBundle(
                        name: "page-3",
                        rawContent: Mocks.RawContents.page(id: 3, now: now)
                    )
                }

                Directory(name: "redirects") {
                    RawContentBundle(
                        name: "home-old",
                        rawContent: Mocks.RawContents.redirectHome(now: now)
                    )
                    RawContentBundle(
                        name: "about-old",
                        rawContent: Mocks.RawContents.redirectAbout(now: now)
                    )
                }

                RawContentBundle(
                    name: "sitemap.xml",
                    rawContent: Mocks.RawContents.sitemapXML(now: now)
                )

                RawContentBundle(
                    name: "rss.xml",
                    rawContent: Mocks.RawContents.rssXML(now: now)
                )

                Directory(name: "blog") {
                    Directory(name: "posts") {
                        RawContentBundle(
                            name: "post-1",
                            rawContent: Mocks.RawContents.post(
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
                            )
                        )
                        RawContentBundle(
                            name: "post-2",
                            rawContent: Mocks.RawContents.post(
                                id: 2,
                                now: now,
                                // past
                                publication: formatter.string(
                                    from: now.addingTimeInterval(
                                        -86400 * 2
                                    ),
                                    using: publicationConfig
                                ),
                                // future
                                expiration: formatter.string(
                                    from: now.addingTimeInterval(
                                        86400 * 2
                                    ),
                                    using: expirationConfig
                                ),
                                featured: true,
                                authorIDs: [1, 2, 3],
                                tagIDs: [2]
                            )
                        )
                        RawContentBundle(
                            name: "post-3",
                            rawContent: Mocks.RawContents.post(
                                id: 3,
                                now: now,
                                // distant past
                                publication: formatter.string(
                                    from: now.addingTimeInterval(
                                        -86400 * 3
                                    ),
                                    using: publicationConfig
                                ),
                                // distant future
                                expiration: formatter.string(
                                    from: now.addingTimeInterval(
                                        86400 * 3
                                    ),
                                    using: expirationConfig
                                ),
                                featured: false,
                                authorIDs: [2, 3],
                                tagIDs: [2, 3]
                            )
                        )
                        Directory(name: "pages") {
                            RawContentBundle(
                                name: "{{post.pagination}}",
                                rawContent: Mocks.RawContents.postPagination(
                                    now: now
                                )
                            )
                        }
                    }
                    Directory(name: "authors") {
                        RawContentBundle(
                            name: "author-1",
                            rawContent: Mocks.RawContents.author(
                                id: 1,
                                age: 18,
                                now: now
                            )
                        )
                        RawContentBundle(
                            name: "author-2",
                            rawContent: Mocks.RawContents.author(
                                id: 2,
                                age: 21,
                                now: now
                            )
                        )
                        RawContentBundle(
                            name: "author-3",
                            rawContent: Mocks.RawContents.author(
                                id: 3,
                                age: 42,
                                now: now
                            )
                        )
                    }
                    Directory(name: "tags") {
                        RawContentBundle(
                            name: "tag-1",
                            rawContent: Mocks.RawContents.tag(id: 1, now: now)
                        )
                        RawContentBundle(
                            name: "tag-2",
                            rawContent: Mocks.RawContents.tag(id: 2, now: now)
                        )
                        RawContentBundle(
                            name: "tag-3",
                            rawContent: Mocks.RawContents.tag(id: 3, now: now)
                        )
                    }
                }
                Directory(name: "docs") {
                    Directory(name: "categories") {
                        RawContentBundle(
                            name: "category-1",
                            rawContent: Mocks.RawContents.category(
                                id: 1,
                                now: now
                            )
                        )
                        RawContentBundle(
                            name: "category-2",
                            rawContent: Mocks.RawContents.category(
                                id: 2,
                                now: now
                            )
                        )
                        RawContentBundle(
                            name: "category-3",
                            rawContent: Mocks.RawContents.category(
                                id: 3,
                                now: now
                            )
                        )
                    }
                    Directory(name: "guides") {
                        RawContentBundle(
                            name: "guide-1",
                            rawContent: Mocks.RawContents.guide(
                                id: 1,
                                categoryID: 1,
                                now: now
                            )
                        )
                        RawContentBundle(
                            name: "guide-2",
                            rawContent: Mocks.RawContents.guide(
                                id: 2,
                                categoryID: 1,
                                now: now
                            )
                        )
                        RawContentBundle(
                            name: "guide-3",
                            rawContent: Mocks.RawContents.guide(
                                id: 3,
                                categoryID: 1,
                                now: now
                            )
                        )
                        RawContentBundle(
                            name: "guide-4",
                            rawContent: Mocks.RawContents.guide(
                                id: 4,
                                categoryID: 2,
                                now: now
                            )
                        )
                        RawContentBundle(
                            name: "guide-5",
                            rawContent: Mocks.RawContents.guide(
                                id: 5,
                                categoryID: 2,
                                now: now
                            )
                        )
                        RawContentBundle(
                            name: "guide-6",
                            rawContent: Mocks.RawContents.guide(
                                id: 6,
                                categoryID: 2,
                                now: now
                            )
                        )
                        RawContentBundle(
                            name: "guide-7",
                            rawContent: Mocks.RawContents.guide(
                                id: 7,
                                categoryID: 3,
                                now: now
                            )
                        )
                        RawContentBundle(
                            name: "guide-8",
                            rawContent: Mocks.RawContents.guide(
                                id: 8,
                                categoryID: 3,
                                now: now
                            )
                        )
                        RawContentBundle(
                            name: "guide-9",
                            rawContent: Mocks.RawContents.guide(
                                id: 9,
                                categoryID: 3,
                                now: now
                            )
                        )
                    }
                }
            }
            Mocks.E2E.types(postType: postType)
            Mocks.E2E.pipelines()
            Mocks.E2E.blocks()
            Mocks.E2E.templates(debugContext: debugContext)
        }
    }
}
