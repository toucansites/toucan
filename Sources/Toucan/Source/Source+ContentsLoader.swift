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
            let extensions = ["md", "markdown"]
            var toProcess: [URL] = []
            let dirEnum = fileManager.enumerator(atPath: url.path)
            while let file = dirEnum?.nextObject() as? String {
                let url = url.appendingPathComponent(file)
                let ext = url.pathExtension.lowercased()
                guard extensions.contains(ext) else {
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
                let fileName = url.lastPathComponent
                let location = String(url.path.dropLast(fileName.count))
                let id = fileName.droppingEverythingAfterLastOccurrence(of: ".")
                let lastModification = try fileManager.modificationDate(at: url)
                
                let dirUrl = URL(fileURLWithPath: location)
                    
                let rawMarkdown = try String(contentsOf: url, encoding: .utf8)
                var frontMatter = try frontMatterParser.parse(markdown: rawMarkdown)
                
                for c in [id + ".yaml", id + ".yml"] {
                    let url = dirUrl.appendingPathComponent(c)
                    guard fileManager.fileExists(at: url) else {
                        continue
                    }
                    let yaml = try String(contentsOf: url, encoding: .utf8)
                    let fm = try frontMatterParser.load(yaml: yaml)
                    frontMatter = frontMatter.recursivelyMerged(with: fm)
                }
                
                let slug = frontMatter.string("slug") ?? id
                let title = frontMatter.string("title") ?? ""
                let description = frontMatter.string("description") ?? ""
                let image = frontMatter.string("image")
                let template = frontMatter.string("template")
                let assetsPath = frontMatter.string("assets.path")
                let userDefined = frontMatter.dict("userDefined")
                let redirects = frontMatter.value(
                    "redirects.from",
                    as: [String].self
                ) ?? []
                
                let assetsUrl = dirUrl
                    .appendingPathComponent(assetsPath ?? id)
                
                let styleCss = assetsUrl
                    .appendingPathComponent("style.css")
                
                let mainJs = assetsUrl
                    .appendingPathComponent("main.js")
                
                var css: [String] = []
                if fileManager.fileExists(at: styleCss) {
                    let cssFile = "./" + id + "/style.css"
                    css.append(cssFile)
                }
                let cssFiles = frontMatter.value(
                    "css",
                    as: [String].self
                ) ?? []
                css += cssFiles
                
                var js: [String] = []
                if fileManager.fileExists(at: mainJs) {
                    let jsFile = "./" + id + "/main.js"
                    js.append(jsFile)
                }

                let jsFiles = frontMatter.value(
                    "css",
                    as: [String].self
                ) ?? []
                js += jsFiles

//                print(id)
//                print(fileName)
//                print(slug)
//                print(location)
//                print(assetsFolder ?? id)
//                print("---")
                
                return .init(
                    location: .init(fileURLWithPath: location),
                    slug: slug.safeSlug(prefix: slugPrefix),
                    title: title,
                    description: description,
                    image: image,
                    css: css,
                    js: js,
                    template: template,
                    assetsPath: assetsPath ?? id,
                    lastModification: lastModification,
                    redirects: redirects,
                    userDefined: userDefined,
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
                    using: path
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
