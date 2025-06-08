//
//  Mocks+E2E.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 06. 08..
//

import FileManagerKitBuilder
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
    }

    static func pipelines() -> Directory {
        Directory(name: "pipelines") {
            YAMLFile(name: "html", contents: Mocks.Pipelines.html())
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
            YAMLFile(name: "rss", contents: Mocks.Pipelines.rss())
            YAMLFile(name: "api", contents: Mocks.Pipelines.api())
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

    static func themes() -> Directory {
        Directory(name: "themes") {
            Directory(name: "default") {
                Directory(name: "assets") {
                    Directory(name: "css") {
                        File(
                            name: "theme.css",
                            string: """
                                body { background: #000; }
                                """
                        )
                    }
                }
                Directory(name: "templates") {
                    Directory(name: "docs") {
                        Directory(name: "category") {
                            MustacheFile(
                                name: "default",
                                template: Mocks.Templates.category()
                            )
                        }
                        Directory(name: "guide") {
                            MustacheFile(
                                name: "default",
                                template: Mocks.Templates.guide()
                            )
                        }
                    }
                    Directory(name: "pages") {
                        MustacheFile(
                            name: "default",
                            template: Mocks.Templates.page()
                        )
                        MustacheFile(
                            name: "404",
                            template: Mocks.Templates.notFound()
                        )
                    }
                    Directory(name: "blog") {
                        Directory(name: "tag") {
                            MustacheFile(
                                name: "default",
                                template: Mocks.Templates.tag()
                            )
                        }
                        Directory(name: "post") {
                            MustacheFile(
                                name: "default",
                                template: Mocks.Templates.post()
                            )
                        }
                        Directory(name: "author") {
                            MustacheFile(
                                name: "default",
                                template: Mocks.Templates.author()
                            )
                        }
                    }
                    Directory(name: "partials") {
                        Directory(name: "blog") {
                            MustacheFile(
                                name: "author",
                                template: Mocks.Templates.partialAuthor()
                            )
                            MustacheFile(
                                name: "tag",
                                template: Mocks.Templates.partialTag()
                            )
                            MustacheFile(
                                name: "post",
                                template: Mocks.Templates.partialPost()
                            )
                        }
                        Directory(name: "docs") {
                            MustacheFile(
                                name: "category",
                                template: Mocks.Templates.partialCategory()
                            )
                            MustacheFile(
                                name: "guide",
                                template: Mocks.Templates.partialGuide()
                            )
                        }
                    }
                    MustacheFile(
                        name: "html",
                        template: Mocks.Templates.html()
                    )
                    MustacheFile(
                        name: "redirect",
                        template: Mocks.Templates.redirect()
                    )
                    MustacheFile(
                        name: "rss",
                        template: Mocks.Templates.rss()
                    )
                    MustacheFile(
                        name: "sitemap",
                        template: Mocks.Templates.sitemap()
                    )
                }
            }
        }
    }

}
