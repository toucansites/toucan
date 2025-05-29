//
//  ContentFilterTestSuite.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 04. 18..
//
//
import Foundation
import Testing
import Logging
import ToucanSerialization
import ToucanSource
@testable import ToucanSDK

@Suite
struct ContentFilterTestSuite {

    private func getContents(
        now: Date
    ) throws -> [Content] {

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

        return try converter.convertTargetContents()
    }

    @Test()
    func genericFilterRules() async throws {
        let now = Date()
        let contents = try getContents(now: now)

        let filter = ContentFilter(
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
            ]
        )

        let result = filter.applyRules(
            contents: contents,
            now: now.timeIntervalSince1970
        )

        let expGroups = Dictionary(
            grouping: contents,
            by: { $0.definition.id }
        )

        let resGroups = Dictionary(
            grouping: result,
            by: { $0.definition.id }
        )

        #expect(result.count < contents.count)

        for key in expGroups.keys {

            let exp1 =
                expGroups[key]?
                .filter {
                    $0.properties["title"]?.stringValue()?.hasSuffix("1")
                        ?? $0.properties["name"]?.stringValue()?.hasSuffix("1")
                        ?? false
                } ?? []

            let res1 =
                resGroups[key]?
                .filter {
                    $0.properties["title"]?.stringValue()?.hasSuffix("1")
                        ?? $0.properties["name"]?.stringValue()?.hasSuffix("1")
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
        let contents = try getContents(now: now)

        let filter = ContentFilter(
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
            ]
        )

        let result = filter.applyRules(
            contents: contents,
            now: now.timeIntervalSince1970
        )

        #expect(result.count < contents.count)

        let expGroups = Dictionary(
            grouping: contents,
            by: { $0.definition.id }
        )

        let resGroups = Dictionary(
            grouping: result,
            by: { $0.definition.id }
        )

        for key in expGroups.keys {

            let exp1 =
                expGroups[key]?
                .filter {
                    if key == "post" {
                        return $0.properties["featured"]?.boolValue() ?? false
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
                        return $0.properties["featured"]?.boolValue() ?? false
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
        let contents = try getContents(now: now)

        let filter = ContentFilter(
            filterRules: [:]
        )

        let result = filter.applyRules(
            contents: contents,
            now: now.timeIntervalSince1970
        )

        #expect(result.count == contents.count)

        let expGroups = Dictionary(
            grouping: contents,
            by: { $0.definition.id }
        )

        let resGroups = Dictionary(
            grouping: result,
            by: { $0.definition.id }
        )

        for key in expGroups.keys {
            #expect(expGroups[key]?.count == resGroups[key]?.count)
        }
    }

    @Test()
    func globalDateFilter() async throws {

        let now = Date()
        let future = now.addingTimeInterval(+86_400)
        let past = now.addingTimeInterval(-86_400)

        let config = Config.defaults
        let dateFormatter = ToucanDateFormatter(
            dateConfig: config.dataTypes.date
        )

        let buildTargetSource = BuildTargetSource(
            location: .init(filePath: ""),
            config: config,
            contentDefinitions: [
                .init(
                    id: "post",
                    default: true,
                    properties: [
                        "publication": .init(
                            propertyType: .date(config: nil),
                            isRequired: true
                        ),
                        "expiration": .init(
                            propertyType: .date(config: nil),
                            isRequired: true
                        ),
                    ]
                )
            ],
            rawContents: [
                .init(
                    origin: .init(
                        path: "test1",
                        slug: "test1"
                    ),
                    markdown: .init(
                        frontMatter: [
                            "publication": .init(
                                // NOTE: not the best way, but it's ok for tests
                                dateFormatter.format(date: past).iso8601
                            ),
                            "expiration": .init(
                                dateFormatter.format(date: future).iso8601
                            ),
                        ]
                    ),
                    lastModificationDate: now.timeIntervalSince1970
                ),
                .init(
                    origin: .init(
                        path: "test2",
                        slug: "test2"
                    ),
                    markdown: .init(
                        frontMatter: [
                            "publication": .init(
                                dateFormatter.format(date: future).iso8601
                            ),
                            "expiration": .init(
                                dateFormatter.format(date: future).iso8601
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
        let converter = ContentConverter(
            buildTargetSource: buildTargetSource,
            encoder: encoder,
            decoder: decoder,
            dateFormatter: dateFormatter
        )

        let contents = try converter.convertTargetContents()

        let filter = ContentFilter(
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
            ]
        )

        let result = filter.applyRules(
            contents: contents,
            now: now.timeIntervalSince1970
        )
        #expect(result.count == 1)
        #expect(result[0].slug.value == "test1")
    }

    @Test()
    func draftFilter() async throws {
        let now = Date()

        let buildTargetSource = BuildTargetSource(
            location: .init(filePath: ""),
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
                        path: "test1",
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
                        path: "test2",
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
        let converter = ContentConverter(
            buildTargetSource: buildTargetSource,
            encoder: encoder,
            decoder: decoder,
            dateFormatter: .init(
                dateConfig: buildTargetSource.config.dataTypes.date
            )
        )

        let contents = try converter.convertTargetContents()

        let filter = ContentFilter(
            filterRules: [
                "*": .field(
                    key: "draft",
                    operator: .equals,
                    value: false
                )
            ]
        )

        let result = filter.applyRules(
            contents: contents,
            now: now.timeIntervalSince1970
        )
        #expect(result.count == 1)
        #expect(result[0].slug.value == "test1")
    }

}
