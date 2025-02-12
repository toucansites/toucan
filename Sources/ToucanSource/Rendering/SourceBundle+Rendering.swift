//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 02. 11..
//

import Foundation
import FileManagerKit
import ToucanModels
import ToucanCodable

extension SourceBundle {

    func getDates(
        for timeInterval: Double,
        using formatter: DateFormatter,
        formats: [String: String] = [:]
    ) -> DateFormats {
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

        return .init(
            date: .init(
                full: dateFormats["full"]!,
                long: dateFormats["long"]!,
                medium: dateFormats["medium"]!,
                short: dateFormats["short"]!
            ),
            time: .init(
                full: timeFormats["full"]!,
                long: timeFormats["long"]!,
                medium: timeFormats["medium"]!,
                short: timeFormats["short"]!
            ),
            timestamp: timeInterval,
            formats: custom
        )
    }

    func getContextObject(
        slug: String?,
        for content: Content,
        context: RenderPipeline.Scope.Context,
        using source: SourceBundle,
        allowSubQueries: Bool = true  // allow top level queries only
    ) -> [String: AnyCodable] {

        var result: [String: AnyCodable] = [:]
        if context.contains(.properties) {

            let formatter = DateFormatter()
            formatter.locale = .init(identifier: "en_US")
            formatter.timeZone = .init(secondsFromGMT: 0)
            // TODO: validate locale
            if let rawLocale = source.settings.locale {
                formatter.locale = .init(identifier: rawLocale)
            }
            if let rawTimezone = source.settings.timeZone,
                let timeZone = TimeZone(identifier: rawTimezone)
            {
                formatter.timeZone = timeZone
            }

            for (k, v) in content.properties {
                if let p = content.definition.properties[k],
                    case .date(_) = p.type,
                    let rawDate = v.value(as: Double.self)
                {
                    result[k] = .init(
                        getDates(
                            for: rawDate,
                            using: formatter,
                            formats: source.config.dateFormats.output
                                .recursivelyMerged(with: [
                                    "test": "Y"
                                ])
                        )
                    )
                }
                else {
                    result[k] = .init(v.value)
                }
            }

            result["slug"] = .init(content.slug)
            result["permalink"] = .init(
                content.slug.permalink(baseUrl: source.settings.baseUrl)
            )
            result["isCurrentURL"] = .init(content.slug == slug)
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
                            slug: content.slug,
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

                result[key] = .init(
                    queryContents.map {
                        getContextObject(
                            slug: content.slug,
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

    func renderContents(
        pipelineContext: [String: AnyCodable],
        pipeline: RenderPipeline,
        url: URL
    ) throws {

        if FileManager.default.exists(at: url) {
            try FileManager.default.removeItem(at: url)
        }
        try FileManager.default.createDirectory(at: url)

        let encoder = JSONEncoder()
        encoder.outputFormatting = [
            .prettyPrinted,
            .withoutEscapingSlashes,
            //.sortedKeys,
        ]

        let engineOptions = pipeline.engine.options
        print(engineOptions)
        //        let ct = opt["contentTypes"]?.value as? [String: Any] ?? [:]

        for contentBundle in contentBundles {
            // content pipeline settings
            //            let cps = ct.dict(contentBundle.definition.type)
            //            print(contentBundle.definition.type)
            //            print(cps)

            //            if pipeline.contentType.contains(.bundle) {
            //                        print("render content bundle...")
            //                        print(contentBundle.definition.type)
            //                        print("--------------------------------------")
            //            }

            //            if pipeline.contentType.contains(.single) {

            for content in contentBundle.contents {
                let context: [String: AnyCodable] = [
                    //                        "global": pipelineContext,
                    "local": .init(
                        getContextObject(
                            slug: content.slug,
                            for: content,
                            context: .all,
                            using: self
                        )
                    )
                ]

                let folder =
                    url
                    .appending(path: content.slug)

                try FileManager.default.createDirectory(at: folder)

                let file =
                    folder
                    .appending(path: "context")
                    .appendingPathExtension("json")

                let data = try encoder.encode(context)
                try data.write(to: file)
                //prettyPrint(context)
            }
            //            }
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

            rawContext[key] = .init(
                results.map {
                    getContextObject(
                        slug: nil,
                        for: $0,
                        context: scope.context,
                        using: self
                    )
                }
            )
        }
        return rawContext
    }

    func render(  // TODO: url input
        ) throws
    {

        let url = FileManager.default.homeDirectoryForCurrentUser.appending(
            path: "output"
        )

        for pipeline in renderPipelines {
            let context = getPipelineContext(for: pipeline)

            switch pipeline.engine.id {
            case "context":
                try renderContents(
                    pipelineContext: context,
                    pipeline: pipeline,
                    url: url
                )
            case "json":
                print("mustache")
            case "mustache":
                print("mustache")
            default:
                print("ERROR - no such renderer \(pipeline.engine.id)")
            }
        }
    }

}
