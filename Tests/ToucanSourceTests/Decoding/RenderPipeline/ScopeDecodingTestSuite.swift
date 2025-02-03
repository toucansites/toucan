import Foundation
import Testing
import ToucanSource
import ToucanModels

@Suite
struct ScopeDecodingTestSuite {

    // MARK: - order

    @Test
    func minimal() throws {
        let data = """
            context: all
            """
            .data(using: .utf8)!

        let decoder = ToucanYAMLDecoder()

        let result = try decoder.decode(
            RenderPipeline.Scope.self,
            from: data
        )

        #expect(result.context == .all)
        try #require(result.fields.count == 0)
        #expect(result.fields == [])
    }

    @Test
    func fields() throws {
        let data = """
            context: properties
            fields: 
                - foo
                - bar
            """
            .data(using: .utf8)!

        let decoder = ToucanYAMLDecoder()

        let result = try decoder.decode(
            RenderPipeline.Scope.self,
            from: data
        )

        #expect(result.context == .properties)
        try #require(result.fields.count == 2)
        #expect(result.fields == ["foo", "bar"])
    }

    @Test
    func context() throws {
        let data = """
            context: 
                - contents
                - relations
            fields: 
                - foo
            """
            .data(using: .utf8)!

        let decoder = ToucanYAMLDecoder()

        let result = try decoder.decode(
            RenderPipeline.Scope.self,
            from: data
        )

        #expect(result.context == [.contents, .relations])
        try #require(result.fields.count == 1)
        #expect(result.fields == ["foo"])
    }
}
