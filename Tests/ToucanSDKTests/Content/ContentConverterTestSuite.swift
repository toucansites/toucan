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
import ToucanCore
import ToucanSource
import ToucanSerialization
@testable import ToucanSDK

@Suite
struct ContentConverterTestSuite {

    @Test
    func contentBasicConversion() throws {
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

            // check type identifiers
            if ![
                "",
                "404",
                "about",
                "home-old",
                "about-old",
            ]
            .contains(item.rawValue.origin.slug) {
                #expect(item.rawValue.origin.slug.contains(item.definition.id))
            }
            else {
                if ["", "404", "about"].contains(item.rawValue.origin.slug) {
                    #expect(item.definition.id == "page")
                }
                else {
                    #expect(item.definition.id == "redirect")
                }
            }
            print(item.definition.id)
        }
    }

    // MARK: - content types

    //        catch let error as ToucanError {
    //            print(error.logMessageStack())
    //            if let context = error.lookup({
    //                if case DecodingError.dataCorrupted(let ctx) = $0 {
    //                    return ctx
    //                }
    //                return nil
    //            }) {
    //                let expected = "The given data was not valid YAML."
    //                #expect(context.debugDescription == expected)
    //            }
    //            else {
    //                throw error
    //            }
    //        }

    @Test
    func defaultContentDefinition() throws {
        let now = Date()
        let buildTargetSource = BuildTargetSource(
            location: .init(filePath: ""),
            contentDefinitions: [
                .init(
                    id: "page",
                    default: true
                ),
                .init(
                    id: "post"
                ),
            ],
            rawContents: [
                .init(
                    origin: .init(
                        path: "hello",
                        slug: "hello"
                    ),
                    lastModificationDate: now.timeIntervalSince1970
                )
            ]
        )

        let validator = BuildTargetSourceValidator(
            buildTargetSource: buildTargetSource
        )
        try validator.validate()

        let encoder = ToucanYAMLEncoder()
        let decoder = ToucanYAMLDecoder()
        let converter = ContentConverter(
            buildTargetSource: buildTargetSource,
            encoder: encoder,
            decoder: decoder
        )

        let targetContents = try converter.convertTargetContents()
        #expect(targetContents.count == 1)
        let content = try #require(targetContents.first)
        #expect(content.definition.id == "page")
    }

    @Test
    func explicitContentDefinition() throws {
        let now = Date()
        let buildTargetSource = BuildTargetSource(
            location: .init(filePath: ""),
            contentDefinitions: [
                .init(
                    id: "page",
                    default: true
                ),
                .init(
                    id: "post",
                    paths: [
                        "posts"
                    ]
                ),
            ],
            rawContents: [
                .init(
                    origin: .init(
                        path: "posts/hello",
                        slug: "posts/hello"
                    ),
                    markdown: .init(
                        frontMatter: [
                            "type": "post"
                        ]
                    ),
                    lastModificationDate: now.timeIntervalSince1970
                )
            ]
        )

        let validator = BuildTargetSourceValidator(
            buildTargetSource: buildTargetSource
        )
        try validator.validate()

        let encoder = ToucanYAMLEncoder()
        let decoder = ToucanYAMLDecoder()
        let converter = ContentConverter(
            buildTargetSource: buildTargetSource,
            encoder: encoder,
            decoder: decoder
        )

        let targetContents = try converter.convertTargetContents()
        #expect(targetContents.count == 1)
        let content = try #require(targetContents.first)
        #expect(content.definition.id == "post")
    }

    @Test
    func pathBasedContentDefinition() throws {
        let now = Date()
        let buildTargetSource = BuildTargetSource(
            location: .init(filePath: ""),
            contentDefinitions: [
                .init(
                    id: "page",
                    default: true
                ),
                .init(
                    id: "post",
                    paths: [
                        "posts"
                    ]
                ),
            ],
            rawContents: [
                .init(
                    origin: .init(
                        path: "posts/hello",
                        slug: "posts/hello"
                    ),
                    lastModificationDate: now.timeIntervalSince1970
                )
            ]
        )

        let validator = BuildTargetSourceValidator(
            buildTargetSource: buildTargetSource
        )
        try validator.validate()

        let encoder = ToucanYAMLEncoder()
        let decoder = ToucanYAMLDecoder()
        let converter = ContentConverter(
            buildTargetSource: buildTargetSource,
            encoder: encoder,
            decoder: decoder
        )

        let targetContents = try converter.convertTargetContents()
        #expect(targetContents.count == 1)
        let content = try #require(targetContents.first)
        #expect(content.definition.id == "post")
    }

    // MARK: - properties

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

}
