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
        .test {
            let url = $1.appending(path: "foo/bar/")
            let overrideUrl = $1.appending(path: "foo/bar/")
            let fs = ToucanFileSystem(fileManager: $0)

            #expect(fs.mdRawContentLocator.locate(at: url).isEmpty)
            #expect(fs.ymlRawContentLocator.locate(at: url).isEmpty)
            #expect(
                fs.ymlFileLocator.locate(at: url, overrides: overrideUrl)
                    .isEmpty
            )
            #expect(
                fs.templateLocator.locate(at: url, overrides: overrideUrl)
                    .isEmpty
            )
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
                    Directory("redirects") {
                        "noindex.yml"
                        Directory("home-old") {
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
                            "redirect.yml"
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
        .test {
            let fs = ToucanFileSystem(fileManager: $0)
            let contentsUrl = $1.appending(path: "src/contents/")

            let mdRawContentLocations = fs.mdRawContentLocator.locate(
                at: contentsUrl
            )
            let ymlRawContentLocations = fs.ymlRawContentLocator.locate(
                at: contentsUrl
            )

            let rawContentLocations =
                mdRawContentLocations + ymlRawContentLocations

            #expect(
                rawContentLocations.sorted { $0.path < $1.path }
                    == [
                        .init(path: "404/index.md", slug: "404"),
                        .init(path: "home/index.md", slug: "home"),
                        .init(path: "blog/authors/index.md", slug: "authors"),
                        .init(
                            path: "redirects/home-old/index.md",
                            slug: "home-old"
                        ),
                    ]
                    .sorted { $0.path < $1.path }
            )

            let typesUrl = $1.appending(path: "src/themes/default/types/")
            let typesOverridesUrl = $1.appending(
                path: "src/themes/overrides/types/"
            )

            let contentTypes = fs.ymlFileLocator.locate(
                at: typesUrl,
                overrides: typesOverridesUrl
            )
            #expect(
                contentTypes.sorted { $0.path < $1.path }
                    == [
                        .init(
                            path: "author.yml",
                            overridePath: .some("author.yml")
                        ),
                        .init(path: "post.yml", overridePath: nil),
                        .init(path: "redirect.yml", overridePath: nil),
                    ]
                    .sorted { $0.path < $1.path }
            )

            let templatesUrl = $1.appending(
                path: "src/themes/default/templates/"
            )
            let templatesOverridesUrl = $1.appending(
                path: "src/themes/overrides/templates/"
            )

            let templates = fs.templateLocator.locate(
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
                    .sorted { $0.path < $1.path }
            )
        }
    }

    @Test()
    func fileSystem_SettingsLocator() async throws {
        try FileManagerPlayground {
            Directory("src") {
                Directory("contents") {
                    "site.yml"
                    "site.yaml"
                    "index.yml"
                    "index.md"
                }
            }
        }
        .test {
            let fs = ToucanFileSystem(fileManager: $0)
            let url = $1.appending(path: "src/contents/")
            let locations = fs.settingsLocator.locate(at: url)

            #expect(locations.sorted() == ["site.yaml", "site.yml"])
        }
    }

}
