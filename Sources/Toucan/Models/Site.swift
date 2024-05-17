//
//  File.swift
//
//
//  Created by Tibor Bodecs on 03/05/2024.
//

import Algorithms

struct Site {

    let baseUrl: String
    let title: String
    let description: String
    let language: String?
    let pageLimit: Int

    let pages: [Page]
    let posts: [Post]
    let authors: [Author]
    let tags: [Tag]

    init(
        baseUrl: String,
        title: String,
        description: String,
        language: String? = nil,
        pageLimit: Int? = nil,
        pages: [Page],
        posts: [Post],
        authors: [Author],
        tags: [Tag]
    ) {
        var baseUrl = baseUrl
        if !baseUrl.hasSuffix("/") {
            baseUrl += "/"
        }
        self.baseUrl = baseUrl
        self.title = title
        self.description = description
        self.language = language
        self.pageLimit = pageLimit ?? 10

        self.pages = pages.sorted { $0.meta.title > $1.meta.title }
        self.posts = posts.sorted { $0.publication > $1.publication }
        self.authors = authors.sorted { $0.meta.title > $1.meta.title }
        self.tags = tags.sorted { $0.meta.title > $1.meta.title }
    }
}

extension Site {

    var contents: [Content] {
        pages + posts + authors + tags
    }

    var systemPageIds: [String] {
        ["home", "404", "authors", "posts", "tags"]
    }

    var customPages: [Page] {
        pages.filter { !systemPageIds.contains($0.id) }
    }

    var systemPages: [Page] {
        pages.filter { systemPageIds.contains($0.id) }
    }

    var postChunks: ChunksOfCountCollection<[Post]> {
        posts.chunks(ofCount: pageLimit)
    }

    func permalink(_ value: String) -> String {
        let components = value.split(separator: "/").map(String.init)
        if components.isEmpty {
            return baseUrl
        }
        if components.last?.split(separator: ".").count ?? 0 > 1 {
            return baseUrl + components.joined(separator: "/")
        }
        return baseUrl + components.joined(separator: "/") + "/"
    }

    func postsBy(tagId: String) -> [Post] {
        posts.filter { $0.tagIds.contains(tagId) }
    }

    func postsBy(authorId: String) -> [Post] {
        posts.filter { $0.authorIds.contains(authorId) }
    }

    func page(id: String) -> Page? {
        pages.filter { $0.id == id }.first
    }
    
    func authorsBy(ids: [String]) -> [Author] {
        authors.filter { ids.contains($0.id) }
    }

    func tagsBy(ids: [String]) -> [Tag] {
        tags.filter { ids.contains($0.id) }
    }

}
