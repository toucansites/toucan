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

            contentTypes: all
            engine: 
                id: test
                options:
                    foo: bar
            output:
                path: "{{slug}}"
                file: "{{id}}"
                ext: json
            """
            .data(using: .utf8)!

        let decoder = ToucanYAMLDecoder()

        let result = try decoder.decode(
            RenderPipeline.self,
            from: data
        )

        #expect(result.contentTypes == .all)
        let query = try #require(result.queries["featured"])
        #expect(query.contentType == "post")

        #expect(result.engine.id == "test")
        #expect(result.engine.options.string("foo") == "bar")
    }

    @Test
    func scopes() throws {
        let data = """
            scopes: 
                post:
                    list:
                        context: 
                            - all
                        fields:
            dataTypes:
                date:
                    formats:
                        test: ymd
            engine: 
                id: test
            output:
                path: "{{slug}}"
                file: index
                ext: html
            """
            .data(using: .utf8)!

        let decoder = ToucanYAMLDecoder()

        let result = try decoder.decode(
            RenderPipeline.self,
            from: data
        )

        #expect(result.contentTypes == .single)
        #expect(result.engine.id == "test")

        let defaultScope = try #require(result.scopes["*"])
        let defaultReferenceScope = try #require(defaultScope["reference"])
        let defaultListScope = try #require(defaultScope["list"])
        let defaultDetailScope = try #require(defaultScope["detail"])

        #expect(defaultReferenceScope.context == .reference)
        #expect(defaultListScope.context == .list)
        #expect(defaultDetailScope.context == .detail)

        let dateFormat = try #require(result.dataTypes.date.formats["test"])
        #expect(dateFormat == "ymd")

        let postScope = try #require(result.scopes["post"])
        let postListScope = try #require(postScope["list"])
        #expect(postListScope.context == .all)
    }
}
