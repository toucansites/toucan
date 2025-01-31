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
//                    "dataTypes": [
//                        "date": [
//                            "formats": [
//                                "full": "...",
//                                "medium": "...",
//                                    //                        "iso886"
//                                    //                        "rss"
//                                    //                        "sitemap"
//                            ]
//                        ]
//                    ],
//                    "contentTypes": [
//                        "post": [
//                            "template": "post.default.template",
//                            "properties": [
//                                "date": [
//                                    "formats": [
//                                        "custom": "y.md."
//                                    ]
//                                ]
//                            ],
//                            "scopes": [  // views?
//                                //...
//                                "reference": ["id", "title"],
//                                "list": [
//                                    "id", "title", "description", "authors",
//                                ],
//                                "detail": ["*"],
//                            ],
//                        ]
//                    ],
//                ],
//                output: "{{slug}}/index.html"

extension SourceBundle {

    func renderTest() throws {

        for pipeline in self.renderPipelines {

            var rawContext: [String: [Content]] = [:]
            for (key, query) in pipeline.queries {
                rawContext[key] = self.run(query: query)
            }

            // TODO: rawContext to real scoped context

            switch pipeline.engine.id {
            case "test":

                var outputs: [MockOutput] = []

                for contentBundle in self.contentBundles {
                    if pipeline.contentType.contains(.bundle) {
                        //                        print("render content bundle...")
                        //                        print(contentBundle.definition.type)
                        //                        print("--------------------------------------")
                        outputs.append(
                            .init(
                                template: contentBundle.definition.type,
                                context: nil,
                                url: "\(contentBundle.definition.type)s.json"
                            )
                        )
                    }

                    if pipeline.contentType.contains(.single) {

                        for content in contentBundle.contents {
                            //                            print("render single content...")
                            //                            print("\(content)")

                            // {{id}}: content.id
                            var contentQueryContext: [String: Any] = [:]
                            for (key, query) in contentBundle.definition.queries
                            {
                                // apply query filter values recursively...
                                contentQueryContext[key] = "foo"
                            }

                            outputs.append(
                                .init(
                                    template: "",
                                    context: nil,
                                    url: "\(content.rawValue.origin.slug).html"
                                )
                            )
                            //                            mustache.render(template, fullContext)
                        }
                    }
                }

                for i in outputs {
                    print(i)
                }

            default:
                print("ERROR - no such renderer \(pipeline.engine.id)")
            }
        }

    }

}

struct MockOutput {
    var template: String
    var context: Any?
    var url: String
}
