//
//  File.swift
//
//
//  Created by Tibor Bodecs on 03/05/2024.
//

struct Site {

    let baseUrl: String
    let name: String
    let tagline: String
    let imageUrl: String?
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
}
