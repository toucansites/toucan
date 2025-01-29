import Testing
@testable import ToucanDecoder

@Suite
struct ToucanDecoderTestSuite {

    struct Config: Decodable {
        let name: String
        let description: String
    }

    @Test
    func basicJSON5Decoding() async throws {

        let decoder = ToucanJSONDecoder()
        let data = """
            {
                // JSON5 comment
                "name": "John Doe",
                "description": "john@example.com"
            }
            """
            .data(using: .utf8)!

        let config = try decoder.decode(Config.self, from: data)
        #expect(config.name == "John Doe")
    }

    @Test
    func basicInvalidJSONDecoding() async throws {

        let decoder = ToucanJSONDecoder()
        let data = """
            {
                // JSON5 comment
                "name: "John Doe",
                "description": "john@example.com"
            }
            """
            .data(using: .utf8)!

        do {
            _ = try decoder.decode(Config.self, from: data)
        }
        catch ToucanDecoderError.decoding(let error) {
            #expect(
                error.localizedDescription
                    == "The data couldn’t be read because it isn’t in the correct format."
            )
        }
    }

    @Test
    func basicYAMLDecoding() async throws {

        let decoder = ToucanYAMLDecoder()
        let data = """
            # comment
            name: "John Doe"
            description: "john@example.com"
            """
            .data(using: .utf8)!

        let config = try decoder.decode(Config.self, from: data)
        #expect(config.name == "John Doe")
    }

}
