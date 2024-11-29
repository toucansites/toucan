//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2024. 10. 13..
//

import Foundation

@testable import ToucanSDK

extension PageBundle {

    static let post1 = PageBundle(
        id: "post-1",
        url: URL(fileURLWithPath: "/"),
        baseUrl: "http://localhost:3000",
        slug: "post-1",
        permalink: "post-1",
        title: "Post 1",
        description: "Post 1 description",
        date: .init(
            html: "",
            rss: "",
            sitemap: ""
        ),
        contentType: .post,
        publication: .init(),
        lastModification: .init(),
        config: .init(
            slug: nil,
            type: nil,
            title: nil,
            description: nil,
            image: nil,
            assets: .init(folder: ""),
            template: nil,
            output: nil,
            draft: false,
            publication: nil,
            expiration: nil,
            noindex: false,
            canonical: nil,
            hreflang: [],
            redirects: [],
            css: [],
            js: [],
            userDefined: [:]
        ),
        frontMatter: [
            "featured": true,
            "authors": ["author-1"],
        ],
        properties: [:],
        relations: [:],
        markdown: "",
        assets: []
    )

    static let author1 = PageBundle(
        id: "author-1",
        url: URL(fileURLWithPath: "/"),
        baseUrl: "http://localhost:3000",
        slug: "author-1",
        permalink: "author-1",
        title: "Author 1",
        description: "Author 1 description",
        date: .init(
            html: "",
            rss: "",
            sitemap: ""
        ),
        contentType: .author,
        publication: .init(),
        lastModification: .init(),
        config: .init(
            slug: nil,
            type: nil,
            title: nil,
            description: nil,
            image: nil,
            assets: .init(folder: ""),
            template: nil,
            output: nil,
            draft: false,
            publication: nil,
            expiration: nil,
            noindex: false,
            canonical: nil,
            hreflang: [],
            redirects: [],
            css: [],
            js: [],
            userDefined: [:]
        ),
        frontMatter: [:],
        properties: [:],
        relations: [:],
        markdown: "",
        assets: []
    )

    static let page1 = PageBundle(
        id: "page-1",
        url: URL(fileURLWithPath: "/"),
        baseUrl: "http://localhost:3000",
        slug: "page-1",
        permalink: "page-1",
        title: "Page 1",
        description: "Page 1 description",
        date: .init(
            html: "",
            rss: "",
            sitemap: ""
        ),
        contentType: .default,
        publication: .init(),
        lastModification: .init(),
        config: .init([:]),
        frontMatter: [:],
        properties: [:],
        relations: [:],
        markdown: "",
        assets: []
    )
}
