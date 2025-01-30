//
//  File.swift
//  ToucanV2
//
//  Created by Tibor Bodecs on 2025. 01. 21..
//

import Foundation
import Testing
@testable import ToucanModels

@Suite
struct QueryTestSuite {

    //    @Test
    //    func filters() async throws {
    //        var cb = ContentBundle.authors
    //
    //        cb.pageBundles = cb.pageBundles.map { cb.loadFields(pageBundle: $0) }
    //
    //        {
    //            let pbs = cb.query(
    //                .init(
    //                    contentType: "authors",
    //                    scope: "list",
    //                    limit: 10,
    //                    offset: 0,
    //                    filter: .field(
    //                        key: "name",
    //                        operator: .equals,
    //                        value: "Author 6"
    //                    ),
    //                    orderBy: []
    //                )
    //            )
    //            #expect(pbs.count == 1)
    //            #expect(pbs[0].properties["name"] == .string("Author 6"))
    //        }()
    //
    //        {
    //            let pbs = cb.query(
    //                .init(
    //                    contentType: "authors",
    //                    scope: "list",
    //                    limit: 10,
    //                    offset: 0,
    //                    filter: .or([
    //                        .field(
    //                            key: "name",
    //                            operator: .equals,
    //                            value: "Author 6"
    //                        ),
    //                        .field(
    //                            key: "name",
    //                            operator: .equals,
    //                            value: "Author 4"
    //                        ),
    //                    ]),
    //                    orderBy: [
    //                        .init(key: "name", direction: .desc)
    //                    ]
    //                )
    //            )
    //            #expect(pbs.count == 2)
    //            #expect(pbs[0].properties["name"] == .string("Author 6"))
    //            #expect(pbs[1].properties["name"] == .string("Author 4"))
    //        }()
    //
    //        {
    //            let pbs = cb.query(
    //                .init(
    //                    contentType: "authors",
    //                    scope: "list",
    //                    limit: 10,
    //                    offset: 0,
    //                    filter: .and([
    //                        .field(
    //                            key: "name",
    //                            operator: .equals,
    //                            value: "Author 6"
    //                        ),
    //                        .field(
    //                            key: "name",
    //                            operator: .equals,
    //                            value: "Author 4"
    //                        ),
    //                    ]),
    //                    orderBy: [
    //                        .init(key: "name", direction: .desc)
    //                    ]
    //                )
    //            )
    //            #expect(pbs.count == 0)
    //        }()
    //
    //        {
    //            let pbs = cb.query(
    //                .init(
    //                    contentType: "authors",
    //                    scope: "list",
    //                    limit: 10,
    //                    offset: 0,
    //                    filter: .and([
    //                        .field(
    //                            key: "name",
    //                            operator: .equals,
    //                            value: "Author 6"
    //                        ),
    //                        .field(
    //                            key: "description",
    //                            operator: .like,
    //                            value: "Author description 6"
    //                        ),
    //                    ]),
    //                    orderBy: [
    //                        .init(key: "name", direction: .desc)
    //                    ]
    //                )
    //            )
    //            #expect(pbs.count == 1)
    //            #expect(pbs[0].properties["name"] == .string("Author 6"))
    //        }()
    //
    //        {
    //            let pbs = cb.query(
    //                .init(
    //                    contentType: "authors",
    //                    scope: "list",
    //                    limit: 10,
    //                    offset: 0,
    //                    filter: .field(
    //                        key: "name",
    //                        operator: .in,
    //                        value: ["Author 4", "Author 6"]
    //                    ),
    //                    orderBy: [
    //                        .init(key: "name", direction: .desc)
    //                    ]
    //                )
    //            )
    //            #expect(pbs.count == 2)
    //            #expect(pbs[0].properties["name"] == .string("Author 6"))
    //            #expect(pbs[1].properties["name"] == .string("Author 4"))
    //        }()
    //
    //        {
    //            let pbs = cb.query(
    //                .init(
    //                    contentType: "authors",
    //                    scope: "list",
    //                    limit: 10,
    //                    offset: 0,
    //                    filter: .field(
    //                        key: "name",
    //                        operator: .in,
    //                        value: ["Author 4", "Author 6"]
    //                    ),
    //                    orderBy: [
    //                        .init(key: "name", direction: .desc)
    //                    ]
    //                )
    //            )
    //            #expect(pbs.count == 2)
    //            #expect(pbs[0].properties["name"] == .string("Author 6"))
    //            #expect(pbs[1].properties["name"] == .string("Author 4"))
    //        }()
    //
    //    }
}
