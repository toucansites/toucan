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
            context: detail
            """
            .dataValue()

        let decoder = ToucanYAMLDecoder()

        let result = try decoder.decode(
            Pipeline.Scope.self,
            from: data
        )

        #expect(result.context == .detail)
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
            .dataValue()

        let decoder = ToucanYAMLDecoder()

        let result = try decoder.decode(
            Pipeline.Scope.self,
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
            .dataValue()

        let decoder = ToucanYAMLDecoder()

        let result = try decoder.decode(
            Pipeline.Scope.self,
            from: data
        )

        #expect(result.context == [.contents, .relations])
        try #require(result.fields.count == 1)
        #expect(result.fields == ["foo"])
    }
}
