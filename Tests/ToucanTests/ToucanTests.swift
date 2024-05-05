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
            name: "Binary Birds",
            description: "Lorem ipsum",
            imageUrl: "http://foo.jpg",
            language: "en_US",
            pages: [
                .init(
                    metatags: .init(
                        slug: "about",
                        title: "About us",
                        description: "Lorem ipsum",
                        imageUrl: "about.jpg"
                    )
                )
            ],
            posts: [
                .init(
                    metatags: .init(
                        slug: "foo",
                        title: "Foo",
                        description: "Foo",
                        imageUrl: "foo.jpg"
                    ),
                    authors: [
                        "tiborbodecs"
                    ],
                    tags: [
                        "swift"
                    ]
                )
            ],
            authors: [
                .init(
                    metatags: .init(
                        slug: "tiborbodecs",
                        title: "Tibor Bödecs",
                        description: "about the author",
                        imageUrl: "tiborbodecs.jpg"
                    )
                )
            ],
            tags: [
                .init(
                    metatags: .init(
                        slug: "swift",
                        title: "Swift",
                        description: "Swift tag",
                        imageUrl: "swift.jpg"
                    )
                )
            ]
        )

        let slugs = site.metatags.map(\.slug).sorted()
        let uniqueSlugs = Array(Set(slugs)).sorted()

        XCTAssertEqual(slugs, uniqueSlugs)
    }

}
