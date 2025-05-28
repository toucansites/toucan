//
//  DateFormattingTestSuite.swift
//  toucan
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
            DateFormatterParameters.self,
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
            DateFormatterParameters.self,
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
        let options = DateFormatterParameters(
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
        let options = DateFormatterParameters(
            localization: DateLocalization.defaults,
            format: "yyyy"
        )
        let encoder = ToucanYAMLEncoder()
        let yamlString: String = try encoder.encode(options)

        let exp = """
            format: yyyy
            locale: en-US
            timeZone: GMT
            """
            .trimmingCharacters(in: .whitespacesAndNewlines)
        #expect(
            yamlString.trimmingCharacters(in: .whitespacesAndNewlines) == exp
        )
    }

    @Test
    func roundTripPreservesValues() throws {
        let original = DateFormatterParameters(
            localization: DateLocalization(
                locale: "es_ES",
                timeZone: "UTC"
            ),
            format: "dd-MM-yyyy"
        )
        let encoder = ToucanYAMLEncoder()
        let decoder = ToucanYAMLDecoder()
        let yamlString: String = try encoder.encode(original)
        let decoded = try decoder.decode(
            DateFormatterParameters.self,
            from: yamlString
        )
        #expect(decoded == original)
    }
}
