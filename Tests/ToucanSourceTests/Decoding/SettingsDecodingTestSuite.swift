import Foundation
import Testing
import ToucanSource
import ToucanModels

@Suite
struct SettingsDecodingTestSuite {

    @Test
    func defaults() throws {
        let data = """
            baseUrl: "lorem1"
            name: "lorem2"
            locale: "lorem3"
            timezone: "lorem4"
            foo:
                bar: baz
            """
            .data(using: .utf8)!

        let decoder = ToucanYAMLDecoder()

        let result = try decoder.decode(
            Settings.self,
            from: data
        )

        #expect(result.userDefined["name"] == nil)
        let foo = try #require(
            result.userDefined["foo"]?.value as? [String: String]
        )
        #expect(foo["bar"] == "baz")
    }

    @Test
    func full() throws {
        let data = """
            baseUrl: https://toucansites.com/
            """
            .data(using: .utf8)!

        let decoder = ToucanYAMLDecoder()

        let result = try decoder.decode(
            Settings.self,
            from: data
        )

        #expect(result.baseUrl == "https://toucansites.com/")
        #expect(result.name == "localhost")
        #expect(result.locale == nil)
        #expect(result.timezone == nil)
        #expect(result.userDefined.isEmpty)
    }
}
