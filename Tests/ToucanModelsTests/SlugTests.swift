//
//  SlugTests.swift
//
//  Created by gerp83 on 2025. 04. 04.
//
    
import Testing
@testable import ToucanModels

@Suite
struct SlugTests {
    
    @Test
    func testPathResolve() throws {
        let slug = Slug(value: "slug")
        #expect(slug.resolveForPath() == "slug")
    }

    @Test
    func testHomePathResolve() throws {
        let slug = Slug(value: "")
        #expect(slug.resolveForPath() == "home")
    }
    
    @Test
    func testExtractIteratorId() throws {
        let slug = Slug(value: "posts/page/{{post.pagination}}")
        #expect(slug.extractIteratorId() == "post.pagination")
    }
    
    @Test
    func testExtractNoneIteratorId() throws {
        let slug = Slug(value: "slugWithNoPagination")
        #expect(slug.extractIteratorId() == nil)
    }
    
    @Test
    func testPermalink() throws {
        let slug = Slug(value: "slug")
        #expect(slug.permalink(baseUrl: "http://localhost:3000") == "http://localhost:3000/slug/")
    }
    
}
