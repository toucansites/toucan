//
//  ContentConverterTestSuite.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 02. 20..
//
//
import Foundation
import Testing
import Logging
import ToucanSource
import ToucanSerialization
@testable import ToucanSDK

@Suite
struct ContentConverterTestSuite {

    @Test
    func contentConversion() throws {
        let now = Date()
        let buildTargetSource = Mocks.buildTargetSource(now: now)
        let encoder = ToucanYAMLEncoder()
        let decoder = ToucanYAMLDecoder()

        let converter = ContentConverter(
            buildTargetSource: buildTargetSource,
            encoder: encoder,
            decoder: decoder
        )

        let targetContents = try converter.convertTargetContents()
        #expect(!targetContents.isEmpty)
        #expect(buildTargetSource.rawContents.count == targetContents.count)
        for rawContent in buildTargetSource.rawContents {
            guard
                let item = targetContents.first(
                    where: { $0.rawValue == rawContent }
                )
            else {
                Issue.record("Missing content `\(rawContent.origin.slug)`.")
                return
            }
            #expect(!item.isIterator)
            print("----------------")
            print(item.rawValue.origin.slug)
            print(item.definition.id)
        }
    }

    //    @Test()
    //    func contentDefinitionConverter() async throws {
    //        let logger = Logger(label: "ContentDefinitionConverterTestSuite")
    //        let target = Target.standard
    //        let config = Config.defaults
    //        let sourceConfig = SourceLocations(
    //            sourceUrl: .init(fileURLWithPath: ""),
    //            config: config
    //        )
    //        let formatter = target.dateFormatter(
    //            sourceConfig.config.dateFormats.input
    //        )
    //        let now = Date()
    //
    //        let contentDefinition = ContentDefinition(
    //            id: "definition",
    //            paths: [],
    //            properties: [
    //                "customFormat": .init(
    //                    propertyType: .date(format: .init(format: "y-MM-d")),
    //                    isRequired: true,
    //                    defaultValue: nil
    //                ),
    //                "customFormatDefaultValue": .init(
    //                    propertyType: .date(format: .init(format: "y-MM-d")),
    //                    isRequired: true,
    //                    defaultValue: .init("2021-03-03")
    //                ),
    //                "defaultFormat": .init(
    //                    propertyType: .date(format: nil),
    //                    isRequired: true,
    //                    defaultValue: nil
    //                ),
    //            ],
    //            relations: [:],
    //            queries: [:]
    //        )
    //        let rawContent = RawContent(
    //            origin: .init(path: "test", slug: "test"),
    //            frontMatter: [
    //                "customFormat": .init("2021-03-05"),
    //                /// `customFormatDefaultValue` not provided on purpose
    //                "defaultFormat": .init("2025-03-30T09:23:14.870Z"),
    //            ],
    //            markdown: "no content",
    //            lastModificationDate: now.timeIntervalSince1970,
    //            assets: []
    //        )
    //        let converter = ContentDefinitionConverter(
    //            contentDefinition: contentDefinition,
    //            dateFormatter: formatter,
    //            logger: logger
    //        )
    //
    //        let result = converter.convert(rawContent: rawContent)
    //
    //        #expect(result.properties["customFormat"] == .init(1614902400.0))
    //        #expect(
    //            result.properties["customFormatDefaultValue"] == .init(1614729600.0)
    //        )
    //        #expect(result.properties["defaultFormat"] == .init(1743326594.87))
    //    }
    //
    //    @Test()
    //    func contentDefinitionConverter_InvalidValue() async throws {
    //        let logger = Logger(label: "ContentDefinitionConverterTestSuite")
    //        let target = Target.standard
    //        let config = Config.defaults
    //        let sourceConfig = SourceLocations(
    //            sourceUrl: .init(fileURLWithPath: ""),
    //            config: config
    //        )
    //        let formatter = target.dateFormatter(
    //            sourceConfig.config.dateFormats.input
    //        )
    //        let now = Date()
    //
    //        let contentDefinition = ContentDefinition(
    //            id: "definition",
    //            paths: [],
    //            properties: [
    //                "monthAndDay": .init(
    //                    propertyType: .date(format: .init(format: "MM-d")),
    //                    isRequired: true,
    //                    defaultValue: nil
    //                )
    //            ],
    //            relations: [:],
    //            queries: [:]
    //        )
    //        let rawContent = RawContent(
    //            origin: .init(path: "test", slug: "test"),
    //            frontMatter: [
    //                "monthAndDay": .init("2021-03-05")
    //            ],
    //            markdown: "no content",
    //            lastModificationDate: now.timeIntervalSince1970,
    //            assets: []
    //        )
    //        let converter = ContentDefinitionConverter(
    //            contentDefinition: contentDefinition,
    //            dateFormatter: formatter,
    //            logger: logger
    //        )
    //
    //        let result = converter.convert(rawContent: rawContent)
    //
    //        #expect(result.properties.isEmpty)
    //    }
    //
    //    @Test()
    //    func contentDefinitionConverter_InvalidValueWithDefaultValue() async throws
    //    {
    //        let logger = Logger(label: "ContentDefinitionConverterTestSuite")
    //        let target = Target.standard
    //        let config = Config.defaults
    //        let sourceConfig = SourceLocations(
    //            sourceUrl: .init(fileURLWithPath: ""),
    //            config: config
    //        )
    //        let formatter = target.dateFormatter(
    //            sourceConfig.config.dateFormats.input
    //        )
    //        let now = Date()
    //
    //        let contentDefinition = ContentDefinition(
    //            id: "definition",
    //            paths: [],
    //            properties: [
    //                "monthAndDay": .init(
    //                    propertyType: .date(format: .init(format: "MM-d")),
    //                    isRequired: true,
    //                    defaultValue: .init("03-30")
    //                )
    //            ],
    //            relations: [:],
    //            queries: [:]
    //        )
    //        let rawContent = RawContent(
    //            origin: .init(path: "test", slug: "test"),
    //            frontMatter: [
    //                "monthAndDay": .init("2021-03-05")
    //            ],
    //            markdown: "no content",
    //            lastModificationDate: now.timeIntervalSince1970,
    //            assets: []
    //        )
    //        let converter = ContentDefinitionConverter(
    //            contentDefinition: contentDefinition,
    //            dateFormatter: formatter,
    //            logger: logger
    //        )
    //
    //        let result = converter.convert(rawContent: rawContent)
    //
    //        #expect(result.properties.isEmpty)
    //    }
    //
    //    @Test()
    //    func contentDefinitionConverter_rawDateNotString() async throws {
    //
    //        //        let logging = Logger.inMemory(
    //        //            label: "ContentDefinitionConverterTestSuite"
    //        //        )
    //        let target = Target.standard
    //        let config = Config.defaults
    //        let sourceConfig = SourceLocations(
    //            sourceUrl: .init(fileURLWithPath: ""),
    //            config: config
    //        )
    //        let formatter = target.dateFormatter(
    //            sourceConfig.config.dateFormats.input
    //        )
    //        let now = Date()
    //
    //        let contentDefinition = ContentDefinition(
    //            id: "definition",
    //            paths: [],
    //            properties: [
    //                "customFormat": .init(
    //                    propertyType: .date(format: .init(format: "y-MM-d")),
    //                    isRequired: true,
    //                    defaultValue: nil
    //                ),
    //                "customFormatDefaultValue": .init(
    //                    propertyType: .date(format: .init(format: "y-MM-d")),
    //                    isRequired: true,
    //                    defaultValue: .init("2021-03-03")
    //                ),
    //                "defaultFormat": .init(
    //                    propertyType: .date(format: nil),
    //                    isRequired: true,
    //                    defaultValue: nil
    //                ),
    //            ],
    //            relations: [:],
    //            queries: [:]
    //        )
    //        let rawContent = RawContent(
    //            origin: .init(path: "test", slug: "test"),
    //            frontMatter: [
    //                "customFormat": .init(3000),
    //                /// `customFormatDefaultValue` not provided on purpose
    //                "defaultFormat": nil,
    //            ],
    //            markdown: "no content",
    //            lastModificationDate: now.timeIntervalSince1970,
    //            assets: []
    //        )
    //        let converter = ContentDefinitionConverter(
    //            contentDefinition: contentDefinition,
    //            dateFormatter: formatter,
    //            logger: .init(label: "test")
    //        )
    //
    //        _ = converter.convert(rawContent: rawContent)
    //        //        let logResults = logging.handler.messages.filter {
    //        //            $0.description.contains("Raw date property is not a string")
    //        //        }
    //        //        #expect(logResults.count == 2)
    //    }
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

}
