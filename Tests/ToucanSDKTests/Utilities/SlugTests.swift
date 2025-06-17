//
//  SlugTests.swift
//  Toucan
//
//  Created by gerp83 on 2025. 04. 04..
//

import Testing
import ToucanSDK

@Suite
struct SlugTests {

    @Test
    func permalink() throws {
        let slug = Slug("slug")
        #expect(
            slug.permalink(
                baseURL: "http://localhost:3000"
            ) == "http://localhost:3000/slug/"
        )
    }

    @Test
    func permalinkForHomePage() throws {
        let slug = Slug("")
        #expect(
            slug.permalink(
                baseURL: "http://localhost:3000"
            ) == "http://localhost:3000/"
        )
    }
}
