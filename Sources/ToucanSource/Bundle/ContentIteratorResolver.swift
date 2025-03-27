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
    
public struct ContentIteratorResolver {
    
    func resolveContents(
        sourceBundle: SourceBundle,
        pipeline: Pipeline
    ) -> [Content] {
        
        var finalContents: [Content] = []
        
        for content in sourceBundle.contents {
            
            if let iteratorId = extractIteratorId(from: content.slug) {
                guard
                    let query = pipeline.iterators[iteratorId],
                    pipeline.contentTypes.isAllowed(
                        contentType: query.contentType
                    )
                else {
                    finalContents.append(content)
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

                let total = sourceBundle.run(query: countQuery).count
                let limit = max(1, query.limit ?? 10)
                let numberOfPages = (total + limit - 1) / limit

                struct PageLink: Codable {
                    let number: Int
                    let permalink: String
                    let isCurrent: Bool
                }

                for i in 0..<numberOfPages {
                    let offset = i * limit
                    let currentPageIndex = i + 1

                    let links = (0..<numberOfPages)
                        .map { i in
                            let pageIndex = i + 1
                            let slug = content.slug.replacingOccurrences([
                                "{{\(iteratorId)}}": String(pageIndex)
                            ])
                            return PageLink(
                                number: pageIndex,
                                permalink: slug.permalink(
                                    baseUrl: sourceBundle.settings.baseUrl
                                ),
                                isCurrent: pageIndex == currentPageIndex
                            )
                        }

                    let pageItems = sourceBundle.run(
                        query: .init(
                            contentType: query.contentType,
                            limit: limit,
                            offset: offset,
                            filter: query.filter,
                            orderBy: query.orderBy
                        )
                    )

                    let id = content.id.replacingOccurrences([
                        "{{\(iteratorId)}}": String(currentPageIndex)
                    ])
                    let slug = content.slug.replacingOccurrences([
                        "{{\(iteratorId)}}": String(currentPageIndex)
                    ])

                    var alteredContent = content
                    alteredContent.id = id
                    alteredContent.slug = slug

                    let number = currentPageIndex
                    let total = numberOfPages

                    replaceMap(number: number, total: total, array: &alteredContent.properties)
                    replaceMap(number: number, total: total, array: &alteredContent.userDefined)
                    
                    alteredContent.iteratorContext = [
                        "scopeKey": .init(query.scope ?? "list"),
                        "pageItems": .init(pageItems),
                        "total": .init(total),
                        "limit": .init(limit),
                        "current": .init(currentPageIndex),
                        "links": .init(links),
                    ]
                    
                    finalContents.append(alteredContent)
                }
                
            } else {
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
    
    private func replaceMap(
        number: Int,
        total: Int,
        array: inout [String: AnyCodable]
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
