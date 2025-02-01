import Foundation
import Testing
import ToucanModels
@testable import ToucanSource

@Suite
struct ContentTypesDecodingTestSuite {

    @Test
    func initialization() throws {
        let result = RenderPipeline.ContentTypes(stringValue: "foo")

        #expect(!result.contains(.single))
        #expect(!result.contains(.bundle))
        #expect(!result.contains(.all))
    }

    @Test
    func decodingMultipleValues() throws {
        let json = #"["single", "bundle"]"#
        let data = json.data(using: .utf8)!
        let result = try JSONDecoder()
            .decode(RenderPipeline.ContentTypes.self, from: data)

        #expect(result.contains(.single))
        #expect(result.contains(.bundle))
        #expect(result.contains(.all))
    }

    @Test
    func decodingSingleValue() throws {
        let json = #""single""#
        let data = json.data(using: .utf8)!
        let result = try JSONDecoder()
            .decode(RenderPipeline.ContentTypes.self, from: data)

        #expect(result.contains(.single))
        #expect(!result.contains(.bundle))
        #expect(!result.contains(.all))
    }

    @Test
    func decodingSingleAllValue() throws {
        let json = #""all""#
        let data = json.data(using: .utf8)!
        let result = try JSONDecoder()
            .decode(RenderPipeline.ContentTypes.self, from: data)

        #expect(result.contains(.single))
        #expect(result.contains(.bundle))
        #expect(result.contains(.all))
    }
}
