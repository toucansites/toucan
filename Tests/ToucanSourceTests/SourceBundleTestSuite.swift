import Foundation
import Testing
import ToucanModels
import ToucanTesting
@testable import ToucanSource

@Suite
struct SourceBundleTestSuite {

    // MARK: -

    @Test
    func pipelineRendering() throws {
        let sourceBundle = SourceBundle.Mocks.complete()

        let templates: [String: String] = [
            "default": Templates.Mocks.default(),
            "post.default": Templates.Mocks.post(),
            "rss": Templates.Mocks.rss(),
        ]

        try sourceBundle.render(templates: templates)
    }
}
