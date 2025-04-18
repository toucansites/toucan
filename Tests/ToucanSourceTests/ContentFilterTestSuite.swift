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
@testable import ToucanSource

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

        let res = filter.applyRules(contents: posts)

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

        let res = filter.applyRules(contents: posts)

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

        let res = filter.applyRules(contents: posts)

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

}
