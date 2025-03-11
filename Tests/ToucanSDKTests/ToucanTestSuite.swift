import Testing
@testable import ToucanSDK

@Suite
struct ToucanTestSuite {

    var sitesPath: String {
        "/"
            + #file
            .split(separator: "/")
            .dropLast(3)
            .joined(separator: "/")
            + "/sites/"
    }

    @Test
    func example() async throws {

    }
}
