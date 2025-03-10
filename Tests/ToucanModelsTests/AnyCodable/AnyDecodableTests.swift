import Foundation
import Testing
@testable import ToucanModels

@Suite
struct AnyDecodableTests {

    @Test
    func testJSONDecoding() throws {
        let json = """
            {
                "boolean": true,
                "integer": 42,
                "double": 3.141592653589793,
                "string": "string",
                "array": [1, 2, 3],
                "dict": {
                    "a": "alpha",
                    "b": "bravo",
                    "c": "charlie"
                },
                "null": null
            }
            """
            .data(using: .utf8)!

        let decoder = JSONDecoder()
        let dictionary = try decoder.decode(
            [String: AnyCodable].self,
            from: json
        )

        #expect(dictionary["boolean"]?.value as! Bool == true)
        #expect(dictionary["integer"]?.value as! Int == 42)
        #expect(dictionary["double"]?.value as! Double == 3.141592653589793)
        #expect(dictionary["string"]?.value as! String == "string")
        #expect(dictionary["array"]?.value as! [Int] == [1, 2, 3])
        #expect(
            dictionary["dict"]?.value as! [String: AnyCodable] == [
                "a": "alpha", "b": "bravo", "c": "charlie",
            ]
        )
        #expect(dictionary["null"]!.value == nil)
    }
}
