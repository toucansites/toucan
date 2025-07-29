//
//  ToucanCoreTestSuite.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 17..
//

import Testing
@testable import ToucanCore

@Suite
struct ToucanCoreTestSuite {

    @Test()
    func currentRelease() async throws {

        // Make sure to update the target release
        let targetRelease = GeneratorInfo.v1_0_0_beta_6.release

        let currentRelease = GeneratorInfo.current.release
        #expect(targetRelease == currentRelease)
    }
}
