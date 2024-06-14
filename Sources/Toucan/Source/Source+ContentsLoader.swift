//
//  File.swift
//
//
//  Created by Tibor Bodecs on 13/06/2024.
//

import Foundation
import FileManagerKit

/// An extension of the `Source` struct, providing a contents loader for loading markdown files and configuration.
///
/// The `ContentsLoader` is responsible for loading contents from a specified URL, parsing front matter, and managing files.
extension Source {

    /// A structure responsible for loading contents data.
    struct ContentsLoader {
        
        /// An enumeration representing possible errors that can occur while loading the content.
        enum Error: Swift.Error {
            /// Indicates an error related to a content.
            case content(Swift.Error)
        }

        /// The URL of the contents directory.
        let contentsUrl: URL
        /// The configuration for loading contents.
        let config: Config
        /// The file manager used for file operations.
        let fileManager: FileManager
        /// The front matter parser used for parsing markdown files.
        let frontMatterParser: FrontMatterParser

        // MARK: - Private Methods

        /// Retrieves all markdown file URLs at the specified directory URL.
        ///
        /// - Parameter url: The URL of the directory to search for markdown files.
        /// - Returns: An array of URLs pointing to markdown files within the directory.
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
        
        func loadContent(
            at url: URL,
            slugPrefix: String?
        ) throws(ContentsLoader.Error) -> Source.Content? {
            guard fileManager.fileExists(at: url) else {
                return nil
            }
            
            do {
                let id = String(url.lastPathComponent.dropLast(3))
                let lastModification = try fileManager.modificationDate(at: url)
                
                let rawMarkdown = try String(contentsOf: url)
                let frontMatter = try frontMatterParser.parse(markdown: rawMarkdown)
                
                let slug = frontMatter.string("slug") ?? id
                let title = frontMatter.string("title") ?? ""
                let description = frontMatter.string("description") ?? ""
                let coverImage = frontMatter.string("coverImage")
                let template = frontMatter.string("template")
                
                return .init(
                    slug: slug.safeSlug(prefix: slugPrefix),
                    title: title,
                    description: description,
                    coverImage: coverImage,
                    template: template,
                    assetsFolder: slug, // TODO: double check this
                    lastModification: lastModification,
                    frontMatter: frontMatter,
                    markdown: rawMarkdown.dropFrontMatter()
                )
            }
            catch {
                throw ContentsLoader.Error.content(error)
            }
        }
        
        func loadMainHomePageContent(
        ) throws(ContentsLoader.Error) -> Source.Content {
            let homePageUrl = markdownUrl(
                using: config.pages.main.home.path
            )
            // TODO: exception
            guard let home = try loadContent(at: homePageUrl, slugPrefix: nil) else {
                fatalError("Couldn't load not home page.")
            }
            return home.updated(slug: "")
        }
        
        func loadMainNotFoundPageContent(
        ) throws(ContentsLoader.Error) -> Source.Content {
            let notFoundPageUrl = markdownUrl(
                using: config.pages.main.notFound.path
            )
            // TODO: exception
            guard let notFound = try loadContent(at: notFoundPageUrl, slugPrefix: nil) else {
                fatalError("Couldn't load not found page.")
            }
            return notFound.updated(slug: "404")
        }
        
        func markdownUrl(
            using path: String
        ) -> URL {
            contentsUrl
                .appendingPathComponent(path)
                .appendingPathExtension("md")
        }
        
        func loadContent(
            using path: String,
            slugPrefix: String?
        ) throws(ContentsLoader.Error) -> Source.Content? {
            try loadContent(
                at: markdownUrl(
                    using: config.pages.blog.home.path
                ),
                slugPrefix: slugPrefix
            )
        }
        
        func loadContents(
            using config: Source.Config.ContentConfig
        ) throws(ContentsLoader.Error) -> [Source.Content] {
            let customPagesDirectoryUrl = contentsUrl
                .appendingPathComponent(config.folder)

            return getMarkdownURLs(
                at: customPagesDirectoryUrl
            ).compactMap {
                try? loadContent(at: $0, slugPrefix: config.slugPrefix)
            }
        }
        
        // MARK: -
        
        func loadBlogContents(
        ) throws(ContentsLoader.Error) -> Source.Contents.Blog {
            .init(
                authors: try loadContents(
                    using: config.contents.blog.authors
                ),
                tags: try loadContents(
                    using: config.contents.blog.tags
                ),
                posts: try loadContents(
                    using: config.contents.blog.posts
                )
            )
        }
        
        func loadDocsContents(
        ) throws(ContentsLoader.Error) -> Source.Contents.Docs {
            .init(
                categories: try loadContents(
                    using: config.contents.docs.categories
                ),
                guides: try loadContents(
                    using: config.contents.docs.guides
                )
            )
        }

        func loadPagesContents(
        ) throws(ContentsLoader.Error) -> Source.Contents.Pages {
            
            let mainHomePage = try loadMainHomePageContent()
            let mainNotFoundPage = try loadMainNotFoundPageContent()
            
            let blogHomePage = try loadContent(
                using: config.pages.blog.home.path,
                slugPrefix: nil
            )
            let blogAuthorsPage = try loadContent(
                using: config.pages.blog.authors.path,
                slugPrefix: nil
            )
            let blogTagsPage = try loadContent(
                using: config.pages.blog.tags.path,
                slugPrefix: nil
            )
            let blogPostsPage = try loadContent(
                using: config.pages.blog.posts.path,
                slugPrefix: nil
            )
            let docsHomePage = try loadContent(
                using: config.pages.docs.home.path,
                slugPrefix: nil
            )
            let docsCategoriesPage = try loadContent(
                using: config.pages.docs.categories.path,
                slugPrefix: nil
            )
            let docsGuidesPage = try loadContent(
                using: config.pages.docs.guides.path,
                slugPrefix: nil
            )

            return .init(
                main: .init(
                    home: mainHomePage,
                    notFound: mainNotFoundPage
                ),
                blog: .init(
                    home: blogHomePage,
                    authors: blogAuthorsPage,
                    tags: blogTagsPage,
                    posts: blogPostsPage
                ),
                docs: .init(
                    home: docsHomePage,
                    categories: docsCategoriesPage,
                    guides: docsGuidesPage
                ),
                custom: try loadContents(
                    using: config.contents.pages.custom
                )
            )
        }
        
        /// Loads the contents asynchronously.
        ///
        /// - Returns: A `Contents` object containing the loaded contents.
        /// - Throws: An error if loading the contents fails.
        func load(
        ) throws -> Contents {
            .init(
                blog: try loadBlogContents(),
                docs: try loadDocsContents(),
                pages: try loadPagesContents()
            )
        }
        
    }
}
