//
//  File.swift
//
//
//  Created by Tibor Bodecs on 03/05/2024.
//

import Foundation
import FileManagerKit

extension String {

    func dropFrontMatter() -> String {
        if starts(with: "---") {
            return
                self
                .split(separator: "---")
                .dropFirst()
                .joined(separator: "---")
        }
        return self
    }
}

struct ContentLoader {

    let path: String

    // MARK: - private

    private func getMarkdownURLs(
        at url: URL,
        using fileManager: FileManager = .default
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

    func load() throws -> Site {

        let fileManager = FileManager.default
        let workUrl = URL(fileURLWithPath: path)
        let pagesUrl = workUrl.appendingPathComponent(Toucan.Directories.pages)
        let postsUrl = workUrl.appendingPathComponent(Toucan.Directories.posts)
        let authorsUrl = workUrl.appendingPathComponent(
            Toucan.Directories.authors
        )
        let tagsUrl = workUrl.appendingPathComponent(Toucan.Directories.tags)
        let siteUrl = workUrl.appendingPathComponent(Toucan.Files.site)

        let pageFiles = getMarkdownURLs(at: pagesUrl, using: fileManager)
        let postFiles = getMarkdownURLs(at: postsUrl, using: fileManager)
        let authorFiles = getMarkdownURLs(at: authorsUrl, using: fileManager)
        let tagFiles = getMarkdownURLs(at: tagsUrl, using: fileManager)

        let frontMatterParser = FrontMatterParser()

        /// load pages
        let pages = try pageFiles.map { url in
            let id = String(url.lastPathComponent.dropLast(3))
            let lastModification = try fileManager.modificationDate(at: url)

            let markdown = try String(contentsOf: url)
            let frontMatter = frontMatterParser.parse(markdown: markdown)

            let slug = frontMatter["slug"] ?? id
            let title = frontMatter["title"] ?? ""
            let description = frontMatter["description"] ?? ""
            let imageUrl = frontMatter["imageUrl"]

            return Page(
                id: id,
                slug: slug,
                meta: .init(
                    title: title,
                    description: description,
                    imageUrl: imageUrl
                ),
                lastModification: lastModification,
                frontMatter: frontMatter,
                markdown: markdown.dropFrontMatter()
            )
        }

        let formatter = DateFormatters().standard
        /// load posts
        let posts = try postFiles.map { url in
            let id = String(url.lastPathComponent.dropLast(3))
            let lastModification = try fileManager.modificationDate(at: url)

            let rawMarkdown = try String(contentsOf: url)
            let frontMatter = frontMatterParser.parse(markdown: rawMarkdown)

            let slug = frontMatter["slug"] ?? id
            let title = frontMatter["title"] ?? ""
            let description = frontMatter["description"] ?? ""
            let imageUrl = frontMatter["imageUrl"]

            let publication = frontMatter["publication"] ?? ""
            let authors = frontMatter["authors"] ?? ""
            let tags = frontMatter["tags"] ?? ""

            let authorIds =
                authors
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

            let tagIds =
                tags
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

            return Post(
                id: id,
                slug: slug,
                meta: .init(
                    title: title,
                    description: description,
                    imageUrl: imageUrl
                ),
                lastModification: lastModification,
                frontMatter: frontMatter,
                markdown: rawMarkdown.dropFrontMatter(),
                // TODO: proper error / fallback for publication date
                publication: formatter.date(from: publication) ?? .init(),
                authorIds: authorIds,
                tagIds: tagIds
            )
        }

        /// load authors
        let authors = try authorFiles.map { url in
            let id = String(url.lastPathComponent.dropLast(3))
            let lastModification = try fileManager.modificationDate(at: url)

            let rawMarkdown = try String(contentsOf: url)
            let frontMatter = frontMatterParser.parse(markdown: rawMarkdown)

            let slug = frontMatter["slug"] ?? id
            let title = frontMatter["title"] ?? ""
            let description = frontMatter["description"] ?? ""
            let imageUrl = frontMatter["imageUrl"]

            return Author(
                id: id,
                slug: slug,
                meta: .init(
                    title: title,
                    description: description,
                    imageUrl: imageUrl
                ),
                lastModification: lastModification,
                frontMatter: frontMatter,
                markdown: rawMarkdown.dropFrontMatter()
            )
        }

        /// load tags
        let tags = try tagFiles.map { url in
            let id = String(url.lastPathComponent.dropLast(3))
            let lastModification = try fileManager.modificationDate(at: url)

            let rawMarkdown = try String(contentsOf: url)
            let frontMatter = frontMatterParser.parse(markdown: rawMarkdown)

            let slug = frontMatter["slug"] ?? id
            let title = frontMatter["title"] ?? ""
            let description = frontMatter["description"] ?? ""
            let imageUrl = frontMatter["imageUrl"]

            return Tag(
                id: id,
                slug: slug,
                meta: .init(
                    title: title,
                    description: description,
                    imageUrl: imageUrl
                ),
                lastModification: lastModification,
                frontMatter: frontMatter,
                markdown: rawMarkdown.dropFrontMatter()
            )
        }

        let rawMarkdown = try String(contentsOf: siteUrl)
        let frontMatter = frontMatterParser.parse(markdown: rawMarkdown)

        let baseUrl = frontMatter["baseUrl"] ?? ""
        let title = frontMatter["title"] ?? ""
        let description = frontMatter["description"] ?? ""
        let language = frontMatter["language"]
        let rawPageLimit = frontMatter["pageLimit"] ?? ""

        return .init(
            baseUrl: baseUrl,
            title: title,
            description: description,
            language: language,
            pageLimit: Int(rawPageLimit),
            pages: pages,
            posts: posts,
            authors: authors,
            tags: tags
        )
    }
}
