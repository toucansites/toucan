//
//  ToucanErrorTestSuite.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 04. 15..
//
//import Testing
//import Logging
//import Foundation
//import FileManagerKitBuilder
//
//@testable import ToucanSDK
//
//@Suite
//struct ToucanErrorTestSuite: ToucanTestSuite {
//
//    @Test
//    func propertyValidationLogs() async throws {
//        //        let logging = Logger.inMemory(label: "ToucanTestSuite")
//        try FileManagerPlayground {
//            Directory(name: "src") {
//                Directory(name: "contents") {
//                    /// No title, but its required  => Warning.
//                    Directory(name: "page1") {
//                        File(
//                            "index.yaml",
//                            string: """
//                                type: page
//                                description: Desc1
//                                label: label1
//                                """
//                        )
//                    }
//                    /// No description, its required, but it has default value => No warning.
//                    Directory(name: "page2") {
//                        File(
//                            "index.yaml",
//                            string: """
//                                type: page
//                                title: Test2
//                                label: label2
//                                """
//                        )
//                    }
//                    /// No label and its optional => No warning.
//                    Directory(name: "page3") {
//                        File(
//                            "index.yaml",
//                            string: """
//                                type: page
//                                title: Test3
//                                description: Desc3
//                                """
//                        )
//                    }
//                    contentSiteFile()
//                }
//                Directory(name: "pipelines") {
//                    pipelineHtml()
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
//                configFile()
//            }
//        }
//        .test {
//            let input = $1.appending(path: "src/")
//            let output = $1.appending(path: "docs/")
//            let logger = Logger(label: "test")
//            try getToucan(input, output, logger).generate()
//            #warning("fixme")
//            //            let results = logging.handler.messages.filter {
//            //                $0.description.contains("warning")
//            //                    && $0.description.contains("slug=page1")
//            //                    && $0.description.contains(
//            //                        "Missing content property: `title`"
//            //                    )
//            //            }
//
//            //            #expect(results.count == 1)
//        }
//    }
//
//    @Test
//    func duplicateSlugs() async throws {
//        let logger = Logger(label: "ToucanTestSuite")
//        try FileManagerPlayground {
//            Directory(name: "src") {
//                Directory(name: "contents") {
//                    Directory(name: "page1") {
//                        File(
//                            "index.yaml",
//                            string: """
//                                type: page
//                                title: Test1
//                                slug: duplicate/slug
//                                """
//                        )
//                    }
//                    Directory(name: "page2") {
//                        File(
//                            "index.yaml",
//                            string: """
//                                type: page
//                                title: Test2
//                                slug: duplicate/slug
//                                """
//                        )
//                    }
//                }
//                Directory(name: "pipelines") {
//                    pipelineHtml()
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
//                configFile()
//            }
//        }
//        .test {
//            let input = $1.appending(path: "src/")
//            let output = $1.appending(path: "docs/")
//            do {
//                try getToucan(input, output, logger).generate()
//            }
//            catch Toucan.Error.duplicateSlugs(let slugs) {
//                #expect(slugs == ["duplicate/slug"])
//            }
//        }
//    }
//
//    @Test(arguments: ["index.md", "index.yml"])
//    func invalidFrontMatter(_ file: String) async throws {
//        let logger = Logger(label: "ToucanTestSuite")
//        try FileManagerPlayground {
//            Directory(name: "src") {
//                Directory(name: "contents") {
//                    Directory(name: "page1") {
//                        File(
//                            file,
//                            string: """
//                                type: page
//                                title missingColor
//                                """
//                        )
//                    }
//                }
//                Directory(name: "pipelines") {
//                    pipelineHtml()
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
//                configFile()
//            }
//        }
//        .test {
//            let input = $1.appending(path: "src/")
//            let output = $1.appending(path: "docs/")
//            do {
//                try getToucan(input, output, logger).generate()
//            }
//            catch let error as RawContentLoader.Error {
//                switch error {
//                case .invalidFrontMatter(let path):
//                    #expect(path == "page1/\(file)")
//                }
//            }
//        }
//    }
//
//}
