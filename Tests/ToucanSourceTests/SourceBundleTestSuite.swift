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
        try sourceBundle.render()
    }
}
