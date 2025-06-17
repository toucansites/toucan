//
//  ContentResolverTestSuite.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 02. 20..
//
//
import Foundation
import Logging
import Testing
import ToucanCore
@testable import ToucanSDK
import ToucanSerialization
import ToucanSource

@Suite
struct ContentResolverTestSuite {
    // MARK: -

    private func getMockresolver(
        buildTargetSource: BuildTargetSource,
        now _: Date
    ) throws -> ContentResolver {
        let encoder = ToucanYAMLEncoder()
        let decoder = ToucanYAMLDecoder()
        let dateFormatter = ToucanInputDateFormatter(
            dateConfig: buildTargetSource.config.dataTypes.date
        )

        return .init(
            contentTypeResolver: .init(
                types: buildTargetSource.contentDefinitions,
                pipelines: buildTargetSource.pipelines
            ),
            encoder: encoder,
            decoder: decoder,
            dateFormatter: dateFormatter
        )
    }

    @Test
    func contentBasicConversion() throws {
        let now = Date()
        let buildTargetSource = Mocks.buildTargetSource(now: now)
        let encoder = ToucanYAMLEncoder()
        let decoder = ToucanYAMLDecoder()
        let dateFormatter = ToucanInputDateFormatter(
            dateConfig: buildTargetSource.config.dataTypes.date
        )

        let resolver = ContentResolver(
            contentTypeResolver: .init(
                types: buildTargetSource.contentDefinitions,
                pipelines: buildTargetSource.pipelines
            ),
            encoder: encoder,
            decoder: decoder,
            dateFormatter: dateFormatter
        )

        let targetContents = try resolver.convert(
            rawContents: buildTargetSource.rawContents
        )
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

            let notFoundPages = ["404"]
            let specialPages = ["", "about", "context"]
            let redirectPages = ["home-old", "about-old"]
            // check type identifiers
            if !(specialPages + redirectPages + notFoundPages)
                .contains(item.rawValue.origin.slug)
            {
                #expect(item.rawValue.origin.slug.contains(item.type.id))
            }
            else {
                if specialPages.contains(item.rawValue.origin.slug) {
                    #expect(item.type.id == "page")
                }
                else if notFoundPages.contains(item.rawValue.origin.slug) {
                    #expect(item.type.id == "not-found")
                }
                else {
                    #expect(item.type.id == "redirect")
                }
            }
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
            locations: .init(
                sourceURL: .init(filePath: ""),
                config: .defaults
            ),
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
                        path: .init("hello"),
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
        let resolver = ContentResolver(
            contentTypeResolver: .init(
                types: buildTargetSource.contentDefinitions,
                pipelines: buildTargetSource.pipelines
            ),
            encoder: encoder,
            decoder: decoder,
            dateFormatter: .init(
                dateConfig: buildTargetSource.config.dataTypes.date
            )
        )

        let targetContents = try resolver.convert(
            rawContents: buildTargetSource.rawContents
        )
        #expect(targetContents.count == 1)
        let content = try #require(targetContents.first)
        #expect(content.type.id == "page")
    }

