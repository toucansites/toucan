//
//  File.swift
//
//
//  Created by Tibor Bodecs on 13/06/2024.
//

import Foundation
import FileManagerKit
import Yams

/// An extension of the `Source` struct, providing a configuration loader for site configuration.
///
/// The `ConfigLoader` is responsible for loading and parsing configuration files, handling errors, and providing
/// the necessary configuration data for the site.
extension Source {

    /// A structure responsible for loading configuration data.
    struct ConfigLoader {
        
        /// An enumeration representing possible errors that can occur while loading the configuration.
        enum Error: Swift.Error {
            /// Indicates an error related to file operations.
            case file(Swift.Error)
            /// Indicates an error related to parsing YAML.
            case yaml(YamlError)
        }
        
        /// The URL of the configuration file.
        let configFileUrl: URL
        /// The file manager used for file operations.
        let fileManager: FileManager
        /// The front matter parser used for parsing the configuration file.
        let frontMatterParser: FrontMatterParser

        /// Creates a configuration for the site based on the provided dictionary.
        ///
        /// - Parameter dict: A dictionary containing paths and settings for the site configuration.
        /// - Returns: A `Source.Config.Site` object configured with the provided settings, or default settings if none are provided.
        func createSiteConfig(
            _ dict: [String: Any]
        ) -> Source.Config.Site {
            let userDefined = dict.filter {
                ![
                    "baseUrl",
                    "title",
                    "description",
                    "language",
                    "dateFormat",
                ]
                .contains($0.key)
            }
            
            var siteBaseUrl = dict.string("baseUrl") ?? ""
            if !siteBaseUrl.hasSuffix("/") {
                siteBaseUrl += "/"
            }
            let title = dict.string("title")
            let desc = dict.string("description")
            let lang = dict.string("language")
            let dateFormat = dict.string("dateFormat")
            
            return .init(
                baseUrl: siteBaseUrl,
                title: title ?? "",
                description: desc ?? "",
                language: lang,
                dateFormat: dateFormat ?? "yyyy-MM-dd HH:mm:ss"
            )
        }
        
        /// Creates a configuration for the blog contents based on the provided dictionary.
        ///
        /// - Parameter dict: A dictionary containing paths for the blog contents.
        /// - Returns: A `Config.Contents.Blog` object configured with the provided paths, or default paths if none are provided.
        func createBlogConfig(
            _ dict: [String: Any]
        ) -> Config.Contents.Blog {
            .init(
                posts: .init(
                    folder: dict.string("posts.folder") ?? "blog/posts",
                    slugPrefix: dict.string("posts.slugPrefix")
                ),
                authors: .init(
                    folder: dict.string("authors.folder") ?? "blog/authors",
                    slugPrefix: dict.string("authors.slugPrefix") ?? "authors"
                ),
                tags: .init(
                    folder: dict.string("tags.folder") ?? "blog/tags",
                    slugPrefix: dict.string("tags.slugPrefix") ?? "tags"
                )
            )
        }
        
        /// Creates a configuration for the documentation contents based on the provided dictionary.
        ///
        /// - Parameter dict: A dictionary containing paths for the documentation contents.
        /// - Returns: A `Config.Contents.Docs` object configured with the provided paths, or default paths if none are provided.
        func createDocsConfig(
            _ dict: [String: Any]
        ) -> Config.Contents.Docs {
            .init(
                categories: .init(
                    folder: dict.string("categories.folder") ?? "docs/categories",
                    slugPrefix: dict.string("categories.slugPrefix") ?? "docs/categories"
                ),
                guides: .init(
                    folder: dict.string("guides.folder") ?? "docs/guides",
                    slugPrefix: dict.string("guides.slugPrefix") ?? "docs/guides"
                )
            )
        }
        
        /// Creates a configuration for the main pages based on the provided dictionary.
        ///
        /// - Parameter dict: A dictionary containing paths for the main pages.
        /// - Returns: A `Config.Pages.Main` object configured with the provided paths, or default paths if none are provided.
        func createPagesConfig(
            _ dict: [String: Any]
        ) -> Config.Contents.Pages {
            .init(
                custom: .init(
                    folder: dict.string("custom.folder") ?? "pages/custom",
                    slugPrefix: dict.string("custom.slugPrefix")
                )
            )
        }
        
        func createMainPageConfig(
            _ dict: [String: Any]
        ) -> Config.Pages.Main {
            .init(
                home: .init(path: dict.string("home.path") ?? "pages/home"),
                notFound: .init(path: dict.string("notFound.path") ?? "pages/404")
            )
        }
        
        /// Creates a configuration for the blog pages based on the provided dictionary.
        ///
        /// - Parameter dict: A dictionary containing paths for the blog pages.
        /// - Returns: A `Config.Pages.Blog` object configured with the provided paths, or default paths if none are provided.
        func createBlogPageConfig(
            _ dict: [String: Any]
        ) -> Config.Pages.Blog {
            .init(
                home: .init(path: dict.string("home.path") ?? "pages/blog/home"),
                authors: .init(path: dict.string("authors.path") ?? "pages/blog/authors"),
                tags: .init(path: dict.string("tags.path") ?? "pages/blog/tags"),
                posts: .init(path: dict.string("posts.path") ?? "pages/blog/posts")
            )
        }
        
        /// Creates a configuration for the documentation pages based on the provided dictionary.
        ///
        /// - Parameter dict: A dictionary containing paths for the documentation pages.
        /// - Returns: A `Config.Pages.Docs` object configured with the provided paths, or default paths if none are provided.
        func createDocsPageConfig(
            _ dict: [String: Any]
        ) -> Config.Pages.Docs {
            .init(
                home: .init(path: dict.string("home.path") ?? "pages/docs/home"),
                categories: .init(path: dict.string("categories.path") ?? "pages/docs/categories"),
                guides: .init(path: dict.string("guides.path") ?? "pages/docs/guides")
            )
        }

        /// Loads the configuration from the specified YAML file and returns a `Source.Config` object.
        ///
        /// - Throws: `ConfigLoader.Error.yaml` if there is an error parsing the YAML file.
        ///           `ConfigLoader.Error.file` if there is an error reading the file.
        /// - Returns: A `Source.Config` object containing the site, content, and pages configuration.
        func load() throws(ConfigLoader.Error) -> Source.Config {
            do {
                let rawYaml = try String(contentsOf: configFileUrl)
                let yaml = try Yams.load(
                    yaml: String(rawYaml),
                    Resolver.default.removing(.timestamp)
                ) as? [String: Any] ?? [:]
                
                let site = yaml.dict("site")
                let content = yaml.dict("contents")
                let pages = yaml.dict("pages")

                return .init(
                    site: createSiteConfig(site),
                    contents: .init(
                        blog: createBlogConfig(content.dict("blog")),
                        docs: createDocsConfig(content.dict("docs")),
                        pages: createPagesConfig(content.dict("pages"))
                    ),
                    pages: .init(
                        main: createMainPageConfig(pages.dict("main")),
                        blog: createBlogPageConfig(pages.dict("blog")),
                        docs: createDocsPageConfig(pages.dict("docs"))
                    )
                )
            }
            catch let error as YamlError {
                throw Error.yaml(error)
            }
            catch {
                throw Error.file(error)
            }
        }
    }
}
