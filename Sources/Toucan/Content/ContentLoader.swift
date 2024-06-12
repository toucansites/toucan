//
//  File.swift
//
//
//  Created by Tibor Bodecs on 03/05/2024.
//

import Foundation
import FileManagerKit

struct ContentLoader {

    let contentsUrl: URL
    let fileManager: FileManager
    let frontMatterParser: FrontMatterParser

    // MARK: - private

    private func getMarkdownURLs(
        at url: URL
    ) -> [URL] {
        var toProcess: [URL] = []
        let dirEnum = fileManager.enumerator(atPath: url.path)
        while let file = dirEnum?.nextObject() as? String {
            let url = url.appendingPathComponent(file)
            guard url.pathExtension.lowercased() == "md" else {
                continue
            }
            toProcess.append(url)
        }
        return toProcess
    }

    private func safeSlug(
        _ value: String,
        prefix: String?
    ) -> String {
        guard value != "home" else {
            return ""
        }
        guard let prefix, !prefix.isEmpty else {
            return
                value
                .split(separator: "/")
                .joined(separator: "/")
        }
        return (prefix.split(separator: "/") + value.split(separator: "/"))
            .joined(separator: "/")
    }

    // MARK: - load

    func load() async throws -> Content {

        let pagesUrl =
            contentsUrl
            .appendingPathComponent(Content.Page.folder)

        let postsUrl =
            contentsUrl
            .appendingPathComponent(Content.Post.folder)

        let authorsUrl =
            contentsUrl
            .appendingPathComponent(Content.Author.folder)

        let tagsUrl =
            contentsUrl
            .appendingPathComponent(Content.Tag.folder)

        let configUrl =
            contentsUrl
            .appendingPathComponent(Toucan.Files.config)

        let pageFiles = getMarkdownURLs(at: pagesUrl)
        let postFiles = getMarkdownURLs(at: postsUrl)
        let authorFiles = getMarkdownURLs(at: authorsUrl)
        let tagFiles = getMarkdownURLs(at: tagsUrl)

        let formatter = DateFormatters.contentLoader

        let config = try loadConfig(
            url: configUrl
        )

        let pages = try await pageFiles.map { url in
            try loadPage(
                config: config,
                baseUrl: pagesUrl,
                url: url
            )
        }
//        let pages = try await withThrowingTaskGroup(of: Content.Page.self) { group in
//            for url in pageFiles {
//                group.addTask {
//                    return try loadPage(
//                        config: config,
//                        baseUrl: pagesUrl,
//                        url: url
//                    )
//                }
//            }
//            var pages: [Content.Page] = []
//            
//            for try await res in group {
//                pages.append(res)
//            }
//            return pages
//        }

        let posts = try await postFiles.map { url in
            let path = url.path.dropFirst(postsUrl.path.count + 1).dropLast(".md".count)
            
            print(path)
            return try loadPost(
                config: config,
                id: String(path),
                url: url,
                formatter: formatter
            )
        }

        let authors = try await authorFiles.map { url in
            try loadAuthor(
                config: config,
                url: url
            )
        }

        let tags = try await tagFiles.map { url in
            try loadTag(
                config: config,
                url: url
            )
        }

        let blogBaseUrl =
            contentsUrl
            .appendingPathComponent("blog")

        let blogHomePage = try loadPage(
            at: blogBaseUrl.appendingPathComponent("home.md"),
            with: "blog",
            using: config
        )

        let authorsPage = try loadPage(
            config: config,
            baseUrl: blogBaseUrl,
            url:
                blogBaseUrl
                .appendingPathComponent("authors.md")
        )

        let postsPage = try loadPage(
            config: config,
            baseUrl: blogBaseUrl,
            url:
                blogBaseUrl
                .appendingPathComponent("posts.md")
        )

        let tagsPage = try loadPage(
            config: config,
            baseUrl: blogBaseUrl,
            url:
                blogBaseUrl
                .appendingPathComponent("tags.md")
        )

        let homePage = try loadPage(
            at:
                contentsUrl
                .appendingPathComponent("pages")
                .appendingPathComponent("home.md"),
            with: "home",
            using: config
        )

        let notFoundPage = try loadPage(
            at:
                contentsUrl
                .appendingPathComponent("pages")
                .appendingPathComponent("404.md"),
            with: "404",
            using: config
        )

        return .init(
            config: config,
            home: homePage,
            notFound: notFoundPage,
            blog: .init(
                home: blogHomePage,
                author: .init(
                    home: authorsPage,
                    contents: authors
                ),
                tag: .init(
                    home: tagsPage,
                    contents: tags
                ),
                post: .init(
                    home: postsPage,
                    contents: posts
                )
            ),
            custom: .init(pages: pages)
        )
    }

