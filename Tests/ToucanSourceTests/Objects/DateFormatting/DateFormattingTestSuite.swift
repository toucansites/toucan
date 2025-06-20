//
//  DateFormattingTestSuite.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 28..
//

import Foundation
import Testing
import ToucanSerialization
@testable import ToucanSource

@Suite
struct DateFormattingTestSuite {
    @Test
    func decodeFullSpec() throws {
        let yaml = """
            locale: "fr_FR"
            timeZone: "Europe/Budapest"
            format: "yyyy-MM-dd"
            """
        let decoder = ToucanYAMLDecoder()
        let options = try decoder.decode(
            DateFormatterConfig.self,
            from: yaml
        )
        #expect(options.localization.locale == "fr_FR")
        #expect(options.localization.timeZone == "Europe/Budapest")
        #expect(options.format == "yyyy-MM-dd")
    }

    @Test
    func decodeDefaultValues() throws {
        let yaml = """
            format: "MM/dd/yyyy"
            """
        let decoder = ToucanYAMLDecoder()
        let options = try decoder.decode(
            DateFormatterConfig.self,
            from: yaml
        )
        #expect(
            options.localization.locale
                == DateLocalization.defaults.locale
        )
        #expect(
            options.localization.timeZone
                == DateLocalization.defaults.timeZone
        )
        #expect(options.format == "MM/dd/yyyy")
    }

    @Test
    func encodeProducesExpectedYAML() throws {
        let options = DateFormatterConfig(
            localization: DateLocalization(
                locale: "de_DE",
                timeZone: "Europe/Berlin"
            ),
            format: "dd.MM.yyyy"
        )
        let encoder = ToucanYAMLEncoder()
        let yamlString: String = try encoder.encode(options)
        let exp = """
            format: dd.MM.yyyy
            locale: de_DE
            timeZone: Europe/Berlin
            """
            .trimmingCharacters(in: .whitespacesAndNewlines)
        #expect(
            yamlString.trimmingCharacters(in: .whitespacesAndNewlines) == exp
        )
    }

    @Test
    func encodeDefaultsProducesYAMLWithFormatOnly() throws {
        let options = DateFormatterConfig(
            localization: DateLocalization.defaults,
            format: "yyyy"
        )
        let encoder = ToucanYAMLEncoder()
        let yamlString: String = try encoder.encode(options)

        let exp = """
            format: yyyy
            """
            .trimmingCharacters(in: .whitespacesAndNewlines)

        #expect(
            yamlString.trimmingCharacters(in: .whitespacesAndNewlines) == exp
        )
    }

    @Test
    func invalidLocale() throws {
        let decoder = ToucanYAMLDecoder()
        let yaml = """
                format: yyyy
                locale: invalid
                timeZone: GMT
            """

        do {
            _ = try decoder.decode(DateLocalization.self, from: yaml)
        }
        catch {
            if let context = error.lookup({
                if case let DecodingError.dataCorrupted(ctx) = $0 {
                    return ctx
                }
                return nil
            }) {
                let expected = "Invalid locale identifier."
                #expect(context.debugDescription == expected)
            }
            else {
                throw error
            }
        }
    }

    @Test
    func invalidTimeZone() throws {
        let decoder = ToucanYAMLDecoder()
        let yaml = """
                format: yyyy
                locale: en-US
                timeZone: invalid
            """

        do {
            _ = try decoder.decode(DateLocalization.self, from: yaml)
        }
        catch {
            if let context = error.lookup({
                if case let DecodingError.dataCorrupted(ctx) = $0 {
                    return ctx
                }
                return nil
            }) {
                let expected = "Invalid time zone identifier."
                #expect(context.debugDescription == expected)
            }
            else {
                throw error
            }
        }
    }

    @Test
    func invalidFormat() throws {
        let decoder = ToucanYAMLDecoder()
        let yaml = """
                format: ""
                locale: en-US
                timeZone: GMT
            """

        do {
            _ = try decoder.decode(DateFormatterConfig.self, from: yaml)
        }
        catch {
            if let context = error.lookup({
                if case let DecodingError.dataCorrupted(ctx) = $0 {
                    return ctx
                }
                return nil
            }) {
                let expected = "Empty date format value."
                #expect(context.debugDescription == expected)
            }
            else {
                throw error
            }
        }
    }

    @Test
    func preserveDefaultValues() throws {
        let original = DateFormatterConfig(
            localization: DateLocalization(
                locale: "en-US",
                timeZone: "GMT"
            ),
            format: "yyyy-MM-dd"
        )
        let encoder = ToucanYAMLEncoder()
        let decoder = ToucanYAMLDecoder()
        let yamlString: String = try encoder.encode(original)
        let decoded = try decoder.decode(
            DateFormatterConfig.self,
            from: yamlString
        )
        #expect(decoded == original)
    }

    @Test
    func preserveCustomValues() throws {
        let original = DateFormatterConfig(
            localization: DateLocalization(
                locale: "hu-HU",
                timeZone: "CET"
            ),
            format: "yyyy-MM-dd"
        )
        let encoder = ToucanYAMLEncoder()
        let decoder = ToucanYAMLDecoder()
        let yamlString: String = try encoder.encode(original)
        let decoded = try decoder.decode(
            DateFormatterConfig.self,
            from: yamlString
        )
        #expect(decoded == original)
    }
}
