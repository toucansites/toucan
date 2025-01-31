import Foundation
import Testing
import ToucanSource
import ToucanModels

@Suite
struct ContentDefinitionDecodingTestSuite {

    // MARK: - order

    @Test
    func minimal() throws {
        let data = """
            type: post
            """
            .data(using: .utf8)!

        let decoder = ToucanYAMLDecoder()

        let result = try decoder.decode(
            ContentDefinition.self,
            from: data
        )

        #expect(result.type == "post")
    }
}
