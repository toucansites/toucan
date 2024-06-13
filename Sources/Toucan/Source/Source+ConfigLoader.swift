//
//  File.swift
//
//
//  Created by Tibor Bodecs on 13/06/2024.
//

import Foundation
import FileManagerKit
import Yams

extension Source {

    struct ConfigLoader {
        
        enum Error: Swift.Error {
            case file(Swift.Error)
            case yaml(YamlError)
        }
        
        let configFileUrl: URL
        let fileManager: FileManager
        let frontMatterParser: FrontMatterParser
        
        
        func getSiteConfig(_ dict: [String: Any]) -> Source.Config.Site {
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
            
            var siteBaseUrl = dict["baseUrl"] as? String ?? ""
            if !siteBaseUrl.hasSuffix("/") {
                siteBaseUrl += "/"
            }
            let title = dict["title"] as? String
            let desc = dict["description"] as? String
            let lang = dict["language"] as? String
            let dateFormat = dict["dateFormat"] as? String
            
            return .init(
                baseUrl: siteBaseUrl,
                title: title ?? "",
                description: desc ?? "",
                language: lang,
                dateFormat: dateFormat ?? "yyyy-MM-dd HH:mm:ss"
            )
        }
        
        
        func load() throws(ConfigLoader.Error) -> Source.Config {
            do {
                let rawYaml = try String(contentsOf: configFileUrl)
                let yaml = try Yams.load(
                    yaml: String(rawYaml),
                    Resolver.default.removing(.timestamp)
                ) as? [String: Any] ?? [:]
                
                let site = yaml["site"] as? [String: Any] ?? [:]
                return .init(
                    site: getSiteConfig(site),
                    contents: .init(
                        blog: .init(
                            posts: .init(
                                folder: "",
                                slugPrefix: nil
                            ),
                            authors: .init(
                                folder: "",
                                slugPrefix: nil
                            ),
                            tags: .init(
                                folder: "",
                                slugPrefix: nil
                            )
                        ),
                        docs: .init(
                            categories: .init(
                                folder: "",
                                slugPrefix: nil
                            ),
                            guides: .init(
                                folder: "",
                                slugPrefix: nil
                            )
                        ),
                        pages: .init(
                            custom: .init(
                                folder: "",
                                slugPrefix: nil
                            )
                        )
                    ),
                    pages: .init(
                        main: .init(
                            home: .init(path: ""),
                            notFound: .init(path: "")
                        ),
                        blog: .init(
                            authors: .init(path: ""),
                            tags: .init(path: ""),
                            posts: .init(path: "")
                        ),
                        docs: .init(
                            categories: .init(path: ""),
                            guides: .init(path: "")
                        )
                    )
                )
            }
            catch let error as YamlError {
                throw Error.yaml(error)
            }
            catch {
                throw Error.file(error)
            }

//            let site = frontMatter["site"] as? [String: Any] ?? [:]
//            let userDefined = site.filter {
//                ![
//                    "baseUrl",
//                    "title",
//                    "description",
//                    "language",
//                    "dateFormat",
//                ]
//                    .contains($0.key)
//            }
//
//            var siteBaseUrl = site["baseUrl"] as? String ?? ""
//            if !siteBaseUrl.hasSuffix("/") {
//                siteBaseUrl += "/"
//            }
//            let siteTitle = site["title"] as? String ?? ""
//            let siteDescription = site["description"] as? String ?? ""
//            let siteLanguage = site["language"] as? String
//            let siteDateFormat =
//            site["dateFormat"] as? String ?? "yyyy-MM-dd HH:mm:ss"
//
//            let blog = frontMatter["blog"] as? [String: Any] ?? [:]
//            let blogSlug = blog["slug"] as? String ?? ""
//
//            let posts = blog["posts"] as? [String: Any] ?? [:]
//            let postsSlug =
//            posts["slug"] as? String ?? Content.Post.slugPrefix ?? ""
//
//            let postsPage = posts["page"] as? [String: Any] ?? [:]
//            let postsPageSlug = postsPage["slug"] as? String ?? "pages"
//
//            let postsPageLimit = postsPage["limit"] as? Int ?? 10
//
//            let tags = blog["tags"] as? [String: Any] ?? [:]
//            let tagsSlug = tags["slug"] as? String ?? Content.Tag.slugPrefix ?? ""
//
//            let authors = blog["authors"] as? [String: Any] ?? [:]
//            let authorsSlug =
//            authors["slug"] as? String ?? Content.Author.slugPrefix ?? ""
//
//            let pages = frontMatter["pages"] as? [String: Any] ?? [:]
//            let pagesSlug =
//            pages["slug"] as? String ?? Content.Page.slugPrefix ?? ""
        }
    }
}
