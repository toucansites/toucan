//
//  File.swift
//
//
//  Created by Tibor Bodecs on 03/05/2024.
//

import XCTest
@testable import Toucan

final class SiteGeneratorTests: XCTestCase {

    func testSiteStructure() throws {

        //        let site = Site(
        //            baseUrl: "https://binarybirds.com",
        //            title: "Binary Birds",
        //            description: "The official site",
        //            language: "en_US",
        //            pageLimit: 10,
        //            pages: [
        //                .init(
        //                    id: "about",
        //                    slug: "about",
        //                    title: "About us",
        //                    description: "Lorem ipsum",
        //                    coverImage: "./about/about.jpg",
        //                    template: nil,
        //                    lastModification: Date(),
        //                    frontMatter: [:],
        //                    markdown: ""
        //                )
        //            ],
        //            posts: [
        //                .init(
        //                    id: "foo",
        //                    slug: "foo",
        //                    title: "Foo",
        //                    description: "Foo",
        //                    coverImage: "./foo/foo.jpg",
        //                    template: nil,
        //                    lastModification: Date(),
        //                    frontMatter: [:],
        //                    markdown: "",
        //                    publication: Date(),
        //                    authorIds: [
        //                        "tiborbodecs"
        //                    ],
        //                    tagIds: [
        //                        "swift"
        //                    ]
        //                )
        //            ],
        //            authors: [
        //                .init(
        //                    id: "tiborbodecs",
        //                    slug: "tibor-bodecs",
        //                    title: "Tibor Bödecs",
        //                    description: "about the author",
        //                    coverImage: "./tiborbodecs/tiborbodecs.jpg",
        //                    template: nil,
        //                    lastModification: Date(),
        //                    frontMatter: [:],
        //                    markdown: ""
        //                )
        //            ],
        //            tags: [
        //                .init(
        //                    id: "swift",
        //                    slug: "swift",
        //                    title: "Swift",
        //                    description: "Swift tag",
        //                    coverImage: "./swift/swift.jpg",
        //                    template: nil,
        //                    lastModification: Date(),
        //                    frontMatter: [:],
        //                    markdown: ""
        //                )
        //            ]
        //        )
        //
        //        let contentSlugs = site.contents.map(\.slug).sorted()
        //        let uniqueContentSlugs = Array(Set(contentSlugs)).sorted()
        //
        //        XCTAssertEqual(contentSlugs, uniqueContentSlugs)
    }

}
