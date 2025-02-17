import Foundation
import Testing
import ToucanModels
@testable import ToucanSource

@Suite
struct ContentTypesDecodingTestSuite {

    @Test
    func empty() throws {
        let data = """
            foo: bar
            """
            .data(using: .utf8)!

        let decoder = ToucanYAMLDecoder()

        let result = try decoder.decode(
            RenderPipeline.ContentTypes.self,
            from: data
        )

        #expect(result.filter.isEmpty)
        #expect(result.lastUpdate.isEmpty)
    }

    @Test
    func standard() throws {
        let data = """
            filter:
                - post
            lastUpdate:
                - page
            """
            .data(using: .utf8)!

        let decoder = ToucanYAMLDecoder()

        let result = try decoder.decode(
            RenderPipeline.ContentTypes.self,
            from: data
        )

        #expect(result.filter == ["post"])
        #expect(result.lastUpdate == ["page"])
    }

}
