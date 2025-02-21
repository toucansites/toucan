import Foundation
import Testing
import ToucanModels
@testable import ToucanSource

@Suite
struct ContextDecodingTestSuite {

    @Test
    func initialization() throws {
        let result = Pipeline.Scope.Context(stringValue: "foo")

        #expect(!result.contains(.properties))
        #expect(!result.contains(.contents))
        #expect(!result.contains(.relations))
        #expect(!result.contains(.queries))
        #expect(!result.contains(.all))
    }

    @Test
    func decodingMultipleValues() throws {
        let json = #"["contents", "queries"]"#
        let data = json.data(using: .utf8)!
        let result = try ToucanJSONDecoder()
            .decode(Pipeline.Scope.Context.self, from: data)

        #expect(!result.contains(.properties))
        #expect(result.contains(.contents))
        #expect(!result.contains(.relations))
        #expect(result.contains(.queries))
        #expect(!result.contains(.all))
    }

    @Test
    func decodingSingleValue() throws {
        let json = #""properties""#
        let data = json.data(using: .utf8)!
        let result = try ToucanJSONDecoder()
            .decode(Pipeline.Scope.Context.self, from: data)

        #expect(result.contains(.properties))
        #expect(!result.contains(.contents))
        #expect(!result.contains(.relations))
        #expect(!result.contains(.queries))
        #expect(!result.contains(.all))
    }

    @Test
    func decodingSingleAllValue() throws {
        let json = #""all""#
        let data = json.data(using: .utf8)!
        let result = try ToucanJSONDecoder()
            .decode(Pipeline.Scope.Context.self, from: data)

        #expect(result.contains(.properties))
        #expect(result.contains(.contents))
        #expect(result.contains(.relations))
        #expect(result.contains(.queries))
        #expect(result.contains(.all))
    }
}