    @Test
    func explicitContentDefinition() throws {
        let now = Date()
        let buildTargetSource = BuildTargetSource(
            locations: .init(
                sourceURL: .init(filePath: ""),
                config: .defaults
            ),
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
                        path: .init("posts/hello"),
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
        let resolver = ContentResolver(
            contentTypeResolver: .init(
                types: buildTargetSource.contentDefinitions,
                pipelines: buildTargetSource.pipelines
            ),
            encoder: encoder,
            decoder: decoder,
            dateFormatter: .init(
                dateConfig: buildTargetSource.config.dataTypes.date
            )
        )

        let targetContents = try resolver.convert(
            rawContents: buildTargetSource.rawContents
        )
        #expect(targetContents.count == 1)
        let content = try #require(targetContents.first)
        #expect(content.type.id == "post")
    }

    @Test
    func pathBasedContentDefinition() throws {
        let now = Date()
        let buildTargetSource = BuildTargetSource(
            locations: .init(
                sourceURL: .init(filePath: ""),
                config: .defaults
            ),
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
                        path: .init("posts/hello"),
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
        let resolver = ContentResolver(
            contentTypeResolver: .init(
                types: buildTargetSource.contentDefinitions,
                pipelines: buildTargetSource.pipelines
            ),
            encoder: encoder,
            decoder: decoder,
            dateFormatter: .init(
                dateConfig: buildTargetSource.config.dataTypes.date
            )
        )

        let targetContents = try resolver.convert(
            rawContents: buildTargetSource.rawContents
        )
        #expect(targetContents.count == 1)
        let content = try #require(targetContents.first)
        #expect(content.type.id == "post")
    }

    @Test()
    func allPropertyTypeConversion() async throws {
        let now = Date()
        let buildTargetSource = BuildTargetSource(
            locations: .init(
                sourceURL: .init(filePath: ""),
                config: .defaults
            ),
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
                        path: .init("test"),
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
        let resolver = ContentResolver(
            contentTypeResolver: .init(
                types: buildTargetSource.contentDefinitions,
                pipelines: buildTargetSource.pipelines
            ),
            encoder: encoder,
            decoder: decoder,
            dateFormatter: .init(
                dateConfig: buildTargetSource.config.dataTypes.date
            )
        )

        let targetContents = try resolver.convert(
            rawContents: buildTargetSource.rawContents
        )
        #expect(targetContents.count == 1)
        let result = try #require(targetContents.first).properties
        #expect(result.count == 6)
        #expect(result["string"] == "foo")
        #expect(result["bool"] == true)
        #expect(result["int"] == 42)
        #expect(result["double"] == 3.14)
        #expect(result["date"] == 1_743_326_594.87)
        // TODO: what do we expect here?
        // #expect(result["array"] == .init(["1", "2"]))
    }

    @Test()
    func contentDatePropertyConversion() async throws {
        let now = Date()
        let buildTargetSource = BuildTargetSource(
            locations: .init(
                sourceURL: .init(filePath: ""),
                config: .defaults
            ),
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
                        path: .init("test"),
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
        let resolver = ContentResolver(
            contentTypeResolver: .init(
                types: buildTargetSource.contentDefinitions,
                pipelines: buildTargetSource.pipelines
            ),
            encoder: encoder,
            decoder: decoder,
            dateFormatter: .init(
                dateConfig: buildTargetSource.config.dataTypes.date
            )
        )

        let targetContents = try resolver.convert(
            rawContents: buildTargetSource.rawContents
        )
        #expect(targetContents.count == 1)
        let result = try #require(targetContents.first).properties

        #expect(
            result["customFormat"] == .init(1_614_902_400.0)
        )
        #expect(
            result["customFormatDefaultValue"] == .init(1_614_729_600.0)
        )
        #expect(
            result["defaultFormat"] == .init(1_743_326_594.87)
        )
    }

    @Test()
    func contentDatePropertyConversionInvalidValue() async throws {
        let now = Date()
        let buildTargetSource = BuildTargetSource(
            locations: .init(
                sourceURL: .init(filePath: ""),
                config: .defaults
            ),
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
                        path: .init("test"),
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
        let resolver = ContentResolver(
            contentTypeResolver: .init(
                types: buildTargetSource.contentDefinitions,
                pipelines: buildTargetSource.pipelines
            ),
            encoder: encoder,
            decoder: decoder,
            dateFormatter: .init(
                dateConfig: buildTargetSource.config.dataTypes.date
            )
        )

        do {
            _ = try resolver.convert(
                rawContents: buildTargetSource.rawContents
            )
            Issue.record("Should result in an invalid property error.")
        }
        catch {
            switch error {
            case let .invalidProperty(name, value, slug):
                #expect(name == "monthAndDay")
                #expect(value == "2021-03-05")
                #expect(slug == "test")
            default:
                Issue.record("Invalid error result.")
            }
        }
    }

    @Test()
    func contentDatePropertyConversionInvalidValueWithDefaultValue()
        async throws
    {
        let now = Date()
        let buildTargetSource = BuildTargetSource(
            locations: .init(
                sourceURL: .init(filePath: ""),
                config: .defaults
            ),
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
                        path: .init("test"),
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
        let resolver = ContentResolver(
            contentTypeResolver: .init(
                types: buildTargetSource.contentDefinitions,
                pipelines: buildTargetSource.pipelines
            ),
            encoder: encoder,
            decoder: decoder,
            dateFormatter: .init(
                dateConfig: buildTargetSource.config.dataTypes.date
            )
        )

        do {
            _ = try resolver.convert(
                rawContents: buildTargetSource.rawContents
            )
            Issue.record("Should result in an invalid property error.")
        }
        catch {
            switch error {
            case let .invalidProperty(name, value, slug):
                #expect(name == "monthAndDay")
                #expect(value == "2021-03-05")
                #expect(slug == "test")
            default:
                Issue.record("Invalid error result.")
            }
        }
    }

    @Test()
    func genericFilterRules() async throws {
        let now = Date()
        let buildTargetSource = Mocks.buildTargetSource(now: now)
        let resolver = try getMockresolver(
            buildTargetSource: buildTargetSource,
            now: now
        )
        let contents = try resolver.convert(
            rawContents: buildTargetSource.rawContents
        )

        let result = resolver.apply(
            filterRules: [
                "*": .or(
                    [
                        .field(
                            key: "title",
                            operator: .like,
                            value: "1"
                        ),
                        .field(
                            key: "name",
                            operator: .like,
                            value: "1"
                        ),
                    ]
                )
            ],
            to: contents,
            now: now.timeIntervalSince1970
        )

        let expGroups = Dictionary(
            grouping: contents,
            by: { $0.type.id }
        )

        let resGroups = Dictionary(
            grouping: result,
            by: { $0.type.id }
        )

        #expect(result.count < contents.count)

        for key in expGroups.keys {
            let exp1 =
                expGroups[key]?
                .filter {
                    $0.properties["title"]?.stringValue()?.hasSuffix("1")
                        ?? $0.properties["name"]?.stringValue()?
                        .hasSuffix("1")
                        ?? false
                } ?? []

            let res1 =
                resGroups[key]?
                .filter {
                    $0.properties["title"]?.stringValue()?.hasSuffix("1")
                        ?? $0.properties["name"]?.stringValue()?
                        .hasSuffix("1")
                        ?? false
                } ?? []

            #expect(res1.count == exp1.count)
            for i in 0..<res1.count {
                #expect(res1[i].slug == exp1[i].slug)
            }
        }
    }

    @Test()
    func specificFilterRules() async throws {
        let now = Date()
        let buildTargetSource = Mocks.buildTargetSource(now: now)
        let resolver = try getMockresolver(
            buildTargetSource: buildTargetSource,
            now: now
        )
        let contents = try resolver.convert(
            rawContents: buildTargetSource.rawContents
        )

        let result = resolver.apply(
            filterRules: [
                "*": .or(
                    [
                        .field(
                            key: "title",
                            operator: .like,
                            value: "10"
                        ),
                        .field(
                            key: "name",
                            operator: .like,
                            value: "10"
                        ),
                    ]
                ),
                "post": .field(
                    key: "featured",
                    operator: .equals,
                    value: true
                ),
            ],
            to: contents,
            now: now.timeIntervalSince1970
        )

        #expect(result.count < contents.count)

        let expGroups = Dictionary(
            grouping: contents,
            by: { $0.type.id }
        )

        let resGroups = Dictionary(
            grouping: result,
            by: { $0.type.id }
        )

        for key in expGroups.keys {
            let exp1 =
                expGroups[key]?
                .filter {
                    if key == "post" {
                        return $0.properties["featured"]?
                            .boolValue() ?? false
                    }
                    return $0.properties["title"]?.stringValue()?
                        .hasSuffix("10") ?? $0.properties["name"]?
                        .stringValue()?
                        .hasSuffix("10") ?? false
                } ?? []

            let res1 =
                resGroups[key]?
                .filter {
                    if key == "post" {
                        return $0.properties["featured"]?
                            .boolValue() ?? false
                    }
                    return $0.properties["title"]?.stringValue()?
                        .hasSuffix("10") ?? $0.properties["name"]?
                        .stringValue()?
                        .hasSuffix("10") ?? false
                } ?? []

            #expect(res1.count == exp1.count)
            for i in 0..<res1.count {
                #expect(res1[i].slug == exp1[i].slug)
            }
        }
    }

    @Test()
    func noFilterRules() async throws {
        let now = Date()
        let buildTargetSource = Mocks.buildTargetSource(now: now)
        let resolver = try getMockresolver(
            buildTargetSource: buildTargetSource,
            now: now
        )
        let contents = try resolver.convert(
            rawContents: buildTargetSource.rawContents
        )

        let result = resolver.apply(
            filterRules: [:],
            to: contents,
            now: now.timeIntervalSince1970
        )

        #expect(result.count == contents.count)

        let expGroups = Dictionary(
            grouping: contents,
            by: { $0.type.id }
        )

        let resGroups = Dictionary(
            grouping: result,
            by: { $0.type.id }
        )

        for key in expGroups.keys {
            #expect(expGroups[key]?.count == resGroups[key]?.count)
        }
    }

    @Test()
    func globalDateFilter() async throws {
        let now = Date()
        let future = now.addingTimeInterval(+86400)
        let past = now.addingTimeInterval(-86400)

        let config = Config.defaults
        let dateFormatter = ToucanInputDateFormatter(
            dateConfig: config.dataTypes.date
        )

        // make sure we use the same format
        let format: DateFormatterConfig? = config.dataTypes.date.input

        let buildTargetSource = BuildTargetSource(
            locations: .init(
                sourceURL: .init(filePath: ""),
                config: .defaults
            ),
            config: config,
            contentDefinitions: [
                .init(
                    id: "post",
                    default: true,
                    properties: [
                        "publication": .init(
                            propertyType: .date(config: format),
                            isRequired: true
                        ),
                        "expiration": .init(
                            propertyType: .date(config: format),
                            isRequired: true
                        ),
                    ]
                )
            ],
            rawContents: [
                .init(
                    origin: .init(
                        path: .init("test1"),
                        slug: "test1"
                    ),
                    markdown: .init(
                        frontMatter: [
                            "publication": .init(
                                // NOTE: not the best way, but it's ok for tests
                                dateFormatter.string(
                                    from: past,
                                    using: format
                                )
                            ),
                            "expiration": .init(
                                dateFormatter.string(
                                    from: future,
                                    using: format
                                )
                            ),
                        ]
                    ),
                    lastModificationDate: now.timeIntervalSince1970
                ),
                .init(
                    origin: .init(
                        path: .init("test2"),
                        slug: "test2"
                    ),
                    markdown: .init(
                        frontMatter: [
                            "publication": .init(
                                dateFormatter.string(
                                    from: future,
                                    using: format
                                )
                            ),
                            "expiration": .init(
                                dateFormatter.string(
                                    from: future,
                                    using: format
                                )
                            ),
                        ]
                    ),
                    lastModificationDate: now.timeIntervalSince1970
                ),
            ]
        )

        let validator = BuildTargetSourceValidator(
            buildTargetSource: buildTargetSource
        )
        try validator.validate()

        let encoder = ToucanYAMLEncoder()
        let decoder = ToucanYAMLDecoder()
        let resolver = ContentResolver(
            contentTypeResolver: .init(
                types: buildTargetSource.contentDefinitions,
                pipelines: buildTargetSource.pipelines
            ),
            encoder: encoder,
            decoder: decoder,
            dateFormatter: dateFormatter
        )

        let contents = try resolver.convert(
            rawContents: buildTargetSource.rawContents
        )

        let result = resolver.apply(
            filterRules: [
                "post": .and(
                    [
                        .field(
                            key: "publication",
                            operator: .lessThan,
                            value: "{{date.now}}"
                        ),
                        .field(
                            key: "expiration",
                            operator: .greaterThan,
                            value: "{{date.now}}"
                        ),
                    ]
                )
            ],
            to: contents,
            now: now.timeIntervalSince1970
        )
        #expect(result.count == 1)
        #expect(result[0].slug.value == "test1")
    }

    @Test()
    func draftFilter() async throws {
        let now = Date()

        let buildTargetSource = BuildTargetSource(
            locations: .init(
                sourceURL: .init(filePath: ""),
                config: .defaults
            ),
            contentDefinitions: [
                .init(
                    id: "post",
                    default: true,
                    properties: [
                        "draft": .init(
                            propertyType: .bool,
                            isRequired: false,
                            defaultValue: false
                        )
                    ]
                )
            ],
            rawContents: [
                .init(
                    origin: .init(
                        path: .init("test1"),
                        slug: "test1"
                    ),
                    markdown: .init(
                        frontMatter: [
                            "draft": false
                        ]
                    ),
                    lastModificationDate: now.timeIntervalSince1970
                ),
                .init(
                    origin: .init(
                        path: .init("test2"),
                        slug: "test2"
                    ),
                    markdown: .init(
                        frontMatter: [
                            "draft": true
                        ]
                    ),
                    lastModificationDate: now.timeIntervalSince1970
                ),
            ]
        )

        let validator = BuildTargetSourceValidator(
            buildTargetSource: buildTargetSource
        )
        try validator.validate()

        let encoder = ToucanYAMLEncoder()
        let decoder = ToucanYAMLDecoder()
        let resolver = ContentResolver(
            contentTypeResolver: .init(
                types: buildTargetSource.contentDefinitions,
                pipelines: buildTargetSource.pipelines
            ),
            encoder: encoder,
            decoder: decoder,
            dateFormatter: .init(
                dateConfig: buildTargetSource.config.dataTypes.date
            )
        )

        let contents = try resolver.convert(
            rawContents: buildTargetSource.rawContents
        )

        let result = resolver.apply(
            filterRules: [
                "*": .field(
                    key: "draft",
                    operator: .equals,
                    value: false
                )
            ],
            to: contents,
            now: now.timeIntervalSince1970
        )
        #expect(result.count == 1)
        #expect(result[0].slug.value == "test1")
    }

    // MARK: - iterators

    //    @Test
    //    func testExtractIteratorId() throws {
    //        let slug = Slug(value: "posts/page/{{post.pagination}}")
    //        #expect(slug.extractIteratorId() == "post.pagination")
    //    }
    //
    //    @Test
    //    func testExtractNoneIteratorId() throws {
    //        let slug = Slug(value: "slugWithNoPagination")
    //        #expect(slug.extractIteratorId() == nil)
    //    }

    @Test
    func iteratorResolution() async throws {
        let now = Date()
        let buildTargetSource = Mocks.buildTargetSource(now: now)
        let resolver = try getMockresolver(
            buildTargetSource: buildTargetSource,
            now: now
        )
        let baseContents = try resolver.convert(
            rawContents: buildTargetSource.rawContents
        )
        let pipeline = Mocks.Pipelines.html()

        let contents = resolver.apply(
            iterators: pipeline.iterators,
            to: baseContents,
            baseURL: buildTargetSource.target.url.dropTrailingSlash(),
            now: now.timeIntervalSince1970
        )

        let query = Query(
            contentType: "page",
            filter: .field(
                key: "iterator",
                operator: .equals,
                value: true
            )
        )

        let results = contents.run(
            query: query,
            now: now.timeIntervalSince1970
        )

        try #require(results.count == 2)
        #expect(
            results.map(\.slug.value).sorted() == [
                "blog/posts/pages/1",
                "blog/posts/pages/2",
            ]
        )
    }

    // MARK: - asset resolver

    @Test
    func assetBehaviorBasics() async throws {
        let now = Date()
        let buildTargetSource = Mocks.buildTargetSource(now: now)
        let resolver = try getMockresolver(
            buildTargetSource: buildTargetSource,
            now: now
        )
        let baseContents = try resolver.convert(
            rawContents: buildTargetSource.rawContents
        )
        let pipeline = Mocks.Pipelines.html()

        let contents = try resolver.apply(
            assetProperties: pipeline.assets.properties,
            to: baseContents,
            contentsURL: buildTargetSource.locations.contentsURL,
            assetsPath: buildTargetSource.config.contents.assets.path,
            baseURL: buildTargetSource.target.url.dropTrailingSlash()
        )

        let query1 = Query(
            contentType: "post",
        )

        let results1 = contents.run(
            query: query1,
            now: now.timeIntervalSince1970
        )

        try #require(results1.count == 3)

        let images = results1.compactMap {
            $0.properties["image"]?.stringValue()
        }

        #expect(
            images.sorted() == [
                "http://localhost:3000/assets/blog/posts/post-1/cover.jpg",
                "http://localhost:3000/assets/blog/posts/post-2/cover.jpg",
                "http://localhost:3000/assets/blog/posts/post-3/cover.jpg",
            ]
        )

        let query2 = Query(
            contentType: "page",
            filter: .field(
                key: "slug",
                operator: .equals,
                value: "about"
            )
        )

        let results2 = contents.run(
            query: query2,
            now: now.timeIntervalSince1970
        )

        try #require(results2.count == 1)

        let css =
            results2[0].properties["css"]?.arrayValue(as: String.self) ?? []
        let js = results2[0].properties["js"]?.arrayValue(as: String.self) ?? []
        #expect(
            css.sorted() == [
                // @NOTE: maybe support resolving ./assets/file.css ???
                "/assets/about/about.css",
                "http://localhost:3000/assets/about/style.css",
                "https://unpkg.com/test@1.0.0.css",
            ]
        )
        #expect(
            js.sorted() == [
                "main.js"
            ]
        )
    }
}
