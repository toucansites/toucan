import Foundation
import Testing
import ToucanModels
@testable import ToucanSource

@Suite
struct RenderPipelineDecodingTestSuite {

    // MARK: - order

    @Test
    func standard() throws {
        let data = """
            queries: 
                featured:
                    contentType: post
                    limit: 10
                    filter:
                        key: featured
                        operator: equals
                        value: true
                    orderBy:
                        - key: publication
                          direction: desc

            contentType: all
            engine: 
                id: test
                options:
                    foo: bar
            """
            .data(using: .utf8)!

        let decoder = ToucanYAMLDecoder()

        let result = try decoder.decode(
            RenderPipeline.self,
            from: data
        )

        #expect(result.contentType == .all)
        let query = try #require(result.queries["featured"])
        #expect(query.contentType == "post")

        #expect(result.engine.id == "test")
        let anyValue = try #require(result.engine.options["foo"])
        #expect(anyValue.value as? String == "bar")
    }
}
