import Testing
import Foundation
@testable import ToucanFileSystem
@testable import FileManagerKitTesting

@Suite(.serialized)
struct FileLocatorTestSuite {

    @Test()
    func fileLocator_emptyRootDirectory() async throws {
        try FileManagerPlayground()
            .test {
                let locator = FileLocator(fileManager: $0)
                let locations = locator.locate(at: $1).sorted()

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
        .test {
            let url = $1.appending(path: "foo/bar/")
            let locator = FileLocator(fileManager: $0)
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
        .test {
            let url = $1.appending(path: "foo/")
            let locator = FileLocator(fileManager: $0)
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
        .test {
            let url = $1.appending(path: "foo/bar/")
            let locator = FileLocator(
                fileManager: $0,
                extensions: ["yaml", "yml"]
            )
            let locations = locator.locate(at: url).sorted()

            #expect(locations == ["baz.yaml", "qux.yml"])
        }
    }
}