    // MARK: - config loader

    func loadConfig(
        url: URL
    ) throws -> Content.Config {
        let rawMarkdown = try String(contentsOf: url)
        let frontMatter = try frontMatterParser.parse(markdown: rawMarkdown)

        let site = frontMatter["site"] as? [String: Any] ?? [:]
        let userDefined = site.filter {
            ![
                "baseUrl",
                "title",
                "description",
                "language",
                "dateFormat",
            ]
            .contains($0.key)
        }

        var siteBaseUrl = site["baseUrl"] as? String ?? ""
        if !siteBaseUrl.hasSuffix("/") {
            siteBaseUrl += "/"
        }
        let siteTitle = site["title"] as? String ?? ""
        let siteDescription = site["description"] as? String ?? ""
        let siteLanguage = site["language"] as? String
        let siteDateFormat =
            site["dateFormat"] as? String ?? "yyyy-MM-dd HH:mm:ss"

        let blog = frontMatter["blog"] as? [String: Any] ?? [:]
        let blogSlug = blog["slug"] as? String ?? ""

        let posts = blog["posts"] as? [String: Any] ?? [:]
        let postsSlug =
            posts["slug"] as? String ?? Content.Post.slugPrefix ?? ""

        let postsPage = posts["page"] as? [String: Any] ?? [:]
        let postsPageSlug = postsPage["slug"] as? String ?? "pages"

        let postsPageLimit = postsPage["limit"] as? Int ?? 10

        let tags = blog["tags"] as? [String: Any] ?? [:]
        let tagsSlug = tags["slug"] as? String ?? Content.Tag.slugPrefix ?? ""

        let authors = blog["authors"] as? [String: Any] ?? [:]
        let authorsSlug =
            authors["slug"] as? String ?? Content.Author.slugPrefix ?? ""

        let pages = frontMatter["pages"] as? [String: Any] ?? [:]
        let pagesSlug =
            pages["slug"] as? String ?? Content.Page.slugPrefix ?? ""

        return .init(
            site: .init(
                baseUrl: siteBaseUrl,
                title: siteTitle,
                description: siteDescription,
                language: siteLanguage,
                dateFormat: siteDateFormat,
                userDefined: userDefined
            ),
            blog: .init(
                slug: blogSlug,
                posts: .init(
                    slug: safeSlug(postsSlug, prefix: blogSlug),
                    page: .init(
                        slug: postsPageSlug,
                        limit: postsPageLimit
                    )
                ),
                authors: .init(
                    slug: safeSlug(authorsSlug, prefix: blogSlug)
                ),
                tags: .init(
                    slug: safeSlug(tagsSlug, prefix: blogSlug)
                )
            ),
            pages: .init(
                slug: pagesSlug
            )
        )
    }

    // MARK: - content type loader

    func loadAuthor(
        config: Content.Config,
        url: URL
    ) throws -> Content.Author {
        let id = String(url.lastPathComponent.dropLast(3))
        let lastModification = try fileManager.modificationDate(at: url)

        let rawMarkdown = try String(contentsOf: url)
        let frontMatter = try frontMatterParser.parse(markdown: rawMarkdown)

        let slug = frontMatter["slug"] as? String ?? id
        let title = frontMatter["title"] as? String ?? ""
        let description = frontMatter["description"] as? String ?? ""
        let coverImage = frontMatter["coverImage"] as? String
        let template = frontMatter["template"] as? String

        return .init(
            slug: safeSlug(slug, prefix: config.blog.authors.slug),
            title: title,
            description: description,
            coverImage: coverImage,
            template: template,
            lastModification: lastModification,
            frontMatter: frontMatter,
            markdown: rawMarkdown.dropFrontMatter()
        )
    }

