//import Foundation
//import Testing
//import ToucanModels
//import ToucanTesting
//@testable import ToucanSource
//
//@Suite
//struct SourceBundleTestSuite {
//
//    @Test
//    func pipelineRendering() throws {
//        let sourceBundle = SourceBundle.Mocks.complete()
//
//        let homeUrl = FileManager.default.homeDirectoryForCurrentUser
//        let url = homeUrl.appending(
//            path: "output"
//        )
//
//        if FileManager.default.exists(at: url) {
//            try FileManager.default.removeItem(at: url)
//        }
//        try FileManager.default.createDirectory(at: url)
//
//        let results = try sourceBundle.generatePipelineResults()
//
//        for result in results {
//            let folder = url.appending(path: result.destination.path)
//            try FileManager.default.createDirectory(at: folder)
//
//            let outputUrl =
//                folder
//                .appending(path: result.destination.file)
//                .appendingPathExtension(result.destination.ext)
//
//            try result.contents.write(
//                to: outputUrl,
//                atomically: true,
//                encoding: .utf8
//            )
//        }
//    }
//
//}
