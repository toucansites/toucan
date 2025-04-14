import Testing
import Logging
@testable import ToucanSDK
@testable import ToucanSource

@Suite
struct FrontMatterParserTestSuite {

    @Test
    func basicParserLogic() throws {
        let logger: Logger = .init(label: "FrontMatterParserTestSuite")
        let input = #"""
            ---
            slug: lorem-ipsum
            title: Lorem ipsum
            ---

            Lorem ipsum dolor sit amet.
            """#

        let parser = FrontMatterParser(
            decoder: ToucanYAMLDecoder(),
            logger: logger
        )
        let metadata = try parser.parse(input)

        #expect(metadata["slug"] == .init("lorem-ipsum"))
        #expect(metadata["title"] == .init("Lorem ipsum"))
    }

    @Test
    func frontMatterNoContent() throws {
        let logger: Logger = .init(label: "FrontMatterParserTestSuite")
        let input = #"""
            ---
            slug: lorem-ipsum
            title: Lorem ipsum
            ---
            """#

        let parser = FrontMatterParser(
            decoder: ToucanYAMLDecoder(),
            logger: logger
        )
        let metadata = try parser.parse(input)

        #expect(metadata["slug"] == .init("lorem-ipsum"))
        #expect(metadata["title"] == .init("Lorem ipsum"))
    }

    @Test
    func frontMatterWithSeparatorInContent() throws {
        let logger: Logger = .init(label: "FrontMatterParserTestSuite")
        let input = #"""
            ---
            slug: lorem-ipsum
            title: Lorem ipsum
            ---

            Text with '---' separator as content
            """#

        let parser = FrontMatterParser(
            decoder: ToucanYAMLDecoder(),
            logger: logger
        )
        let metadata = try parser.parse(input)

        #expect(metadata["slug"] == .init("lorem-ipsum"))
        #expect(metadata["title"] == .init("Lorem ipsum"))
    }

    @Test
    func firstMissingSeparator() throws {
        let logger: Logger = .init(label: "FrontMatterParserTestSuite")
        let input = #"""
            slug: lorem-ipsum
            title: Lorem ipsum
            ---

            Lorem ipsum dolor sit amet.
            """#

        let parser = FrontMatterParser(
            decoder: ToucanYAMLDecoder(),
            logger: logger
        )
        let metadata = try parser.parse(input)

        #expect(metadata.isEmpty)
    }

    @Test
    func firstMissingSeparatorWithSeparatorInContent() throws {
        let logger: Logger = .init(label: "FrontMatterParserTestSuite")
        let input = #"""
            slug: lorem-ipsum
            title: Lorem ipsum
            ---

            Text with '---' separator as content
            """#

        let parser = FrontMatterParser(
            decoder: ToucanYAMLDecoder(),
            logger: logger
        )
        let metadata = try parser.parse(input)

        #expect(metadata.isEmpty)
    }

    @Test
    func secondMissingSeparator() throws {
        let logger: Logger = .init(label: "FrontMatterParserTestSuite")
        let input = #"""
            ---
            slug: lorem-ipsum
            title: Lorem ipsum

            Lorem ipsum dolor sit amet.
            """#

        let parser = FrontMatterParser(
            decoder: ToucanYAMLDecoder(),
            logger: logger
        )
        let metadata = try parser.parse(input)

        #expect(metadata.isEmpty)
    }

    @Test
    func secondMissingSeparatorWithSeparatorInContent() throws {
        let logger: Logger = .init(label: "FrontMatterParserTestSuite")
        let input = #"""
            ---
            slug: lorem-ipsum
            title: Lorem ipsum

            Text with '---' separator as content
            """#

        let parser = FrontMatterParser(
            decoder: ToucanYAMLDecoder(),
            logger: logger
        )
        let metadata = try parser.parse(input)

        #expect(metadata.isEmpty)
    }

    @Test
    func withManySeparators() throws {
        let logger: Logger = .init(label: "FrontMatterParserTestSuite")
        let input = #"""
            --- --- ---
            slug: lorem-ipsum
            title: Lorem ipsum
            --- --- ---

            Text with '---' separator as content
            """#

        let parser = FrontMatterParser(
            decoder: ToucanYAMLDecoder(),
            logger: logger
        )
        let metadata = try parser.parse(input)

        #expect(metadata.isEmpty)
    }

}
