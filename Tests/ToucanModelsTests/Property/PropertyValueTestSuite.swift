import Foundation
import Testing
@testable import ToucanModels

@Suite
struct PropetyValueTestSuite {

    // TODO: Any Value Test Suite
    //    @Test
    //    func initializers() {
    //        #expect(PropertyValue(true) == .bool(true))
    //        #expect(PropertyValue(42) == .int(42))
    //        #expect(PropertyValue(3.14) == .double(3.14))
    //        #expect(PropertyValue("Swift") == .string("Swift"))
    //        #expect(PropertyValue(1000) != .date(1000))
    //        #expect(PropertyValue(Set([1, 2, 3])) == nil)
    //
    //        let date = Date(timeIntervalSince1970: 1000)
    //        #expect(PropertyValue(date) == .date(1000))
    //
    //        let array: [Any] = [true, 42, "Swift"]
    //        let explicitArray: [PropertyValue] = [
    //            .bool(true), .int(42), .string("Swift"),
    //        ]
    //        #expect(PropertyValue(array) == .array(explicitArray))
    //    }
    //
    //    @Test
    //    func equality() {
    //        #expect(PropertyValue.bool(true) == PropertyValue.bool(true))
    //        #expect(PropertyValue.bool(true) != PropertyValue.bool(false))
    //
    //        #expect(PropertyValue.int(5) == PropertyValue.int(5))
    //        #expect(PropertyValue.int(5) != PropertyValue.int(10))
    //
    //        #expect(PropertyValue.double(5.5) == PropertyValue.double(5.5))
    //        #expect(PropertyValue.double(5.5) != PropertyValue.double(10.0))
    //
    //        #expect(PropertyValue.string("test") == PropertyValue.string("test"))
    //        #expect(PropertyValue.string("test") != PropertyValue.string("other"))
    //
    //        #expect(PropertyValue.date(0) == PropertyValue.date(0))
    //        #expect(PropertyValue.date(0) != PropertyValue.date(100))
    //    }
    //
    //    @Test
    //    func comparison() {
    //        #expect(PropertyValue.bool(false) < PropertyValue.bool(true))
    //        #expect(!(PropertyValue.bool(true) < PropertyValue.bool(false)))
    //
    //        #expect(PropertyValue.int(5) < PropertyValue.int(10))
    //        #expect(!(PropertyValue.int(10) < PropertyValue.int(5)))
    //
    //        #expect(PropertyValue.double(5.5) < PropertyValue.double(10.0))
    //        #expect(!(PropertyValue.double(10.0) < PropertyValue.double(5.5)))
    //
    //        #expect(PropertyValue.string("apple") < PropertyValue.string("banana"))
    //        #expect(
    //            !(PropertyValue.string("banana") < PropertyValue.string("apple"))
    //        )
    //
    //        #expect(PropertyValue.date(0) < PropertyValue.date(100))
    //        #expect(!(PropertyValue.date(100) < PropertyValue.date(0)))
    //        #expect(!(PropertyValue.array([]) < PropertyValue.array([.int(0)])))
    //    }
    //
    //    @Test
    //    func defaultOrderForDifferentCases() {
    //        #expect(PropertyValue.bool(false) < PropertyValue.int(0))
    //        #expect(PropertyValue.int(0) < PropertyValue.double(1.0))
    //        #expect(PropertyValue.double(0.0) < PropertyValue.string(""))
    //        #expect(!(PropertyValue.string("") < PropertyValue.date(0)))
    //
    //        #expect(PropertyValue.date(0) < PropertyValue.string(""))
    //        #expect(!(PropertyValue.string("") < PropertyValue.double(0.0)))
    //        #expect(!(PropertyValue.double(0.0) < PropertyValue.int(0)))
    //        #expect(!(PropertyValue.int(0) < PropertyValue.bool(false)))
    //    }
    //
    //    @Test
    //    func sorting() {
    //        let unsorted: [PropertyValue] = [
    //            .string("banana"),
    //            .int(10),
    //            .bool(true),
    //            .double(5.5),
    //            .date(100),
    //            .bool(false),
    //            .int(5),
    //        ]
    //
    //        let sorted = unsorted.sorted()
    //        let expected: [PropertyValue] = [
    //            .bool(false),
    //            .bool(true),
    //            .int(5),
    //            .double(5.5),
    //            .int(10),
    //            .date(100),
    //            .string("banana"),
    //        ]
    //
    //        #expect(sorted == expected)
    //    }
}
