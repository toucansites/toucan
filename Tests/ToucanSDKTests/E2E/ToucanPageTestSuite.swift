//
//  ToucanPageTestSuite.swift
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
//struct ToucanPageTestSuite: ToucanTestSuite {
//
//    @Test
//    func transformerRunTest() async throws {
//        let logger = Logger(label: "ToucanTestSuite")
//        let fileManager = FileManager.default
//        let rootUrl = FileManager.default.temporaryDirectory
//        let rootName = "FileManagerPlayground_\(UUID().uuidString)"
//
//        try FileManagerPlayground(
//            rootUrl: rootUrl,
//            rootName: rootName,
//            fileManager: fileManager
//        ) {
//            Directory(name: "src") {
//                Directory(name: "contents") {
//                    contentAbout()
//                    Directory(name: "assets") {
//                        contentStyleCss()
//                    }
//                    contentHome()
//                    Directory(name: "page1") {
//                        File(
//                            name: "index.yaml",
//                            string: """
//                                type: page
//                                description: Desc1
//                                label: label1
//                                """
//                        )
//                        File(
//                            name: "index.md",
//                            string: """
//                                ---
//                                title: "First beta release"
//                                ---
//                                Character to replace => :
//                                """
//                        )
//                    }
//                    contentSiteFile()
//                }
//                Directory(name: "pipelines") {
//                    pipelineHtml(rootUrl: rootUrl.path(), rootName: rootName)
//                }
//                Directory(name: "types") {
//                    typePage()
//                }
//                Directory(name: "themes") {
//                    Directory(name: "default") {
//                        Directory(name: "templates") {
//                            Directory(name: "pages") {
//                                themeDefaultMustache()
//                            }
//                            themeHtmlMustache()
//                        }
//                    }
//                }
//                Directory(name: "transformers") {
//                    replaceScriptFile()
//                }
//                configFile()
//            }
//        }
//        .test {
//            let input = $1.appending(path: "src/")
//            let output = $1.appending(path: "docs/")
//            try getToucan(input, output, logger).generate()
//
//            let page1 = output.appending(path: "page1/index.html")
//            let data = try page1.loadContents()
//            #expect(data.contains("Character to replace => -"))
//        }
//    }
//
//
//
//    @Test
//    func postAndRssTest() async throws {
//        let logger = Logger(label: "ToucanTestSuite")
//        try FileManagerPlayground {
//            Directory(name: "src") {
//                Directory(name: "contents") {
//                    Directory(name: "posts") {
//                        contentPost(index: 1)
//                        contentPost(index: 2)
//                        contentPost(index: 3)
//                    }
//                    contentAbout()
//                    contentHome()
//                    contentRss()
//                    contentSiteFile()
//                }
//                Directory(name: "pipelines") {
//                    pipelineHtml()
//                    pipelineRss()
//                }
//                Directory(name: "types") {
//                    typePage()
//                    typePost()
//                    typeRss()
//                }
//                Directory(name: "themes") {
//                    Directory(name: "default") {
//                        Directory(name: "templates") {
//                            Directory(name: "pages") {
//                                themeHomeMustache()
//                                themeDefaultMustache()
//                                themeHeaderMustache()
//                                themeFooterMustache()
//                            }
//                            themeRssMustache()
//                            themeHtmlMustache()
//                        }
//                    }
//                }
//                configFile()
//            }
//        }
//        .test {
//            let input = $1.appending(path: "src/")
//            let output = $1.appending(path: "docs/")
//            try getToucan(input, output, logger).generate()
//
//            let rssPath = output.appending(path: "rss.xml")
//            #expect($0.fileExists(at: rssPath))
//        }
//    }
//

//
//}
