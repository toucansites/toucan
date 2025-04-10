//
//  ContentDefinitionConverterTestSuite.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 02. 20..
//

import Foundation
import Testing
import ToucanModels
import ToucanContent
import ToucanTesting
import Logging
@testable import ToucanSource

@Suite
struct ContentDefinitionConverterTestSuite {

    @Test()
    func contentDefinitionConverter() async throws {
        let logger = Logger(label: "ContentDefinitionConverterTestSuite")
        let settings = Settings.defaults
        let config = Config.defaults
        let sourceConfig = SourceConfig(
            sourceUrl: .init(fileURLWithPath: ""),
            config: config
        )
        let formatter = settings.dateFormatter(
            sourceConfig.config.dateFormats.input
        )
        let now = Date()

        let contentDefinition = ContentDefinition(
            id: "definition",
            paths: [],
            properties: [
                "customFormat": .init(
                    type: .date(format: .init(format: "y-MM-d")),
                    required: true,
                    default: nil
                ),
                "customFormatDefaultValue": .init(
                    type: .date(format: .init(format: "y-MM-d")),
                    required: true,
                    default: .init("2021-03-03")
                ),
                "defaultFormat": .init(
                    type: .date(format: nil),
                    required: true,
                    default: nil
                ),
            ],
            relations: [:],
            queries: [:]
        )
        let rawContent = RawContent(
            origin: .init(path: "test", slug: "test"),
            frontMatter: [
                "customFormat": .init("2021-03-05"),
                /// `customFormatDefaultValue` not provided on purpose
                "defaultFormat": .init("2025-03-30T09:23:14.870Z"),
            ],
            markdown: "no content",
            lastModificationDate: now.timeIntervalSince1970,
            assets: []
        )
        let converter = ContentDefinitionConverter(
            contentDefinition: contentDefinition,
            dateFormatter: formatter,
            logger: logger
        )

        let result = converter.convert(rawContent: rawContent)

        #expect(result.properties["customFormat"] == .init(1614902400.0))
        #expect(
            result.properties["customFormatDefaultValue"] == .init(1614729600.0)
        )
        #expect(result.properties["defaultFormat"] == .init(1743326594.87))
    }

    @Test()
    func contentDefinitionConverter_InvalidValue() async throws {
        let logger = Logger(label: "ContentDefinitionConverterTestSuite")
        let settings = Settings.defaults
        let config = Config.defaults
        let sourceConfig = SourceConfig(
            sourceUrl: .init(fileURLWithPath: ""),
            config: config
        )
        let formatter = settings.dateFormatter(
            sourceConfig.config.dateFormats.input
        )
        let now = Date()

        let contentDefinition = ContentDefinition(
            id: "definition",
            paths: [],
            properties: [
                "monthAndDay": .init(
                    type: .date(format: .init(format: "MM-d")),
                    required: true,
                    default: nil
                )
            ],
            relations: [:],
            queries: [:]
        )
        let rawContent = RawContent(
            origin: .init(path: "test", slug: "test"),
            frontMatter: [
                "monthAndDay": .init("2021-03-05")
            ],
            markdown: "no content",
            lastModificationDate: now.timeIntervalSince1970,
            assets: []
        )
        let converter = ContentDefinitionConverter(
            contentDefinition: contentDefinition,
            dateFormatter: formatter,
            logger: logger
        )

        let result = converter.convert(rawContent: rawContent)

        #expect(result.properties.isEmpty)
    }

    @Test()
    func contentDefinitionConverter_InvalidValueWithDefaultValue() async throws
    {
        let logger = Logger(label: "ContentDefinitionConverterTestSuite")
        let settings = Settings.defaults
        let config = Config.defaults
        let sourceConfig = SourceConfig(
            sourceUrl: .init(fileURLWithPath: ""),
            config: config
        )
        let formatter = settings.dateFormatter(
            sourceConfig.config.dateFormats.input
        )
        let now = Date()

        let contentDefinition = ContentDefinition(
            id: "definition",
            paths: [],
            properties: [
                "monthAndDay": .init(
                    type: .date(format: .init(format: "MM-d")),
                    required: true,
                    default: .init("03-30")
                )
            ],
            relations: [:],
            queries: [:]
        )
        let rawContent = RawContent(
            origin: .init(path: "test", slug: "test"),
            frontMatter: [
                "monthAndDay": .init("2021-03-05")
            ],
            markdown: "no content",
            lastModificationDate: now.timeIntervalSince1970,
            assets: []
        )
        let converter = ContentDefinitionConverter(
            contentDefinition: contentDefinition,
            dateFormatter: formatter,
            logger: logger
        )

        let result = converter.convert(rawContent: rawContent)

        #expect(result.properties.isEmpty)
    }

}
