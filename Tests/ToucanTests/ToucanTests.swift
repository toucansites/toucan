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
            image: "http://foo.jpg",
            language: "en_US",
            pages: [
                .init(
                    metatags: .init(
                        slug: "about",
                        title: "About us",
                        description: "Lorem ipsum",
                        image: "about.jpg"
                    )
                )
            ],
            posts: [
                .init(
                    metatags: .init(
                        slug: "foo",
                        title: "Foo",
                        description: "Foo",
                        image: "foo.jpg"
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
                        image: "tiborbodecs.jpg"
                    )
                )
            ],
            tags: [
                .init(
                    metatags: .init(
                        slug: "swift",
                        title: "Swift",
                        description: "Swift tag",
                        image: "swift.jpg"
                    )
                )
            ]
        )

        let slugs = site.metatags.map(\.slug).sorted()
        let uniqueSlugs = Array(Set(slugs)).sorted()

        XCTAssertEqual(slugs, uniqueSlugs)
    }

}
