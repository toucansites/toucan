import Testing
import Foundation
@testable import ToucanFileSystem
@testable import FileManagerKitTesting

@Suite(.serialized)
struct FileLocatorTestSuite {

    @Test()
    func fileLocator_emptyRootDirectory() async throws {
        try FileManagerPlayground()
            .test { fileManager in
                let url = URL(fileURLWithPath: ".")
                let locator = FileLocator(fileManager: fileManager)
                let locations = locator.locate(at: url).sorted()

                #expect(locations.isEmpty)
            }
    }

    @Test()
    func fileLocator_allFiles() async throws {
        try FileManagerPlayground {
            Directory("foo") {
                Directory("bar") {
                    "baz.yaml"
                    "qux.yml"
                }
            }
        }
        .test { fileManager in
            let url = URL(fileURLWithPath: "foo/bar/")
            let locator = FileLocator(fileManager: fileManager)
            let locations = locator.locate(at: url).sorted()

            #expect(locations == ["baz.yaml", "qux.yml"])
        }
    }

    @Test()
    func fileLocator_directoriesAndFiles() async throws {
        try FileManagerPlayground {
            Directory("foo") {
                Directory("bar")
                "baz.yaml"
                "qux.yml"
            }
        }
        .test { fileManager in
            let url = URL(fileURLWithPath: "foo/")
            let locator = FileLocator(fileManager: fileManager)
            let locations = locator.locate(at: url).sorted()

            #expect(locations == ["bar", "baz.yaml", "qux.yml"])
        }
    }

    @Test()
    func fileLocator_multipleExtensions() async throws {
        try FileManagerPlayground {
            Directory("foo") {
                Directory("bar") {
                    "baz.yaml"
                    "qux.yml"
                    "quux.txt"
                }
            }
        }
        .test { fileManager in
            let url = URL(fileURLWithPath: "foo/bar/")
            let locator = FileLocator(
                fileManager: fileManager,
                extensions: ["yaml", "yml"]
            )
            let locations = locator.locate(at: url).sorted()

            #expect(locations == ["baz.yaml", "qux.yml"])
        }
    }
}
