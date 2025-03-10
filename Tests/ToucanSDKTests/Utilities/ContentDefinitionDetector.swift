//
//  File.swift
//  toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 03. 10..
//

import Foundation
import Testing
import Logging
import ToucanModels
import ToucanTesting
@testable import ToucanSDK

@Suite
struct ContentDefinitionDetectorTestSuite {
    
    @Test
    func explicitContentDefinition() throws {
        let logger = Logger(label: "ContentDefinitionDetectorTestSuite")
        let definitions = [
            ContentDefinition.Mocks.author(),
            ContentDefinition.Mocks.post(),
            ContentDefinition.Mocks.tag(),
            ContentDefinition.Mocks.page(),
        ]
        let detector = ContentDefinitionDetector(
            definitions: definitions,
            origin: .init(path: "blog/authors", slug: ""),
            logger: logger
        )
        let result = try detector.detect(explicitType: "author")
        #expect(result == definitions[0])
    }
    
    @Test
    func pathsContentDefinition() throws {
        let logger = Logger(label: "ContentDefinitionDetectorTestSuite")
        let definitions = [
            ContentDefinition.Mocks.author(),
            ContentDefinition.Mocks.post(),
            ContentDefinition.Mocks.tag(),
            ContentDefinition.Mocks.page(),
        ]
        let detector = ContentDefinitionDetector(
            definitions: definitions,
            origin: .init(path: "blog/authors", slug: ""),
            logger: logger
        )
        let result = try detector.detect(explicitType: nil)
        #expect(result == definitions[0])
    }
    
    @Test
    func defaultContentDefinition() throws {
        let logger = Logger(label: "ContentDefinitionDetectorTestSuite")
        let definitions = [
            ContentDefinition.Mocks.author(),
            ContentDefinition.Mocks.post(),
            ContentDefinition.Mocks.tag(),
            ContentDefinition.Mocks.page(),
        ]
        let detector = ContentDefinitionDetector(
            definitions: definitions,
            origin: .init(path: "some/path", slug: ""),
            logger: logger
        )
        let result = try detector.detect(explicitType: nil)
        #expect(result == definitions[3])
    }
}
