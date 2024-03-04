import XCTest
@testable import ToucanSDK

final class AppTests: XCTestCase {

    func testPosts() async throws {

        var toucanFilesKit = ToucanFilesKit()
        try toucanFilesKit.createURLs(URL(fileURLWithPath: "./Tests/src"))
        try toucanFilesKit.createInfo(needToCopy: true)

        var toucanContentKit = ToucanContentKit()
        try toucanContentKit.create(
            baseUrl: "https://binarybirds.com/",
            contentsUrl: toucanFilesKit.contentsUrl,
            templatesUrl: toucanFilesKit.templatesUrl,
            postFileInfos: toucanFilesKit.postFileInfos,
            pageFileInfos: toucanFilesKit.pageFileInfos
        )

        for post in toucanContentKit.posts {
            let content = try post.generate().replacingOccurrences(of: " ", with: "")
                .replacingOccurrences(of: "\n", with: "")
                .replacingOccurrences(of: "\r", with: "")

            let distUrl = URL(fileURLWithPath: "./Tests/dist/").appendingPathComponent(post.slug).appendingPathComponent("/index.html")
            let goalContent = try String(contentsOf: distUrl).replacingOccurrences(of: " ", with: "")
                .replacingOccurrences(of: "\n", with: "")
                .replacingOccurrences(of: "\r", with: "")
           
            XCTAssertEqual(content, goalContent)
        }

    }
}
