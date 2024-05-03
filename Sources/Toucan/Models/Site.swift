//
//  File.swift
//
//
//  Created by Tibor Bodecs on 03/05/2024.
//

struct Site {

    let baseUrl: String
    let name: String
    let description: String
    let image: String
    let language: String

    let pages: [Page]
    let posts: [Post]
    let authors: [Author]
    let tags: [Tag]
}

extension Site {

    var metatags: [Metatags] {
        pages.map(\.metatags) + posts.map(\.metatags) + authors.map(\.metatags)
            + tags.map(\.metatags)
    }
}
