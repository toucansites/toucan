import Testing
import Foundation
@testable import ToucanFileSystem
@testable import FileManagerKitTesting

@Suite(.serialized)
struct ToucanFileSystemTests {

    @Test()
    func fileSystem_NoFiles() async throws {
        try FileManagerPlayground {
            Directory("foo") {
                Directory("bar")
                Directory("baz")
            }
        }
        .test { fileManager in
            let url = URL(fileURLWithPath: "./foo/bar/")
            let overrideUrl = URL(fileURLWithPath: "./foo/bar/")
            let fs = ToucanFileSystem(fileManager: fileManager)

            let pageBundles = fs.locateRawContents(at: url)
            #expect(pageBundles.isEmpty)

            let contentTypes = fs.locateContentDefinitions(
                at: url,
                overrides: overrideUrl
            )
            #expect(contentTypes.isEmpty)

            let templates = fs.locateTemplates(at: url, overrides: overrideUrl)
            #expect(templates.isEmpty)
        }
    }

    @Test()
    func fileSystem_Typical() async throws {
        try FileManagerPlayground {
            Directory("src") {
                Directory("contents") {
                    Directory("404") {
                        "index.md"
                    }
                    Directory("home") {
                        "index.md"
                        Directory("assets") {
                            "main.js"
                        }
                    }
                    Directory("blog") {
                        "noindex.yml"
                        Directory("authors") {
                            "index.md"
                        }
                    }
                    Directory("assets") {
                        "CNAME"
                        Directory("icons") {
                            "favicon.png"
                        }
                    }
                }
                Directory("themes") {
                    Directory("default") {
                        Directory("assets") {
                            Directory("css") {
                                "base.css"
                            }
                        }
                        Directory("blocks") {
                            "link.yml"
                        }
                        Directory("templates") {
                            "html.mustache"
                            "redirect.mustache"
                            Directory("partials") {
                                "navigation.mustache"
                                "footer.mustache"
                                Directory("blog") {
                                    "author.mustache"
                                    "post.mustache"
                                }
                                Directory("pages") {
                                    "home.mustache"
                                    "404.mustache"
                                    "default.mustache"
                                }
                            }
                            Directory("blog") {
                                "posts.mustache"
                                Directory("post") {
                                    "default.mustache"
                                }
                            }
                        }
                        Directory("types") {
                            "author.yml"
                            "post.yml"
                        }
                    }
                    Directory("overrides") {
                        Directory("templates") {
                            Directory("blog") {
                                "posts.mustache"
                            }
                        }
                        Directory("types") {
                            "author.yml"
                        }
                    }
                }
            }
        }
        .test { fileManager in
            let fs = ToucanFileSystem(fileManager: fileManager)

            let contentsUrl = URL(fileURLWithPath: "./src/contents/")

            let pageBundles = fs.locateRawContents(at: contentsUrl)

            #expect(
                pageBundles.sorted()
                    == [
                        .init(path: "404", slug: "404"),
                        .init(path: "home", slug: "home"),
                        .init(path: "blog/authors", slug: "authors"),
                    ]
                    .sorted()
            )

            let typesUrl = URL(fileURLWithPath: "./src/themes/default/types/")
            let typesOverridesUrl = URL(
                fileURLWithPath: "./src/themes/overrides/types/"
            )

            let contentTypes = fs.locateContentDefinitions(
                at: typesUrl,
                overrides: typesOverridesUrl
            )
            #expect(
                contentTypes.sorted()
                    == [
                        .init(
                            path: "author.yml",
                            overridePath: .some("author.yml")
                        ),
                        .init(path: "post.yml", overridePath: nil),
                    ]
                    .sorted()
            )

            let templatesUrl = URL(
                fileURLWithPath: "./src/themes/default/templates/"
            )
            let templatesOverridesUrl = URL(
                fileURLWithPath: "./src/themes/overrides/templates/"
            )

            let templates = fs.locateTemplates(
                at: templatesUrl,
                overrides: templatesOverridesUrl
            )
            #expect(
                templates
                    == [
                        .init(
                            id: "blog.post.default",
                            path: "blog/post/default.mustache"
                        ),
                        .init(id: "blog.posts", path: "blog/posts.mustache"),
                        .init(id: "html", path: "html.mustache"),
                        .init(
                            id: "partials.blog.author",
                            path: "partials/blog/author.mustache"
                        ),
                        .init(
                            id: "partials.blog.post",
                            path: "partials/blog/post.mustache"
                        ),
                        .init(
                            id: "partials.footer",
                            path: "partials/footer.mustache"
                        ),
                        .init(
                            id: "partials.navigation",
                            path: "partials/navigation.mustache"
                        ),
                        .init(
                            id: "partials.pages.404",
                            path: "partials/pages/404.mustache"
                        ),
                        .init(
                            id: "partials.pages.default",
                            path: "partials/pages/default.mustache"
                        ),
                        .init(
                            id: "partials.pages.home",
                            path: "partials/pages/home.mustache"
                        ),
                        .init(id: "redirect", path: "redirect.mustache"),
                    ]
                    .sorted()
            )
        }
    }
}
