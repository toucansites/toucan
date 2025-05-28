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
        let dateFormatter = ToucanDateFormatter(
            dateConfig: buildTargetSource.config.dataTypes.date
        )

        let converter = ContentConverter(
            buildTargetSource: buildTargetSource,
            encoder: encoder,
            decoder: decoder,
            dateFormatter: dateFormatter
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
            decoder: decoder,
            dateFormatter: .init(
                dateConfig: buildTargetSource.config.dataTypes.date
            )
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
            decoder: decoder,
            dateFormatter: .init(
                dateConfig: buildTargetSource.config.dataTypes.date
            )
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
            decoder: decoder,
            dateFormatter: .init(
                dateConfig: buildTargetSource.config.dataTypes.date
            )
        )

        let targetContents = try converter.convertTargetContents()
        #expect(targetContents.count == 1)
        let content = try #require(targetContents.first)
        #expect(content.definition.id == "post")
    }

    // MARK: - properties

    @Test()
    func allPropertyTypeConversion() async throws {
        let now = Date()
        let buildTargetSource = BuildTargetSource(
            location: .init(filePath: ""),
            contentDefinitions: [
                .init(
                    id: "test",
                    default: true,
                    properties: [
                        "string": .init(
                            propertyType: .string,
                            isRequired: true,
                            defaultValue: nil
                        ),
                        "bool": .init(
                            propertyType: .bool,
                            isRequired: true,
                            defaultValue: .init(2)
                        ),
                        "int": .init(
                            propertyType: .int,
                            isRequired: true,
                            defaultValue: .init(2)
                        ),
                        "double": .init(
                            propertyType: .double,
                            isRequired: true,
                            defaultValue: nil
                        ),
                        "date": .init(
                            propertyType: .date(
                                config: nil
                            ),
                            isRequired: true,
                            defaultValue: nil
                        ),
                        "array": .init(
                            propertyType: .array(
                                of: .string
                            ),
                            isRequired: true,
                            defaultValue: nil
                        ),
                    ]
                )
            ],
            rawContents: [
                .init(
                    origin: .init(
                        path: "test",
                        slug: "test"
                    ),
                    markdown: .init(
                        frontMatter: [
                            "string": .init("foo"),
                            "bool": .init(true),
                            "int": .init(42),
                            "double": .init(3.14),
                            "date": .init("2025-03-30T09:23:14.870Z"),
                            "array": .init(["1", "2"]),
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
            decoder: decoder,
            dateFormatter: .init(
                dateConfig: buildTargetSource.config.dataTypes.date
            )
        )

        let targetContents = try converter.convertTargetContents()
        #expect(targetContents.count == 1)
        let result = try #require(targetContents.first).properties
        #expect(result.count == 6)
        #expect(result["string"] == "foo")
        #expect(result["bool"] == true)
        #expect(result["int"] == 42)
        #expect(result["double"] == 3.14)
        #expect(result["date"] == 1743326594.87)
        // TODO: what do we expect here?
        // #expect(result["array"] == .init(["1", "2"]))
    }

    @Test()
    func contentDatePropertyConversion() async throws {
        let now = Date()
        let buildTargetSource = BuildTargetSource(
            location: .init(filePath: ""),
            contentDefinitions: [
                .init(
                    id: "definition",
                    default: true,
                    properties: [
                        "defaultFormat": .init(
                            propertyType: .date(
                                config: nil
                            ),
                            isRequired: true
                        ),
                        "customFormat": .init(
                            propertyType: .date(
                                config: .init(
                                    localization: .defaults,
                                    format: "y-MM-d"
                                )
                            ),
                            isRequired: true,
                        ),
                        "customFormatDefaultValue": .init(
                            propertyType: .date(
                                config: .init(
                                    localization: .defaults,
                                    format: "y-MM-d"
                                )
                            ),
                            isRequired: true,
                            defaultValue: .init("2021-03-03")
                        ),
                    ]
                )
            ],
            rawContents: [
                .init(
                    origin: .init(
                        path: "test",
                        slug: "test"
                    ),
                    markdown: .init(
                        frontMatter: [
                            "defaultFormat": "2025-03-30T09:23:14.870Z",
                            "customFormat": "2021-03-05",
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
            decoder: decoder,
            dateFormatter: .init(
                dateConfig: buildTargetSource.config.dataTypes.date
            )
        )

        let targetContents = try converter.convertTargetContents()
        #expect(targetContents.count == 1)
        let result = try #require(targetContents.first).properties

        #expect(
            result["customFormat"] == .init(1614902400.0)
        )
        #expect(
            result["customFormatDefaultValue"] == .init(1614729600.0)
        )
        #expect(
            result["defaultFormat"] == .init(1743326594.87)
        )
    }

    @Test()
    func contentDatePropertyConversionInvalidValue() async throws {
        let now = Date()
        let buildTargetSource = BuildTargetSource(
            location: .init(filePath: ""),
            contentDefinitions: [
                .init(
                    id: "test",
                    default: true,
                    properties: [
                        "monthAndDay": .init(
                            propertyType: .date(
                                config: .init(
                                    localization: .defaults,
                                    format: "MM-d"
                                )
                            ),
                            isRequired: true
                        )
                    ]
                )
            ],
            rawContents: [
                .init(
                    origin: .init(
                        path: "test",
                        slug: "test"
                    ),
                    markdown: .init(
                        frontMatter: [
                            "monthAndDay": .init("2021-03-05")
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
            decoder: decoder,
            dateFormatter: .init(
                dateConfig: buildTargetSource.config.dataTypes.date
            )
        )

        let targetContents = try converter.convertTargetContents()
        #expect(targetContents.count == 1)
        let result = try #require(targetContents.first).properties
        #expect(result.isEmpty)
    }

    @Test()
    func contentDatePropertyConversionInvalidValueWithDefaultValue()
        async throws
    {
        let now = Date()
        let buildTargetSource = BuildTargetSource(
            location: .init(filePath: ""),
            contentDefinitions: [
                .init(
                    id: "test",
                    default: true,
                    properties: [
                        "monthAndDay": .init(
                            propertyType: .date(
                                config: .init(
                                    localization: .defaults,
                                    format: "MM-d"
                                )
                            ),
                            isRequired: true,
                            defaultValue: .init("03-30")
                        )
                    ]
                )
            ],
            rawContents: [
                .init(
                    origin: .init(
                        path: "test",
                        slug: "test"
                    ),
                    markdown: .init(
                        frontMatter: [
                            "monthAndDay": .init("2021-03-05")
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
            decoder: decoder,
            dateFormatter: .init(
                dateConfig: buildTargetSource.config.dataTypes.date
            )
        )

        let targetContents = try converter.convertTargetContents()
        #expect(targetContents.count == 1)
        let result = try #require(targetContents.first).properties
        #expect(result.isEmpty)
    }

}
