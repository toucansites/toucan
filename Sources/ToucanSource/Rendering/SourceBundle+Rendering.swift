//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 02. 11..
//

import Foundation
import ToucanModels
import ToucanCodable

// use this instead of String: Any
struct DateFormats {

    struct Standard {
        let full: String
        let long: String
        let medium: String
        let short: String
    }

    let date: Standard
    let time: Standard
    let custom: [String: String]
}

extension SourceBundle {

    func getDates(
        for timeInterval: Double,
        using formatter: DateFormatter,
        formats: [String: String] = [:]
    ) -> [String: Any] {
        let date = Date(timeIntervalSince1970: timeInterval)

        let styles: [(String, DateFormatter.Style)] = [
            ("full", .full),
            ("long", .long),
            ("medium", .medium),
            ("short", .short),
        ]

        var dateFormats: [String: String] = [:]
        var timeFormats: [String: String] = [:]

        for (key, style) in styles {
            formatter.dateStyle = style
            formatter.timeStyle = .none
            dateFormats[key] = formatter.string(from: date)

            formatter.dateStyle = .none
            formatter.timeStyle = style
            timeFormats[key] = formatter.string(from: date)
        }

        let standard: [String: String] = [
            "iso8601": "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
            "rss": "EEE, dd MMM yyyy HH:mm:ss Z",
            "sitemap": "yyyy-MM-dd",
        ]
        var custom: [String: String] = [:]
        for (k, f) in formats.recursivelyMerged(with: standard) {
            formatter.dateFormat = f
            custom[k] = formatter.string(from: date)
        }

        return [
            "timestamp": timeInterval,
            "date": dateFormats,
            "time": timeFormats,
        ]
        .recursivelyMerged(with: custom)
    }

    func getContextObject(
        for content: Content,
        context: RenderPipeline.Scope.Context,
        using source: SourceBundle,
        allowSubQueries: Bool = true  // allow top level queries only
    ) -> [String: AnyCodable] {

        var result: [String: AnyCodable] = [:]
        if context.contains(.properties) {

            let formatter = DateFormatter()
            formatter.locale = .init(identifier: "hu_HU")
            formatter.timeZone = .init(identifier: "Europe/Budapest")
            //            formatter.locale = .init(identifier: "en_US_POSIX")
            //            formatter.timeZone = .init(secondsFromGMT: 0)

            for (k, v) in content.properties {
                result[k] = .init(v.value)
                // TODO: fix htis
                //                if case let .date(double) = v {
                //                    result[k] = getDates(for: double, using: formatter)
                //                }
            }
            result["slug"] = .init(content.slug)
            result["permalink"] = .init("TODO_DOMAIN/" + content.slug)
            result["isCurrentURL"] = .init(false)
        }
        if allowSubQueries, context.contains(.relations) {
            for (key, relation) in content.definition.relations {
                var orderBy: [Order] = []
                if let order = relation.order {
                    orderBy.append(order)
                }
                let relationContents = source.run(
                    query: .init(
                        contentType: relation.references,
                        scope: "properties",
                        filter: .field(
                            key: "id",
                            operator: .in,
                            value: .init(
                                content.relations[key]?.identifiers ?? []
                            )
                        ),
                        orderBy: orderBy
                    )
                )
                result[key] = .init(
                    relationContents.map {
                        getContextObject(
                            for: $0,
                            context: .properties,
                            using: self,
                            allowSubQueries: false
                        )
                    }
                )
            }

        }
        if context.contains(.contents) {
            // TODO: render using renderer.
            result["contents"] = .init(content.rawValue.markdown)
        }
        if allowSubQueries, context.contains(.queries) {
            for (key, query) in content.definition.queries {
                // TODO: replace {{}} variables in query filter values...
                let queryContents = source.run(
                    query: query.resolveFilterParameters(
                        with: content.queryFields
                    )
                )

                //                print("-----------")
                //                print(query.filter ?? "n/a")
                //                print("")
                //                print(query.resolveFilterParameters(
                //                    with: content.queryFields.mapValues { $0.value }
                //                ).filter ?? "n/a")
                //                print("-------------------------!!!!!!!!!!!!!!")
                result[key] = .init(
                    queryContents.map {
                        getContextObject(
                            for: $0,
                            context: .all,
                            using: self,
                            allowSubQueries: false
                        )
                    }
                )
            }
        }
        return result
    }

    func renderTestCase(
        pipelineContext: [String: AnyCodable],
        pipeline: RenderPipeline
    ) {
        let opt = pipeline.engine.options?.value as? [String: AnyCodable] ?? [:]
        let ct = opt["contentTypes"]?.value as? [String: Any] ?? [:]

        for contentBundle in contentBundles {
            // content pipeline settings
            let cps = ct.dict(contentBundle.definition.type)
            print(contentBundle.definition.type)
            print(cps)

            if pipeline.contentType.contains(.bundle) {
                //                        print("render content bundle...")
                //                        print(contentBundle.definition.type)
                //                        print("--------------------------------------")
            }

            if pipeline.contentType.contains(.single) {

                for content in contentBundle.contents {
                    let context: [String: AnyCodable] = [
                        //                        "global": pipelineContext,
                        "local": .init(
                                getContextObject(
                                    for: content,
                                    context: .all,
                                    using: self
                                )
                            )
                    ]
                    prettyPrint(context)

                }
            }
        }

    }

    func getPipelineContext(
        for pipeline: RenderPipeline
    ) -> [String: AnyCodable] {
        var rawContext: [String: AnyCodable] = [:]
        for (key, query) in pipeline.queries {
            let results = run(query: query)

            let scope = pipeline.getScope(
                keyedBy: query.scope ?? "list",  // TODO: list by default?
                for: query.contentType
            )

            rawContext[key] = .init(results.map {
                getContextObject(
                    for: $0,
                    context: scope.context,
                    using: self
                )
            }
                                    )
        }
        return rawContext
    }

    func renderTest() throws {

        for pipeline in renderPipelines {
            let context = getPipelineContext(for: pipeline)

            switch pipeline.engine.id {
            case "test":
                renderTestCase(pipelineContext: context, pipeline: pipeline)
            default:
                print("ERROR - no such renderer \(pipeline.engine.id)")
            }
        }

    }

}
