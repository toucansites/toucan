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

    func resolve(
        contents: [Content],
        using pipeline: Pipeline
    ) -> [Content] {
        var finalContents: [Content] = []

        for content in contents {
            if let iteratorId = extractIteratorId(from: content.slug) {
                guard
                    let query = pipeline.iterators[iteratorId],
                    pipeline.contentTypes.isAllowed(
                        contentType: query.contentType
                    )
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

                let total = contents.run(query: countQuery).count
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
                        &alteredContent.slug
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

                    let links = (0..<numberOfPages)
                        .map { i in
                            let pageIndex = i + 1
                            let slug = content.slug.replacingOccurrences([
                                "{{\(iteratorId)}}": String(pageIndex)
                            ])
                            return Content.IteratorInfo.Link(
                                number: pageIndex,
                                permalink: slug.permalink(
                                    baseUrl: baseUrl
                                ),
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
                        )
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

    private func extractIteratorId(
        from input: String
    ) -> String? {
        guard
            let startRange = input.range(of: "{{"),
            let endRange = input.range(
                of: "}}",
                range: startRange.upperBound..<input.endIndex
            )
        else {
            return nil
        }
        return .init(input[startRange.upperBound..<endRange.lowerBound])
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

}
