//
//  AnyCodableWrapTests.swift
//  Toucan
//
//  Created by gerp83 on 2025. 04. 28..
//
// import Foundation
// import Testing
// import ToucanSource
//
// @Suite
// struct AnyCodableWrapTests {
//
//    @Test
//    func testWraps() throws {
//        let boolValue = true
//        let intValue = 100
//        let doubleValue = 100.1
//        let stringValue = "string"
//        let nilValue: String? = nil
//        let arrayValue = [AnyCodable("string"), AnyCodable("string2")]
//        let dictValue = ["key": AnyCodable("value")]
//        let dictValue2 = ["key": "value", "key2": "value2"]
//
//        #expect(wrap(boolValue) == AnyCodable(true))
//        #expect(wrap(intValue) == AnyCodable(100))
//        #expect(wrap(doubleValue) == AnyCodable(100.1))
//        #expect(wrap(stringValue) == AnyCodable("string"))
//        #expect(wrap(nilValue) == AnyCodable(nil))
//        #expect(
//            wrap(arrayValue)
//                == AnyCodable([AnyCodable("string"), AnyCodable("string2")])
//        )
//        #expect(wrap(dictValue) == AnyCodable(["key": AnyCodable("value")]))
//        #expect(
//            wrap(dictValue2)
//                == AnyCodable([
//                    "key": AnyCodable("value"), "key2": AnyCodable("value2"),
//                ])
//        )
//    }
//
//    @Test
//    func testUnwraps() throws {
//        let boolValue = AnyCodable(true)
//        let intValue = AnyCodable(100)
//        let doubleValue = AnyCodable(100.1)
//        let stringValue = AnyCodable("string")
//        let nilValue = AnyCodable(nil)
//        let arrayValue = AnyCodable([
//            AnyCodable("string"), AnyCodable("string2"),
//        ])
//        let dictValue = AnyCodable([
//            "key": AnyCodable("value"), "key2": AnyCodable("value2"),
//        ])
//        let dictValue2 = AnyCodable(["key": 100, "key2": 200])
//
//        #expect(unwrap(boolValue) as? Bool == true)
//        #expect(unwrap(intValue) as? Int == 100)
//        #expect(unwrap(doubleValue) as? Double == 100.1)
//        #expect(unwrap(stringValue) as? String == "string")
//        #expect(unwrap(nilValue) == nil)
//        #expect(unwrap(arrayValue) as? [String] == ["string", "string2"])
//        #expect(
//            unwrap(dictValue) as? [String: String] == [
//                "key2": "value2", "key": "value",
//            ]
//        )
//        #expect(
//            unwrap(dictValue2) as? [String: Int] == ["key": 100, "key2": 200]
//        )
//    }
//
// }
