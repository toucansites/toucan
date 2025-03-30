import Foundation
import Testing
@testable import ToucanModels

@Suite
struct PropertyTypeTestSuite {

    @Test
    func equality() throws {
        #expect(PropertyType.bool == .bool)
        #expect(PropertyType.bool != .int)
        #expect(PropertyType.int == .int)
        #expect(PropertyType.int != .double)
        #expect(PropertyType.double == .double)
        #expect(PropertyType.double != .string)
        #expect(PropertyType.string == .string)
        #expect(PropertyType.string != .date(format: nil))
        #expect(PropertyType.date(format: nil) == .date(format: nil))
        #expect(
            PropertyType.date(format: nil)
                != .date(
                    format: .init(format: "y.m.d")
                )
        )
    }
}
