//
//  MarkdownParserTestSuite.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 04. 15..
//
import Testing
import Logging
import ToucanCore
import ToucanSerialization
@testable import ToucanSource

@Suite
struct MarkdownParserTestSuite {

    @Test
    func basicParserLogic() throws {
        let logger: Logger = .init(label: "MarkdownParserTestSuite")
        let input = #"""
            ---
            slug: lorem-ipsum
            title: Lorem ipsum
            ---

            Lorem ipsum dolor sit amet.
            """#

        let parser = MarkdownParser(
            decoder: ToucanYAMLDecoder(),
            logger: logger
        )
        let markdown = try parser.parse(input)

        #expect(markdown.frontMatter["slug"] == .init("lorem-ipsum"))
        #expect(markdown.frontMatter["title"] == .init("Lorem ipsum"))
    }

    @Test
    func frontMatterNoContent() throws {
        let logger: Logger = .init(label: "MarkdownParserTestSuite")
        let input = #"""
            ---
            slug: lorem-ipsum
            title: Lorem ipsum
            ---
            """#

        let parser = MarkdownParser(
            decoder: ToucanYAMLDecoder(),
            logger: logger
        )
        let markdown = try parser.parse(input)

        #expect(markdown.frontMatter["slug"] == .init("lorem-ipsum"))
        #expect(markdown.frontMatter["title"] == .init("Lorem ipsum"))
    }

    @Test
    func frontMatterWithSeparatorInContent() throws {
        let logger: Logger = .init(label: "MarkdownParserTestSuite")
        let input = #"""
            ---
            slug: lorem-ipsum
            title: Lorem ipsum
            ---

            Text with '---' separator as content
            """#

        let parser = MarkdownParser(
            decoder: ToucanYAMLDecoder(),
            logger: logger
        )
        let markdown = try parser.parse(input)

        #expect(markdown.frontMatter["slug"] == .init("lorem-ipsum"))
        #expect(markdown.frontMatter["title"] == .init("Lorem ipsum"))
    }

    @Test
    func firstMissingSeparator() throws {
        let logger: Logger = .init(label: "MarkdownParserTestSuite")
        let input = #"""
            slug: lorem-ipsum
            title: Lorem ipsum
            ---

            Lorem ipsum dolor sit amet.
            """#

        let parser = MarkdownParser(
            decoder: ToucanYAMLDecoder(),
            logger: logger
        )
        let markdown = try parser.parse(input)

        #expect(markdown.frontMatter.isEmpty)
    }

    @Test
    func firstMissingSeparatorWithSeparatorInContent() throws {
        let logger: Logger = .init(label: "MarkdownParserTestSuite")
        let input = #"""
            slug: lorem-ipsum
            title: Lorem ipsum
            ---

            Text with '---' separator as content
            """#

        let parser = MarkdownParser(
            decoder: ToucanYAMLDecoder(),
            logger: logger
        )
        let markdown = try parser.parse(input)

        #expect(markdown.frontMatter.isEmpty)
    }

    @Test
    func secondMissingSeparator() throws {
        let logger: Logger = .init(label: "MarkdownParserTestSuite")
        let input = #"""
            ---
            slug: lorem-ipsum
            title: Lorem ipsum

            Lorem ipsum dolor sit amet.
            """#

        let parser = MarkdownParser(
            decoder: ToucanYAMLDecoder(),
            logger: logger
        )

        do {
            let _ = try parser.parse(input)
        }
        catch let error as ToucanError {
            if let decodingError = error.lookup(DecodingError.self) {
                switch decodingError {
                case .dataCorrupted(let context):
                    let expected = "The given data was not valid YAML."
                    #expect(context.debugDescription == expected)
                default:
                    throw error
                }
            }
            else {
                throw error
            }
        }
    }

    @Test
    func secondMissingSeparatorWithSeparatorInContent() throws {
        let logger: Logger = .init(label: "MarkdownParserTestSuite")
        let input = #"""
            ---
            slug: lorem-ipsum
            title: Lorem ipsum

            Text with '---' separator as content
            """#

        let parser = MarkdownParser(
            decoder: ToucanYAMLDecoder(),
            logger: logger
        )

        do {
            let _ = try parser.parse(input)
        }
        catch let error as ToucanError {
            if let context = error.lookup({
                if case DecodingError.dataCorrupted(let ctx) = $0 {
                    return ctx
                }
                return nil
            }) {
                let expected = "The given data was not valid YAML."
                #expect(context.debugDescription == expected)
            }
            else {
                throw error
            }
        }
    }

    @Test
    func withManySeparators() throws {
        let logger: Logger = .init(label: "MarkdownParserTestSuite")
        let input = #"""
            --- --- ---
            slug: lorem-ipsum
            title: Lorem ipsum
            --- --- ---

            Text with '---' separator as content
            """#

        let parser = MarkdownParser(
            decoder: ToucanYAMLDecoder(),
            logger: logger
        )

        do {
            let _ = try parser.parse(input)
        }
        catch let error as ToucanError {
            if let context = error.lookup({
                if case DecodingError.typeMismatch(_, let ctx) = $0 {
                    return ctx
                }
                return nil
            }) {
                let exp = "Expected to decode Mapping but found Node instead."
                #expect(context.debugDescription == exp)
            }
            else {
                throw error
            }
        }
    }

}
