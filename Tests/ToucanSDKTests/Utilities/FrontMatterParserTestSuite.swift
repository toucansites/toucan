import Testing
@testable import ToucanSDK

@Suite
struct FrontMatterParserTestSuite {

    @Test
    func basicParserLogic() throws {

        let input = #"""
            ---
            slug: lorem-ipsum
            title: Lorem ipsum
            tags: foo, bar, baz
            ---

            Lorem ipsum dolor sit amet.
            """#

        let parser = FrontMatterParser()
        let metadata = try parser.parse(markdown: input) as? [String: String]

        let expectation: [String: String] = [
            "slug": "lorem-ipsum",
            "title": "Lorem ipsum",
            "tags": "foo, bar, baz",
        ]

        #expect(metadata == expectation)
    }

}
