//
//  File.swift
//
//
//  Created by Tibor Bodecs on 03/05/2024.
//

struct Site {

    let baseUrl: String
    let title: String
    let description: String
    let language: String?

    let pages: [Page]
    let posts: [Post]
    let authors: [Author]
    let tags: [Tag]
}

extension Site {

    var contents: [ContentType] {
        pages + posts + authors + tags
    }

    func permalink(_ value: String) -> String {
        let uncheckedValue = baseUrl + value
        if uncheckedValue.hasSuffix("/") {
            return uncheckedValue
        }
        return uncheckedValue + "/"
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

}
