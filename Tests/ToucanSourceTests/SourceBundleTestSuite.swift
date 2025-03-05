import Foundation
import Testing
import ToucanModels
import ToucanTesting
@testable import ToucanSource

@Suite
struct SourceBundleTestSuite {

    @Test
    func pipelineRendering() throws {
        let sourceBundle = SourceBundle.Mocks.complete()

        // TODO: add support for multiple engines: [mustache: [foo: tpl1]]
        let templates: [String: String] = [
            "default": Templates.Mocks.default(),
            "post.default": Templates.Mocks.post(),
            "rss": Templates.Mocks.rss(),
            "sitemap": Templates.Mocks.sitemap(),
            "redirect": Templates.Mocks.redirect(),
        ]

        let homeUrl = FileManager.default.homeDirectoryForCurrentUser
        let url = homeUrl.appending(
            path: "output"
        )

        if FileManager.default.exists(at: url) {
            try FileManager.default.removeItem(at: url)
        }
        try FileManager.default.createDirectory(at: url)

        let results = try sourceBundle.generatePipelineResults()

        for result in results {
            let folder = url.appending(path: result.destination.path)
            try FileManager.default.createDirectory(at: folder)

            let outputUrl =
                folder
                .appending(path: result.destination.file)
                .appendingPathExtension(result.destination.ext)

            try result.contents.write(
                to: outputUrl,
                atomically: true,
                encoding: .utf8
            )
        }
    }

}
