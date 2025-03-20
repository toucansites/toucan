import Testing
@testable import ToucanSDK
@testable import ToucanSource

@Suite
struct FrontMatterParserTestSuite {

    @Test
    func basicParserLogic() throws {
        
        let input = #"""
                ---
                slug: lorem-ipsum
                title: Lorem ipsum
                ---
                
                Lorem ipsum dolor sit amet.
                """#
        
        let parser = FrontMatterParser(decoder: ToucanYAMLDecoder())
        let metadata = try parser.parse(input)
        
        #expect(metadata["slug"] == .init("lorem-ipsum"))
        #expect(metadata["title"] == .init("Lorem ipsum"))
    }
}
