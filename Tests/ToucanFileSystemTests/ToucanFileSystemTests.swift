import Testing
import Foundation
@testable import ToucanFileSystem
@testable import FileManagerKitTesting

@Suite
struct ToucanFileSystemTests {

    @Test()
    func fileSystem_NoFiles() async throws {
        try FileManagerPlayground {
            Directory("foo") {
                Directory("bar")
                Directory("baz")
            }
        }.test { fileManager in
            let url = URL(fileURLWithPath: "./foo/bar/")
            let overrideUrl = URL(fileURLWithPath: "./foo/bar/")
            let fs = ToucanFileSystem(fileManager: fileManager)
            
            let pageBundles = fs.locatePageBundles(at: url)
            #expect(pageBundles.isEmpty)
            
            let contentTypes = fs.locateContentTypes(
                at: url,
                overrides: overrideUrl
            )
            
            let templates = fs.locateTemplates(at: url, overrides: overrideUrl)
            #expect(templates.isEmpty)
        }
    }
}
