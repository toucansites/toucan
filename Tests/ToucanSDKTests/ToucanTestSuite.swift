import Testing
@testable import ToucanSDK

@Suite("Toucan test suite")
struct ToucanTestSuite {

    var sitesPath: String {
        "/"
            + #file
            .split(separator: "/")
            .dropLast(3)
            .joined(separator: "/")
            + "/sites/"
    }

    @Test("Example test case")
    func example() async throws {
        #expect(true)
    }

    //    func generate(
    //        _ site: String
    //    ) async throws {
    //        let baseUrl = URL(fileURLWithPath: sitesPath)
    //        let siteUrl = baseUrl.appendingPathComponent(site)
    //        let srcUrl = siteUrl.appendingPathComponent("src")
    //        let destUrl = siteUrl.appendingPathComponent("dist")
    //
    //        let toucan = Toucan(
    //            input: srcUrl.path,
    //            output: destUrl.path,
    //            baseUrl: nil
    //        )
    //        try toucan.generate()
    //    }
    //
    //    func generate() async throws {
    //        for argument in [
    //            //                "minimal",
    //            "demo"
    //            //            "theswiftdev.com",
    //            //            "binarybirds.com",
    //            //            "swiftonserver.com",
    //        ] {
    //            try await generate(argument)
    //        }
    //    }
}
