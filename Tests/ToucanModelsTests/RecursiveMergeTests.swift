import Testing
@testable import ToucanModels

@Suite
struct RecursiveMergeTests {

    @Test
    func testBasicMerge() throws {
        let a: [String: AnyCodable] = [
            "foo": "a"

        ]
        let b: [String: AnyCodable] = [
            "foo": "b"
        ]

        let c = a.recursivelyMerged(with: b)

        #expect(c["foo"] == "b")
    }
}
