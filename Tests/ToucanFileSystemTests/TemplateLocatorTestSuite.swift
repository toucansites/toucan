import Testing
import Foundation
@testable import ToucanFileSystem
@testable import FileManagerKitTesting

struct TemplateLocatorTestSuite {

    @Test()
    func template() async throws {
        try FileManagerPlayground {
            Directory("themes") {
                Directory("default") {
                    Directory("templates") {
                        Directory("foo") {
                            "bar.mustache"
                            "baz.mustache"
                        }
                        "qux.mustache"
                        "quux.md"
                    }
                }
                Directory("overrides") {
                    Directory("templates") {
                        Directory("foo") {
                            "baz.mustache"
                        }
                    }
                }
            }
        }
        .test { fileManager in
            let url = URL(fileURLWithPath: "themes/default/templates/")
            let overridesUrl = URL(fileURLWithPath: "themes/overrides/templates/")
            let locator = TemplateLocator(fileManager: fileManager)
            let result = locator.locate(at: url, overridesUrl: overridesUrl)
            #expect(
                result == [
                    .init(id: "foo.bar", path: "foo/bar.mustache"),
                    .init(id: "foo.baz", path: "foo/baz.mustache"),
                    .init(id: "qux", path: "qux.mustache"),
                ]
            )
        }
    }
}