    func loadTag(
        config: Content.Config,
        url: URL
    ) throws -> Content.Tag {
        let id = String(url.lastPathComponent.dropLast(3))
        let lastModification = try fileManager.modificationDate(at: url)

        let rawMarkdown = try String(contentsOf: url)
        let frontMatter = try frontMatterParser.parse(markdown: rawMarkdown)

        let slug = frontMatter["slug"] as? String ?? id
        let title = frontMatter["title"] as? String ?? ""
        let description = frontMatter["description"] as? String ?? ""
        let coverImage = frontMatter["coverImage"] as? String
        let template = frontMatter["template"] as? String

        return .init(
            slug: safeSlug(slug, prefix: config.blog.tags.slug),
            title: title,
            description: description,
            coverImage: coverImage,
            template: template,
            lastModification: lastModification,
            frontMatter: frontMatter,
            markdown: rawMarkdown.dropFrontMatter()
        )
    }

    func loadPost(
        config: Content.Config,
        id: String,
        url: URL,
        formatter: DateFormatter
    ) throws -> Content.Post {
        let lastModification = try fileManager.modificationDate(at: url)

        let rawMarkdown = try String(contentsOf: url)
        let frontMatter = try frontMatterParser.parse(markdown: rawMarkdown)

        let slug = frontMatter["slug"] as? String ?? id
        let title = frontMatter["title"] as? String ?? ""
        let description = frontMatter["description"] as? String ?? ""
        let coverImage = frontMatter["coverImage"] as? String
        let template = frontMatter["template"] as? String
        
        let publication = frontMatter["publication"] as? String ?? ""
        let authors = frontMatter["authors"] as? [String] ?? []
        let tags = frontMatter["tags"] as? [String] ?? []
        let featured = frontMatter["featured"] as? Bool ?? false

        let date = formatter.date(from: publication) ?? Date()
        
        // TODO: use logger
        print("Invalid publication date for `\(slug)`.")

        return .init(
            slug: safeSlug(slug, prefix: config.blog.posts.slug),
            title: title,
            description: description,
            coverImage: coverImage,
            template: template,
            lastModification: lastModification,
            frontMatter: frontMatter,
            markdown: rawMarkdown.dropFrontMatter(),
            publication: date,
            authorSlugs: authors,
            tagSlugs: tags,
            featured: featured
        )
    }

    func loadPage(
        config: Content.Config,
        baseUrl: URL,
        url: URL
    ) throws -> Content.Page {
        let id = String(
            url
                .path
                .dropFirst(baseUrl.path.count + 1)
                .dropLast(3)
        )

        return try loadPage(
            at: url,
            with: id,
            using: config
        )
    }

    ///
    /// Load a page using an identifier and a url
    ///
    /// - Parameters:
    ///   - url: The url of the source markdown document
    ///   - id: The identifier of the page
    ///   - config: The site configuration
    /// - Throws: Error if the modification date or the front matter could not be fetched.
    /// - Returns: Returns a page content type
    ///
    func loadPage(
        at url: URL,
        with id: String,
        using config: Content.Config
    ) throws -> Content.Page {
        let lastModification = try fileManager.modificationDate(at: url)

        let markdown = try String(contentsOf: url)
        let frontMatter = try frontMatterParser.parse(markdown: markdown)

        let slug = frontMatter["slug"] as? String ?? id
        let title = frontMatter["title"] as? String ?? ""
        let description = frontMatter["description"] as? String ?? ""
        let coverImage = frontMatter["coverImage"] as? String
        let template = frontMatter["template"] as? String

        return .init(
            slug: safeSlug(slug, prefix: config.pages.slug),
            title: title,
            description: description,
            coverImage: coverImage,
            template: template,
            lastModification: lastModification,
            frontMatter: frontMatter,
            markdown: markdown.dropFrontMatter()
        )
    }

}
