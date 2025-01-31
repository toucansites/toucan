import Foundation
import Testing
import ToucanSource
@testable import ToucanModels

@Suite
struct ContentDefinitionTestSuite {

    // MARK: -

    @Test
    func decodingQuery() throws {

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
