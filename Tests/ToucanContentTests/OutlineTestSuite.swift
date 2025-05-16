//
//  OutlineTestSuite.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 02. 20..

import Testing

@testable import ToucanContent

@Suite
struct ToucanToCTestSuite {

    @Test
    func withoutFragments() async throws {

        let html = #"""
            <h1>Lorem ipsum</h1>
            <p>lorem ipsum dolor sit amet</p>

                <h2>Dolor sit</h2>
                <p>lorem ipsum dolor sit amet</p>
                
                    <h3>Amet</h3>
                    <p>lorem ipsum dolor sit amet</p>
                
                <h2>Hello world</h2>
                <p>lorem ipsum dolor sit amet</p>
                
                    <h3>foo, bar, baz</h3>
                    <p>lorem ipsum dolor sit amet</p>
            """#

        let parser = OutlineParser(levels: [2, 3])

        let toc = parser.parseHTML(html)
        #expect(toc.count == 4)
    }

    @Test
    func example() async throws {

        let html = #"""
            <h1>Lorem ipsum</h1>
            <p>lorem ipsum dolor sit amet</p>

                <h2 id="dolor-sit">Dolor sit</h2>
                <p>lorem ipsum dolor sit amet</p>
                
                    <h3 id="amet">Amet</h3>
                    <p>lorem ipsum dolor sit amet</p>
                
                <h2 id="hello-world">Hello world</h2>
                <p>lorem ipsum dolor sit amet</p>
                
                    <h3 id="foo-bar-baz">foo, bar, baz</h3>
                    <p>lorem ipsum dolor sit amet</p>
            """#

        let parser = OutlineParser()

        let toc = parser.parseHTML(html)
        #expect(toc.count == 5)
    }
}
