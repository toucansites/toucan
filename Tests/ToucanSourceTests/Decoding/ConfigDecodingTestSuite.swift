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
            .dataValue()

        let decoder = ToucanYAMLDecoder()

        let result = try decoder.decode(
            Config.self,
            from: data
        )

        #expect(result.pipelines.path == "pipelines")
        #expect(result.contents.path == "contents")
        #expect(result.contents.assets.path == "assets")
        #expect(
            result.dateFormats.input
                == .init(
                    format: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                )
        )
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
                input: 
                    format: ymd
                output:
                    test1: 
                        locale: en-US
                        timeZone: EST
                        format: his
            """
            .dataValue()

        let decoder = ToucanYAMLDecoder()

        let result = try decoder.decode(
            Config.self,
            from: data
        )

        #expect(result.pipelines.path == "foo")
        #expect(result.contents.path == "bar")
        #expect(result.contents.assets.path == "baz")
        #expect(result.dateFormats.input == .init(format: "ymd"))
        let output = try #require(result.dateFormats.output["test1"])
        #expect(
            output
                == .init(
                    locale: "en-US",
                    timeZone: "EST",
                    format: "his"
                )
        )
    }
    
    @Test
    func encoding() throws {

        let encoder = ToucanYAMLEncoder()
        let config = Config.defaults
        
        let yaml = try encoder.encode(config)
        
        let exp = """
            pipelines:
              path: pipelines
            contents:
              path: contents
              assets:
                path: assets
            themes:
              location:
                path: themes
              current:
                path: default
              assets:
                path: assets
              templates:
                path: templates
              types:
                path: types
              overrides:
                path: overrides
              blocks:
                path: blocks
            dateFormats:
              input:
                format: yyyy-MM-dd'T'HH:mm:ss.SSS'Z'
              output: {}
            contentConfigurations:
              wordsPerMinute: 238
              outlineLevels:
              - 2
              - 3
              paragraphStyles:
                note:
                - note
                warn:
                - warn
                - warning
                tip:
                - tip
                important:
                - important
                error:
                - error
                - caution
            """
        
        let trimmedYaml = yaml.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        let trimmedExp = exp.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        #expect(trimmedYaml == trimmedExp)
    }
}
