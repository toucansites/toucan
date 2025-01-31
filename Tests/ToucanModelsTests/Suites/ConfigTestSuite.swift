import Foundation
import Testing
import ToucanDecoder
@testable import ToucanModels

@Suite
struct ConfigTestSuite {

    // MARK: -

    @Test
    func decodingThemeConfig() throws {

        let themeConfigData = """
            """
            .data(using: .utf8)!

        let decoer = ToucanYAMLDecoder()

        let themeConfig = try decoer.decode(
            HTMLRendererConfig.Themes.self,
            from: themeConfigData
        )

        print(themeConfig)

        //        #expect(jsonString == #"{"type":"bool"}"#)
    }
}
