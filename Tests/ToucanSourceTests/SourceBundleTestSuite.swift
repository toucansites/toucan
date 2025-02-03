import Foundation
import Testing
import ToucanModels
@testable import ToucanSource

@Suite
struct SourceBundleTestSuite {

    // MARK: -

    @Test
    func decodingThemeConfig() throws {

        let sourceBundle = SourceBundle.Mocks.complete()

        try sourceBundle.renderTest()

        //        #expect(jsonString == #"{"type":"bool"}"#)
    }
}

//                engine: "mustache",  // mustache|json|swift|...
//                options: [  //mustache-renderer-config

//
//                ],
//                output: "{{slug}}/index.html"

extension SourceBundle {

    func prettyPrint(_ dictionary: [String: Any]) {
        if let data = try? JSONSerialization.data(
            withJSONObject: dictionary,
            options: [
                .prettyPrinted,
                .withoutEscapingSlashes,
            ]
        ),
            let jsonString = String(data: data, encoding: .utf8)
        {
            print(jsonString)
        }
    }

    func getContext(
        for content: Content,
        context: RenderPipeline.Scope.Context,
        using source: SourceBundle,
        allowSubQueries: Bool = true  // allow top level queries only
    ) -> [String: Any] {
        var result: [String: Any] = [:]
        if context.contains(.properties) {
            for (k, v) in content.properties {
                result[k] = v.value
            }
            result["slug"] = content.slug
            result["permalink"] = "TODO_DOMAIN/" + content.slug
            result["isCurrentURL"] = false
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
                            value: content.relations[key]?.identifiers ?? []
                        ),
                        orderBy: orderBy
                    )
                )
                result[key] = relationContents.map {
                    getContext(
                        for: $0,
                        context: .properties,
                        using: self,
                        allowSubQueries: false
                    )
                }
            }

        }
        if context.contains(.contents) {
            result["contents"] = "TODO"
        }
        if allowSubQueries, context.contains(.queries) {
            for (key, query) in content.definition.queries {
                // TODO: replace {{}} variables in query filter values...
                let queryContents = source.run(
                    query: query.resolveFilterParameters(
                        with: content.queryFields.mapValues { $0.value }
                    )
                )

                //                print("-----------")
                //                print(query.filter ?? "n/a")
                //                print("")
                //                print(query.resolveFilterParameters(
                //                    with: content.queryFields.mapValues { $0.value }
                //                ).filter ?? "n/a")
                //                print("-------------------------!!!!!!!!!!!!!!")
                result[key] = queryContents.map {
                    getContext(
                        for: $0,
                        context: .all,
                        using: self,
                        allowSubQueries: false
                    )
                }
            }
        }
        return result
    }

    func renderTestCase(
        pipelineContext: [String: Any],
        pipeline: RenderPipeline
    ) {
        let opt = pipeline.engine.options?.value as? [String: Any] ?? [:]
        let ct = opt.dict("contentTypes")

        for contentBundle in self.contentBundles {
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
                    let context = [
                        //                        "global": pipelineContext,
                        "local": getContext(
                            for: content,
                            context: .all,
                            using: self
                        )
                    ]
                    prettyPrint(context)

                }
            }
        }

    }

    func getPipelineContext(for pipeline: RenderPipeline) -> [String: Any] {
        var rawContext: [String: Any] = [:]
        for (key, query) in pipeline.queries {
            let results = self.run(query: query)

            // TODO: list by default?
            let scope = pipeline.getScope(
                for: query.contentType,
                key: query.scope ?? "list"
            )

            rawContext[key] = results.map {
                getContext(for: $0, context: scope.context, using: self)
            }
        }
        return rawContext
    }

    func renderTest() throws {

        for pipeline in self.renderPipelines {
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
