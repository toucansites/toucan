//
//  ContentDefinitionDetectorTestSuite.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 03. 10..
//
//
//import Foundation
//import Testing
//import Logging
//
//
//@testable import ToucanSDK
//
//@Suite
//struct ContentDefinitionDetectorTestSuite {
//
//    @Test
//    func explicitContentDefinition() throws {
//        let logger = Logger(label: "ContentDefinitionDetectorTestSuite")
//        let definitions = [
//            ContentDefinition.Mocks.author(),
//            ContentDefinition.Mocks.post(),
//            ContentDefinition.Mocks.tag(),
//            ContentDefinition.Mocks.page(),
//        ]
//        let detector = ContentDefinitionDetector(
//            definitions: definitions,
//            origin: .init(path: "blog/authors", slug: ""),
//            logger: logger
//        )
//        let result = try detector.detect(explicitType: "author")
//        #expect(result == definitions[0])
//    }
//
//    @Test
//    func pathsContentDefinition() throws {
//        let logger = Logger(label: "ContentDefinitionDetectorTestSuite")
//        let definitions = [
//            ContentDefinition.Mocks.author(),
//            ContentDefinition.Mocks.post(),
//            ContentDefinition.Mocks.tag(),
//            ContentDefinition.Mocks.page(),
//        ]
//        let detector = ContentDefinitionDetector(
//            definitions: definitions,
//            origin: .init(path: "blog/authors", slug: ""),
//            logger: logger
//        )
//        let result = try detector.detect(explicitType: nil)
//        #expect(result == definitions[0])
//    }
//
//    @Test
//    func defaultContentDefinition() throws {
//        let logger = Logger(label: "ContentDefinitionDetectorTestSuite")
//        let definitions = [
//            ContentDefinition.Mocks.author(),
//            ContentDefinition.Mocks.post(),
//            ContentDefinition.Mocks.tag(),
//            ContentDefinition.Mocks.page(),
//        ]
//        let detector = ContentDefinitionDetector(
//            definitions: definitions,
//            origin: .init(path: "some/path", slug: ""),
//            logger: logger
//        )
//        let result = try detector.detect(explicitType: nil)
//        #expect(result == definitions[3])
//    }
//
//    @Test
//    func noDefaultContentDefinitionFound() throws {
//        let logger = Logger(label: "ContentDefinitionDetectorTestSuite")
//        let definitions = [
//            ContentDefinition.Mocks.author()
//        ]
//        let detector = ContentDefinitionDetector(
//            definitions: definitions,
//            origin: .init(path: "some/path", slug: "slug"),
//            logger: logger
//        )
//
//        do {
//            _ = try detector.detect(explicitType: nil)
//        }
//        catch let error {
//            #expect(
//                error.localizedDescription.contains(
//                    "ContentDefinitionDetector.Failure"
//                )
//            )
//        }
//    }
//
//    @Test
//    func multipleDefaultContentDefinitionsFound() throws {
//        let logger = Logger(label: "ContentDefinitionDetectorTestSuite")
//        let definitions = [
//            ContentDefinition.Mocks.author(isDefault: true),
//            ContentDefinition.Mocks.page(),
//        ]
//        let detector = ContentDefinitionDetector(
//            definitions: definitions,
//            origin: .init(path: "some/path", slug: "slug"),
//            logger: logger
//        )
//
//        do {
//            _ = try detector.detect(explicitType: nil)
//        }
//        catch let error {
//            #expect(
//                error.localizedDescription.contains(
//                    "ContentDefinitionDetector.Failure"
//                )
//            )
//        }
//    }
//
//    @Test
//    func noExplicitContentDefinitionFound() throws {
//        let logger = Logger(label: "ContentDefinitionDetectorTestSuite")
//        let definitions = [
//            ContentDefinition.Mocks.post(),
//            ContentDefinition.Mocks.tag(),
//            ContentDefinition.Mocks.page(),
//        ]
//        let detector = ContentDefinitionDetector(
//            definitions: definitions,
//            origin: .init(path: "blog/authors", slug: ""),
//            logger: logger
//        )
//
//        do {
//            _ = try detector.detect(explicitType: "author")
//        }
//        catch let error {
//            #expect(
//                error.localizedDescription.contains(
//                    "ContentDefinitionDetector.Failure"
//                )
//            )
//        }
//    }
//
//}
