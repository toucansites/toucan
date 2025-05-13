//
//  ToucanApiTestSuite.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 04. 15..

import Testing
import Logging
import Foundation
import FileManagerKitTesting
import ToucanTesting
@testable import ToucanSDK
@testable import ToucanModels

@Suite
struct ToucanApiTestSuite: ToucanTestSuite {

    @Test(arguments: [true, false])
    func basic(definesApiTypeManually: Bool) throws {
        let logger = Logger(label: "ToucanApiTestSuite")

        try FileManagerPlayground {
            Directory("src") {
                File(
                    "site.yml",
                    string: """
                        name: Test
                        """
                )
                Directory("contents") {
                    Directory("api.json") {
                        File(
                            "index.yml",
                            string: """
                                type: api
                                """
                        )
                    }
                    Directory("posts") {
                        contentPost(index: 1)
                        contentPost(index: 2)
                        contentPost(index: 3)
                    }
                }
                Directory("types") {
                    typePost()
                    if definesApiTypeManually {
                        File("api.yml", string: "id: api")
                    }
                }
                Directory("pipelines") {
                    pipelineApi(definesType: !definesApiTypeManually)
                }
                configFile()
            }
        }
        .test {
            let input = $1.appending(path: "src/")
            let output = $1.appending(path: "docs/")
            try getToucan(input, output, logger).generate()

            struct Expected: Decodable {
                struct Item: Decodable {
                    let title: String
                    let slug: Slug
                }
                struct Context: Decodable {
                    let posts: [Item]
                }
                let context: Context
            }

            let decoder = JSONDecoder()

            let resultUrl = output.appending(path: "api/posts.json")
            let data = try Data(contentsOf: resultUrl)
            let result = try decoder.decode(Expected.self, from: data)

            #expect(result.context.posts.count == 3)
        }
    }

    @Test(arguments: [true, false])
    func paginated(definesApiTypeManually: Bool) throws {
        let logger = Logger(label: "ToucanApiTestSuite")

        try FileManagerPlayground {
            Directory("src") {
                File(
                    "site.yml",
                    string: """
                        name: Test
                        """
                )
                Directory("contents") {
                    Directory("{{api.posts.pagination}}") {
                        File(
                            "index.md",
                            string: """
                                ---
                                type: api
                                slug: "api/{{api.posts.pagination}}"
                                title: "All posts, page {{number}} of {{total}}"
                                description: "All authors description. Page {{number}} of {{total}}."
                                template: blog.posts
                                ---

                                # Authors

                                All the posts.
                                """
                        )
                    }
                    Directory("posts") {
                        contentPost(index: 1)
                        contentPost(index: 2)
                        contentPost(index: 3)
                    }

                }
                Directory("types") {
                    typePost()
                    if definesApiTypeManually {
                        File("api.yml", string: "id: api")
                    }
                }
                Directory("pipelines") {
                    pipelinePaginatedApi(definesType: !definesApiTypeManually)
                }
                configFile()
            }
        }
        .test {
            let input = $1.appending(path: "src/")
            let output = $1.appending(path: "docs/")
            try getToucan(input, output, logger).generate()

            struct Expected: Decodable {
                struct Item: Decodable {
                    let title: String
                    let slug: Slug
                }
                struct Iterator: Decodable {
                    let current: Int
                    let items: [Item]
                }
                let iterator: Iterator
            }

            let decoder = JSONDecoder()

            let page1Url = output.appending(path: "api/1.json")
            let page1Data = try Data(contentsOf: page1Url)
            let page1Result = try decoder.decode(Expected.self, from: page1Data)

            #expect(page1Result.iterator.current == 1)
            #expect(page1Result.iterator.items.count == 2)

            let page2Url = output.appending(path: "api/2.json")
            let page2Data = try Data(contentsOf: page2Url)
            let page2Result = try decoder.decode(Expected.self, from: page2Data)

            #expect(page2Result.iterator.current == 2)
            #expect(page2Result.iterator.items.count == 1)
        }
    }

    @Test()
    func engineOptionsKeyPaths() throws {
        let logger = Logger(label: "ToucanApiTestSuite")

        try FileManagerPlayground {
            Directory("src") {
                File(
                    "site.yml",
                    string: """
                        name: Test
                        """
                )
                Directory("contents") {
                    Directory("api.json") {
                        File(
                            "index.yml",
                            string: """
                                type: api
                                """
                        )
                    }
                    Directory("posts") {
                        contentPost(index: 1)
                        contentPost(index: 2)
                        contentPost(index: 3)
                    }

                }
                Directory("types") {
                    typePost()
                }
                Directory("pipelines") {
                    pipelineApi(
                        engineOptions: """
                            options:
                                    keyPaths:
                                        "context.posts": "items"
                                        "site.generator": "info"
                            """
                    )
                }
                configFile()
            }
        }
        .test {
            let input = $1.appending(path: "src/")
            let output = $1.appending(path: "docs/")
            try getToucan(input, output, logger).generate()

            struct Expected: Decodable {
                struct Item: Decodable {
                    let title: String
                    let slug: Slug
                }
                struct Info: Decodable {
                    let name: String
                    let version: String
                }
                let items: [Item]
                let info: Info
            }

            let decoder = JSONDecoder()

            let resultUrl = output.appending(path: "api/posts.json")
            let data = try Data(contentsOf: resultUrl)
            let result = try decoder.decode(Expected.self, from: data)

            #expect(result.items.count == 3)
            #expect(result.info.name == "Toucan")
        }
    }

    @Test()
    func engineOptionsKeypPath() throws {
        let logger = Logger(label: "ToucanApiTestSuite")

        try FileManagerPlayground {
            Directory("src") {
                File(
                    "site.yml",
                    string: """
                        name: Test
                        """
                )
                Directory("contents") {
                    Directory("api.json") {
                        File(
                            "index.yml",
                            string: """
                                type: api
                                """
                        )
                    }
                    Directory("posts") {
                        contentPost(index: 1)
                        contentPost(index: 2)
                        contentPost(index: 3)
                    }

                }
                Directory("types") {
                    typePost()
                }
                Directory("pipelines") {
                    pipelineApi(
                        engineOptions: """
                            options:
                                    keyPath: "context.posts"
                            """
                    )
                }
                configFile()
            }
        }
        .test {
            let input = $1.appending(path: "src/")
            let output = $1.appending(path: "docs/")
            try getToucan(input, output, logger).generate()

            struct Expected: Decodable {
                let title: String
                let slug: Slug
            }

            let decoder = JSONDecoder()

            let resultUrl = output.appending(path: "api/posts.json")
            let data = try Data(contentsOf: resultUrl)
            let result = try decoder.decode([Expected].self, from: data)

            #expect(result.count == 3)
        }
    }
}
