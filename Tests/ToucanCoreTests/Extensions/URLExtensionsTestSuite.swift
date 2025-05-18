//
//  URLExtensionsTestSuite.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 17..
//

import Foundation
import Testing

@testable import ToucanCore

@Suite
struct URLExtensionsTestSuite {

    @Test
    func appendingValidPath() {
        let base = URL(string: "https://example.com")!
        let result = base.appendingPathIfPresent("users")
        #expect(result.absoluteString == "https://example.com/users")
    }

    @Test
    func appendingEmptyPath() {
        let base = URL(string: "https://example.com")!
        let result = base.appendingPathIfPresent("")
        #expect(result.absoluteString == "https://example.com")
    }

    @Test
    func appendingNilPath() {
        let base = URL(string: "https://example.com")!
        let result = base.appendingPathIfPresent(nil)
        #expect(result.absoluteString == "https://example.com")
    }
}
