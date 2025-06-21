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
        let homeURL = fileManager.homeDirectoryForCurrentUser
        let cwd = fileManager.currentDirectoryPath
        let cwdURL = URL(filePath: cwd)
        let toucan = Toucan()

        let path1 = toucan.absoluteURL(for: ".").path()
        let exp1 = cwdURL.path()
        #expect(path1 == exp1)

        let path2 = toucan.absoluteURL(for: "/foo/bar").path()
        let exp2 = URL(filePath: "/foo/bar").path()
        #expect(path2 == exp2)

        let path3 = toucan.absoluteURL(for: "../foo/bar").path()
        let exp3 = cwdURL.appending(path: "../foo/bar").standardized.path()
        #expect(path3 == exp3)

        let path4 = toucan.absoluteURL(for: "../foo/../bar").path()
        let exp4 = cwdURL.appending(path: "../foo/../bar").standardized.path()
        #expect(path4 == exp4)

        let path5 = toucan.absoluteURL(for: "./foo/../bar").path()
        let exp5 = cwdURL.appending(path: "./foo/../bar").standardized.path()
        #expect(path5 == exp5)

        let path6 = toucan.absoluteURL(for: "~/../bar").path()
        let exp6 = homeURL.appending(path: "../bar").standardized.path()
        #expect(path6 == exp6)

        let path7 = toucan.absoluteURL(for: "bar").path()
        let exp7 = cwdURL.appending(path: "bar").standardized.path()
        #expect(path7 == exp7)

        let path8 = toucan.absoluteURL(for: "").path()
        let exp8 = cwdURL.appending(path: "").path().dropTrailingSlash()
        #expect(path8 == exp8)
    }

    @Test
    func homeURLResolution() throws {
        let fileManager = FileManager.default
        let homeURL = fileManager.homeDirectoryForCurrentUser
        let toucan = Toucan()

        let path1 = toucan.resolveHomeURL(for: "~/foo").path()
        let exp1 = homeURL.appending(path: "foo").path()
        #expect(path1 == exp1)

        let path2 = toucan.resolveHomeURL(for: "~/").path()
        let exp2 = homeURL.appending(path: "").path()
        #expect(path2 == exp2)
    }
}
