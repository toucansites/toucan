import Testing
import Foundation
@testable import ToucanFileSystem
@testable import FileManagerKitTesting

@Suite(.serialized)
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
                    .init(path: "tag.yml"),
                ]
            )
        }
    }
    
    @Test()
    func contentType_empty() async throws {
        try FileManagerPlayground ().test { fileManager in
            let typesUrl = URL(fileURLWithPath: "default/types/")
            let overridesUrl = URL(fileURLWithPath: "overrides/types/")
            let locator = OverrideFileLocator(fileManager: fileManager)
            let locations = locator.locate(
                at: typesUrl,
                overrides: overridesUrl
            )

            #expect(locations.isEmpty)
        }
    }
    
    @Test()
    func contentType_onlyOverride() async throws {
        try FileManagerPlayground {
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

            #expect(locations.isEmpty)
        }
    }
    
    @Test()
    func contentType_noOverrides() async throws {
        try FileManagerPlayground {
            Directory("default") {
                Directory("types") {
                    "post.yaml"
                    "tag.yml"
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
                    .init(path: "post.yaml"),
                    .init(path: "tag.yml"),
                ]
            )
        }
    }
}
