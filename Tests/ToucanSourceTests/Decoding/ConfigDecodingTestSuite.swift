import Foundation
import Testing
import ToucanSource
import ToucanModels

@Suite
struct ConfigDecodingTestSuite {

    @Test
    func defaults() throws {
        let data = """
            """
            .data(using: .utf8)!

        let decoder = ToucanYAMLDecoder()

        let result = try decoder.decode(
            Config.self,
            from: data
        )

        #expect(result.pipelines.path == "pipelines")
        #expect(result.contents.path == "contents")
        #expect(result.contents.assets.path == "assets")
        #expect(result.dateFormats.input == "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
        #expect(result.dateFormats.output.isEmpty)
    }

    @Test
    func full() throws {
        let data = """
            pipelines: 
                path: foo
            contents:
                path: bar
                assets:
                    path: baz
            dateFormats:
                input: ymd
                output:
                    test1: his
            """
            .data(using: .utf8)!

        let decoder = ToucanYAMLDecoder()

        let result = try decoder.decode(
            Config.self,
            from: data
        )

        #expect(result.pipelines.path == "foo")
        #expect(result.contents.path == "bar")
        #expect(result.contents.assets.path == "baz")
        #expect(result.dateFormats.input == "ymd")
        let output = try #require(result.dateFormats.output["test1"])
        #expect(output == "his")
    }
}
