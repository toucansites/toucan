import Testing
@testable import ToucanModels

@Suite
struct PropetyValueTestSuite {

    @Test
    func equality() {
        #expect(PropertyValue.bool(true) == PropertyValue.bool(true))
        #expect(PropertyValue.bool(true) != PropertyValue.bool(false))

        #expect(PropertyValue.int(5) == PropertyValue.int(5))
        #expect(PropertyValue.int(5) != PropertyValue.int(10))

        #expect(PropertyValue.double(5.5) == PropertyValue.double(5.5))
        #expect(PropertyValue.double(5.5) != PropertyValue.double(10.0))

        #expect(PropertyValue.string("test") == PropertyValue.string("test"))
        #expect(PropertyValue.string("test") != PropertyValue.string("other"))

        #expect(PropertyValue.date(0) == PropertyValue.date(0))
        #expect(PropertyValue.date(0) != PropertyValue.date(100))
    }

    @Test
    func lessThan() {
        #expect(PropertyValue.bool(false) < PropertyValue.bool(true))
        #expect(!(PropertyValue.bool(true) < PropertyValue.bool(false)))

        #expect(PropertyValue.int(5) < PropertyValue.int(10))
        #expect(!(PropertyValue.int(10) < PropertyValue.int(5)))

        #expect(PropertyValue.double(5.5) < PropertyValue.double(10.0))
        #expect(!(PropertyValue.double(10.0) < PropertyValue.double(5.5)))

        #expect(PropertyValue.string("apple") < PropertyValue.string("banana"))
        #expect(
            !(PropertyValue.string("banana") < PropertyValue.string("apple"))
        )

        #expect(PropertyValue.date(0) < PropertyValue.date(100))
        #expect(!(PropertyValue.date(100) < PropertyValue.date(0)))
    }

    @Test
    func defaultOrderForDifferentCases() {
        #expect(PropertyValue.bool(false) < PropertyValue.int(0))
        #expect(PropertyValue.int(0) < PropertyValue.double(0.0))
        #expect(PropertyValue.double(0.0) < PropertyValue.string(""))
        #expect(PropertyValue.string("") < PropertyValue.date(0))

        #expect(!(PropertyValue.date(0) < PropertyValue.string("")))
        #expect(!(PropertyValue.string("") < PropertyValue.double(0.0)))
        #expect(!(PropertyValue.double(0.0) < PropertyValue.int(0)))
        #expect(!(PropertyValue.int(0) < PropertyValue.bool(false)))
    }

    @Test
    func sorting() {
        let unsorted: [PropertyValue] = [
            .string("banana"),
            .int(10),
            .bool(true),
            .double(5.5),
            .date(100),
            .bool(false),
            .int(5),
        ]

        let sorted = unsorted.sorted()
        let expected: [PropertyValue] = [
            .bool(false),
            .bool(true),
            .int(5),
            .int(10),
            .double(5.5),
            .string("banana"),
            .date(100),
        ]

        #expect(sorted == expected)
    }
}
