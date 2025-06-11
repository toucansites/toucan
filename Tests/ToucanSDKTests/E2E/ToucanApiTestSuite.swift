//
//  ToucanApiTestSuite.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 04. 15..

//import Testing
//import Logging
//import Foundation
//import FileManagerKitBuilder
//
//@testable import ToucanSDK
//
//@Suite
//struct ToucanApiTestSuite: ToucanTestSuite {
//
//    @Test(arguments: [true, false])
//    func paginated(definesApiTypeManually: Bool) throws {
//        let logger = Logger(label: "ToucanApiTestSuite")
//
//        try FileManagerPlayground {
//            Directory(name: "src") {
//                File(
//                    name: "site.yml",
//                    string: """
//                        name: Test
//                        """
//                )
//                Directory(name: "contents") {
//                    Directory(name: "{{api.posts.pagination}}") {
//                        File(
//                            name: "index.md",
//                            string: """
//                                ---
//                                type: api
//                                slug: "api/{{api.posts.pagination}}"
//                                title: "All posts, page {{number}} of {{total}}"
//                                description: "All authors description. Page {{number}} of {{total}}."
//                                template: blog.posts
//                                ---
//
//                                # Authors
//
//                                All the posts.
//                                """
//                        )
//                    }
//                    Directory(name: "posts") {
//                        contentPost(index: 1)
//                        contentPost(index: 2)
//                        contentPost(index: 3)
//                    }
//
//                }
//                Directory(name: "types") {
//                    typePost()
//                    if definesApiTypeManually {
//                        File(name: "api.yml", string: "id: api")
//                    }
//                }
//                Directory(name: "pipelines") {
//                    pipelinePaginatedApi(definesType: !definesApiTypeManually)
//                }
//                configFile()
//            }
//        }
//        .test {
//            let input = $1.appending(path: "src/")
//            let output = $1.appending(path: "docs/")
//            try getToucan(input, output, logger).generate()
//
//            struct Expected: Decodable {
//                struct Item: Decodable {
//                    let title: String
//                    let slug: Slug
//                }
//                struct Iterator: Decodable {
//                    let current: Int
//                    let items: [Item]
//                }
//                let iterator: Iterator
//            }
//
//            let decoder = JSONDecoder()
//
//            let page1Url = output.appending(path: "api/1.json")
//            let page1Data = try Data(contentsOf: page1Url)
//            let page1Result = try decoder.decode(Expected.self, from: page1Data)
//
//            #expect(page1Result.iterator.current == 1)
//            #expect(page1Result.iterator.items.count == 2)
//
//            let page2Url = output.appending(path: "api/2.json")
//            let page2Data = try Data(contentsOf: page2Url)
//            let page2Result = try decoder.decode(Expected.self, from: page2Data)
//
//            #expect(page2Result.iterator.current == 2)
//            #expect(page2Result.iterator.items.count == 1)
//        }
//    }

//}
