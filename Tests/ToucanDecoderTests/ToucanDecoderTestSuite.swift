import Testing
@testable import ToucanDecoder

@Suite
struct ToucanDecoderTestSuite {

    struct Config: Decodable {
        let name: String
        let description: String
    }
    
    @Test
    func example() async throws {
     
        let decoder = ToucanJSONDecoder()
        let data = """
        {
            // JSON5 comment
            "id": 1,
            "name": "John Doe",
            "description": "john@example.com"
        }
        """
        .data(using: .utf8)!
        
        let config = try decoder.decode(Config.self, from: data)
        #expect(config.name == "John Doe")
    }

}
