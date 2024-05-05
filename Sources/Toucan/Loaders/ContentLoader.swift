//
//  File.swift
//
//
//  Created by Tibor Bodecs on 03/05/2024.
//

import Foundation
import FileManagerKit

struct ContentLoader {

    let path: String

    private func listMarkdownFiles(at url: URL) -> [String] {
        FileManager
            .default
            .listDirectory(at: url)
            .filter { $0.hasSuffix(".md") }
    }

    func load() throws -> Site {

        let workUrl = URL(fileURLWithPath: path)
        let pagesUrl = workUrl.appendingPathComponent("pages")
        let postsUrl = workUrl.appendingPathComponent("posts")
        let authorsUrl = workUrl.appendingPathComponent("authors")
        let tagsUrl = workUrl.appendingPathComponent("tags")
        let indexUrl = workUrl.appendingPathComponent("index.md")

        let pageFiles = listMarkdownFiles(at: pagesUrl)
        let postFiles = listMarkdownFiles(at: postsUrl)
        let authorFiles = listMarkdownFiles(at: authorsUrl)
        let tagFiles = listMarkdownFiles(at: tagsUrl)

        let metadataParser = MetadataParser()

        /// load pages
        let pages = try pageFiles.map { file in
            let slug = String(file.dropLast(3))  // drop .md extension
            let url = pagesUrl.appendingPathComponent(file)
            let markdown = try String(contentsOf: url)
            let metadata = metadataParser.parse(markdown: markdown)

            let title = metadata["title"] ?? ""
            let description = metadata["description"] ?? ""
            let imageUrl = metadata["imageUrl"]

            return Page(
                metatags: .init(
                    slug: slug,
                    title: title,
                    description: description,
                    imageUrl: imageUrl
                )
            )
        }

        /// load posts
        let posts = try postFiles.map { file in
            let slug = String(file.dropLast(3))  // drop .md extension
            let url = postsUrl.appendingPathComponent(file)
            let markdown = try String(contentsOf: url)
            let metadata = metadataParser.parse(markdown: markdown)

            let title = metadata["title"] ?? ""
            let description = metadata["description"] ?? ""
            let imageUrl = metadata["imageUrl"]

            let authors = metadata["authors"]
            let tags = metadata["tags"]

            return Post(
                metatags: .init(
                    slug: slug,
                    title: title,
                    description: description,
                    imageUrl: imageUrl
                ),
                authors: [],
                tags: []
            )
        }

        /// load authors
        let authors = try authorFiles.map { file in
            let slug = String(file.dropLast(3))  // drop .md extension
            let url = authorsUrl.appendingPathComponent(file)
            let markdown = try String(contentsOf: url)
            let metadata = metadataParser.parse(markdown: markdown)

            let title = metadata["title"] ?? ""
            let description = metadata["description"] ?? ""
            let imageUrl = metadata["imageUrl"]

            return Author(
                metatags: .init(
                    slug: slug,
                    title: title,
                    description: description,
                    imageUrl: imageUrl
                )
            )
        }

        /// load tags
        let tags = try tagFiles.map { file in
            let slug = String(file.dropLast(3))  // drop .md extension
            let url = tagsUrl.appendingPathComponent(file)
            let markdown = try String(contentsOf: url)
            let metadata = metadataParser.parse(markdown: markdown)

            let title = metadata["title"] ?? ""
            let description = metadata["description"] ?? ""
            let imageUrl = metadata["imageUrl"]

            return Tag(
                metatags: .init(
                    slug: slug,
                    title: title,
                    description: description,
                    imageUrl: imageUrl
                )
            )
        }

        let markdown = try String(contentsOf: indexUrl)
        let metadata = metadataParser.parse(markdown: markdown)

        let baseUrl = metadata["baseUrl"] ?? ""
        let name = metadata["name"] ?? ""
        let description = metadata["description"] ?? ""
        let imageUrl = metadata["imageUrl"]
        let language = metadata["language"]

        return .init(
            baseUrl: baseUrl,
            name: name,
            description: description,
            imageUrl: imageUrl,
            language: language,
            pages: pages,
            posts: posts,
            authors: authors,
            tags: tags
        )
    }
}
