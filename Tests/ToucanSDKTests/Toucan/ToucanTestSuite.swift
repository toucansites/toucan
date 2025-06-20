//
//  ToucanTestSuite.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 06. 20..
//

import FileManagerKitBuilder
import Foundation
import Logging
import Testing
import ToucanCore
@testable import ToucanSDK
import ToucanSource

@Suite
struct ToucanTestSuite {

    @Test
    func absoluteURLResolution() throws {
        let fileManager = FileManager.default
        let cwd = fileManager.currentDirectoryPath
        let toucan = Toucan()
        let path1 = toucan.absoluteURL(for: ".").path()
        #expect(cwd == path1)
    }
}
