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

        let workUrl = URL(filePath: path)
        let pagesUrl = workUrl.appending(path: "pages")
        let postsUrl = workUrl.appending(path: "posts")
        let authorsUrl = workUrl.appending(path: "authors")
        let tagsUrl = workUrl.appending(path: "tags")
        let indexUrl = workUrl.appending(path: "index.md")

        let pageFiles = listMarkdownFiles(at: pagesUrl)
        let postFiles = listMarkdownFiles(at: postsUrl)
        let authorFiles = listMarkdownFiles(at: authorsUrl)
        let tagFiles = listMarkdownFiles(at: tagsUrl)

        let metadataParser = MetadataParser()
        var pages: [Page] = []
        for file in pageFiles {
            let slug = String(file.dropLast(3))  // drop .md extension
            let url = pagesUrl.appending(path: file)
            let markdown = try String(contentsOf: url)
            let metadata = metadataParser.parse(markdown: markdown)

            let page = Page(
                metatags: .init(
                    slug: slug,
                    title: "",
                    description: "",
                    image: ""
                )
            )
            pages.append(page)
        }

        return .init(
            baseUrl: "",
            name: "",
            description: "",
            image: "",
            language: "",
            pages: pages,
            posts: [],
            authors: [],
            tags: []
        )
    }
}
