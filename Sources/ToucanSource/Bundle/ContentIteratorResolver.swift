//
//  ContentIteratorResolver.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 04. 15..

//
//  ContextBundleCreator.swift
//
//  Created by gerp83 on 2025. 03. 26.
//

import Foundation
import ToucanModels
import ToucanContent
import FileManagerKit
import Logging

struct ContentIteratorResolver {

    var baseUrl: String
    var now: TimeInterval

    func resolve(
        contents: [Content],
        using pipeline: Pipeline
    ) -> [Content] {
        var finalContents: [Content] = []

        for content in contents {
            if let iteratorId = content.slug.extractIteratorId() {
                guard
                    let query = pipeline.iterators[iteratorId]
                else {
                    continue
                }

                let countQuery = Query(
                    contentType: query.contentType,
                    scope: query.scope,
                    limit: nil,
                    offset: nil,
                    filter: query.filter,
                    orderBy: query.orderBy
                )

                let total = contents.run(query: countQuery, now: now).count
                let limit = max(1, query.limit ?? 10)
                let numberOfPages = (total + limit - 1) / limit

                for i in 0..<numberOfPages {
                    let offset = i * limit
                    let currentPageIndex = i + 1

                    var alteredContent = content
                    rewrite(
                        iteratorId: iteratorId,
                        pageIndex: currentPageIndex,
                        &alteredContent.id
                    )
                    rewrite(
                        iteratorId: iteratorId,
                        pageIndex: currentPageIndex,
                        &alteredContent.slug.value
                    )
                    rewrite(
                        number: currentPageIndex,
                        total: numberOfPages,
                        &alteredContent.properties
                    )
                    rewrite(
                        number: currentPageIndex,
                        total: numberOfPages,
                        &alteredContent.userDefined
                    )

                    if !alteredContent.rawValue.markdown.isEmpty {
                        alteredContent.rawValue.markdown = replace(
                            in: alteredContent.rawValue.markdown,
                            number: currentPageIndex,
                            total: numberOfPages
                        )
                    }

                    let links = (0..<numberOfPages)
                        .map { i in
                            let pageIndex = i + 1
                            let permalink = content.slug.permalink(
                                baseUrl: baseUrl
                            )
                            return IteratorInfo.Link(
                                number: pageIndex,
                                permalink: permalink.replacingOccurrences(
                                    ["{{\(iteratorId)}}": String(pageIndex)]),
                                isCurrent: pageIndex == currentPageIndex
                            )
                        }

                    let items = contents.run(
                        query: .init(
                            contentType: query.contentType,
                            limit: limit,
                            offset: offset,
                            filter: query.filter,
                            orderBy: query.orderBy
                        ),
                        now: now
                    )

                    alteredContent.iteratorInfo = .init(
                        current: currentPageIndex,
                        total: numberOfPages,
                        limit: limit,
                        items: items,
                        links: links,
                        scope: query.scope
                    )

                    finalContents.append(alteredContent)
                }

            }
            else {
                finalContents.append(content)
            }
        }
        return finalContents
    }

    // MARK: - rewrite

    private func rewrite(
        iteratorId: String,
        pageIndex: Int,
        _ value: inout String
    ) {
        value = value.replacingOccurrences([
            "{{\(iteratorId)}}": String(pageIndex)
        ])
    }

    private func rewrite(
        number: Int,
        total: Int,
        _ array: inout [String: AnyCodable]
    ) {
        for (key, _) in array {
            if let stringValue = array[key]?.stringValue() {
                array[key] = .init(
                    replace(
                        in: stringValue,
                        number: number,
                        total: total
                    )
                )
            }
        }
    }

    private func replace(
        in value: String,
        number: Int,
        total: Int
    ) -> String {
        value.replacingOccurrences([
            "{{number}}": String(number),
            "{{total}}": String(total),
        ])
    }

}
