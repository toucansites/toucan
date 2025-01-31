import Testing
import Foundation
@testable import ToucanFileSystem
@testable import FileManagerKitTesting

@Suite
struct ContentTypeLocatorTestSuite {

    @Test()
    func contentType() async throws {
        try FileManagerPlayground {
            Directory("default") {
                Directory("types") {
                    "post.yaml"
                    "tag.yml"
                }
            }
            Directory("overrides") {
                Directory("types") {
                    "post.yml"
                    "custom.yml"
                }
            }
        }
        .test { fileManager in
            let typesUrl = URL(fileURLWithPath: "default/types/")
            let overridesUrl = URL(fileURLWithPath: "overrides/types/")
            let locator = OverrideFileLocator(fileManager: fileManager)
            let locations = locator.locate(
                at: typesUrl,
                overrides: overridesUrl
            )

            #expect(
                locations == [
                    .init(path: "post.yaml", overridePath: "post.yml"),
                    .init(path: "tag.yml", overridePath: nil),
                ]
            )
        }
    }
}
