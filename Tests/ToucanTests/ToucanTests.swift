//
//  File.swift
//
//
//  Created by Tibor Bodecs on 03/05/2024.
//

import XCTest
@testable import Toucan

final class ToucanTests: XCTestCase {

    func testSiteStructure() throws {

        let site = Site(
            baseUrl: "https://binarybirds.com",
            title: "Binary Birds",
            description: "The official site",
            language: "en_US",
            pages: [
                .init(
                    id: "about",
                    slug: "about",
                    meta: .init(
                        title: "About us",
                        description: "Lorem ipsum",
                        imageUrl: "about.jpg"
                    ),
                    publication: Date(),
                    lastModification: Date(),
                    variables: [:],
                    markdown: ""
                )
            ],
            posts: [
                .init(
                    id: "foo",
                    slug: "foo",
                    meta: .init(
                        title: "Foo",
                        description: "Foo",
                        imageUrl: "foo.jpg"
                    ),
                    publication: Date(),
                    lastModification: Date(),
                    variables: [:],
                    markdown: "",
                    authorIds: [
                        "tiborbodecs"
                    ],
                    tagIds: [
                        "swift"
                    ]
                )
            ],
            authors: [
                .init(
                    id: "tiborbodecs",
                    slug: "tibor-bodecs",
                    meta: .init(
                        title: "Tibor Bödecs",
                        description: "about the author",
                        imageUrl: "tiborbodecs.jpg"
                    ),
                    publication: Date(),
                    lastModification: Date(),
                    variables: [:],
                    markdown: ""
                )
            ],
            tags: [
                .init(
                    id: "swift",
                    slug: "swift",
                    meta: .init(
                        title: "Swift",
                        description: "Swift tag",
                        imageUrl: "swift.jpg"
                    ),
                    publication: Date(),
                    lastModification: Date(),
                    variables: [:],
                    markdown: ""
                )
            ]
        )

        let contentSlugs = site.contents.map(\.slug).sorted()
        let uniqueContentSlugs = Array(Set(contentSlugs)).sorted()

        XCTAssertEqual(contentSlugs, uniqueContentSlugs)
    }

}
