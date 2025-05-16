//
//  ContentFilterTestSuite.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 04. 18..
//

import Foundation
import Testing
import ToucanModels
import ToucanContent
import ToucanTesting
import Logging
@testable import ToucanSDK

@Suite
struct ContentFilterTestSuite {

    @Test()
    func genericFilterRules() async throws {
        let sourceBundle = SourceBundle.Mocks.complete()
        let posts = sourceBundle.contents

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
                )
            ]
        )

        let now = Date().timeIntervalSince1970
        let res = filter.applyRules(contents: posts, now: now)

        let expGroups = Dictionary(
            grouping: sourceBundle.contents,
            by: { $0.definition.id }
        )

        let resGroups = Dictionary(
            grouping: res,
            by: { $0.definition.id }
        )

        for key in expGroups.keys {

            let exp1 =
                expGroups[key]?
                .filter {
                    $0.properties["title"]?.stringValue()?.hasSuffix("10")
                        ?? $0.properties["name"]?.stringValue()?.hasSuffix("10")
                        ?? false
                } ?? []

            let res1 =
                resGroups[key]?
                .filter {
                    $0.properties["title"]?.stringValue()?.hasSuffix("10")
                        ?? $0.properties["name"]?.stringValue()?.hasSuffix("10")
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
        let sourceBundle = SourceBundle.Mocks.complete()
        let posts = sourceBundle.contents

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
        let now = Date().timeIntervalSince1970
        let res = filter.applyRules(contents: posts, now: now)

        let expGroups = Dictionary(
            grouping: sourceBundle.contents,
            by: { $0.definition.id }
        )

        let resGroups = Dictionary(
            grouping: res,
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
        let sourceBundle = SourceBundle.Mocks.complete()
        let posts = sourceBundle.contents

        let filter = ContentFilter(
            filterRules: [:]
        )

        let now = Date().timeIntervalSince1970
        let res = filter.applyRules(contents: posts, now: now)

        let expGroups = Dictionary(
            grouping: sourceBundle.contents,
            by: { $0.definition.id }
        )

        let resGroups = Dictionary(
            grouping: res,
            by: { $0.definition.id }
        )

        for key in expGroups.keys {
            #expect(expGroups[key]?.count == resGroups[key]?.count)
        }
    }

    @Test()
    func globalDateFilter() async throws {

        let logger = Logger.inMemory(
            label: "ContentFilterTestSuite"
        )
        let target = Target.standard
        let config = Config.defaults
        let sourceConfig = SourceConfig(
            sourceUrl: .init(fileURLWithPath: ""),
            config: config
        )
        let formatter = target.dateFormatter(
            sourceConfig.config.dateFormats.input
        )

        let now = Date()
        let future = now.addingTimeInterval(+86_400)
        let past = now.addingTimeInterval(-86_400)

        let contentDefinition = ContentDefinition(
            id: "post",
            paths: [],
            properties: [
                "publication": .init(
                    propertyType: .date(format: nil),
                    isRequired: true,
                    defaultValue: nil
                ),
                "expiration": .init(
                    propertyType: .date(format: nil),
                    isRequired: true,
                    defaultValue: nil
                ),
            ],
            relations: [:],
            queries: [:]
        )
        let converter = ContentDefinitionConverter(
            contentDefinition: contentDefinition,
            dateFormatter: formatter,
            logger: logger.logger
        )

        let rawContent1 = RawContent(
            origin: .init(path: "test1", slug: "test1"),
            frontMatter: [
                "publication": .init(formatter.string(from: past)),
                "expiration": .init(formatter.string(from: future)),
            ],
            markdown: "no content",
            lastModificationDate: now.timeIntervalSince1970,
            assets: []
        )
        let post1 = converter.convert(rawContent: rawContent1)

        let rawContent2 = RawContent(
            origin: .init(path: "test2", slug: "test2"),
            frontMatter: [
                "publication": .init(formatter.string(from: future)),
                "expiration": .init(formatter.string(from: future)),
            ],
            markdown: "no content",
            lastModificationDate: now.timeIntervalSince1970,
            assets: []
        )
        let post2 = converter.convert(rawContent: rawContent2)

        #expect(logger.handler.messages.isEmpty)

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

        let posts = [post1, post2]

        let res = filter.applyRules(
            contents: posts,
            now: now.timeIntervalSince1970
        )
        #expect(res.count == 1)
        #expect(res[0].slug.value == "test1")
    }

    @Test()
    func draftFilter() async throws {

        let logger = Logger.inMemory(
            label: "ContentFilterTestSuite"
        )
        let target = Target.standard
        let config = Config.defaults
        let sourceConfig = SourceConfig(
            sourceUrl: .init(fileURLWithPath: ""),
            config: config
        )
        let formatter = target.dateFormatter(
            sourceConfig.config.dateFormats.input
        )

        let contentDefinition = ContentDefinition(
            id: "post",
            paths: [],
            properties: [
                "draft": .init(
                    propertyType: .bool,
                    isRequired: false,
                    defaultValue: false
                )
            ],
            relations: [:],
            queries: [:]
        )
        let converter = ContentDefinitionConverter(
            contentDefinition: contentDefinition,
            dateFormatter: formatter,
            logger: logger.logger
        )

        let now = Date()

        let rawContent1 = RawContent(
            origin: .init(path: "test1", slug: "test1"),
            frontMatter: [:],
            markdown: "no content",
            lastModificationDate: now.timeIntervalSince1970,
            assets: []
        )
        let post1 = converter.convert(rawContent: rawContent1)

        let rawContent2 = RawContent(
            origin: .init(path: "test2", slug: "test2"),
            frontMatter: [
                "draft": true
            ],
            markdown: "no content",
            lastModificationDate: now.timeIntervalSince1970,
            assets: []
        )
        let post2 = converter.convert(rawContent: rawContent2)

        #expect(logger.handler.messages.isEmpty)

        let filter = ContentFilter(
            filterRules: [
                "*": .field(
                    key: "draft",
                    operator: .equals,
                    value: false
                )
            ]
        )

        let posts = [post1, post2]
        let res = filter.applyRules(
            contents: posts,
            now: now.timeIntervalSince1970
        )
        #expect(res.count == 1)
        #expect(res[0].slug.value == "test1")
    }

}
