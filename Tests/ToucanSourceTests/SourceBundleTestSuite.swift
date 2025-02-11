import Foundation
import Testing
import ToucanModels
import ToucanTesting
@testable import ToucanSource

@Suite
struct SourceBundleTestSuite {

    // MARK: -

    @Test
    func decodingThemeConfig() throws {
        let sourceBundle = SourceBundle.Mocks.complete()
        try sourceBundle.renderTest()
    }

}
