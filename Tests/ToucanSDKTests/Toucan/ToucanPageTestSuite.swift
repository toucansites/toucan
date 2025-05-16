//
//  ToucanPageTestSuite.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 04. 15..

import Testing
import Logging
import Foundation
import FileManagerKitTesting

@testable import ToucanSDK

@Suite
struct ToucanPageTestSuite: ToucanTestSuite {

    @Test
    func transformerRunTest() async throws {
        let logger = Logger(label: "ToucanTestSuite")
        let fileManager = FileManager.default
        let rootUrl = FileManager.default.temporaryDirectory
        let rootName = "FileManagerPlayground_\(UUID().uuidString)"

        try FileManagerPlayground(
            rootUrl: rootUrl,
            rootName: rootName,
            fileManager: fileManager
        ) {
            Directory("src") {
                Directory("contents") {
                    contentAbout()
                    Directory("assets") {
                        contentStyleCss()
                    }
                    contentHome()
                    Directory("page1") {
                        File(
                            "index.yaml",
                            string: """
                                type: page
                                description: Desc1
                                label: label1
                                """
                        )
                        File(
                            "index.md",
                            string: """
                                ---
                                title: "First beta release"
                                ---
                                Character to replace => :
                                """
                        )
                    }
                    contentSiteFile()
                }
                Directory("pipelines") {
                    pipelineHtml(rootUrl: rootUrl.path(), rootName: rootName)
                }
                Directory("types") {
                    typePage()
                }
                Directory("themes") {
                    Directory("default") {
                        Directory("templates") {
                            Directory("pages") {
                                themeDefaultMustache()
                            }
                            themeHtmlMustache()
                        }
                    }
                }
                Directory("transformers") {
                    replaceScriptFile()
                }
                configFile()
            }
        }
        .test {
            let input = $1.appending(path: "src/")
            let output = $1.appending(path: "docs/")
            try getToucan(input, output, logger).generate()

            let page1 = output.appending(path: "page1/index.html")
            let data = try page1.loadContents()
            #expect(data.contains("Character to replace => -"))
        }
    }

    @Test
    func sitemapAnd404Test() async throws {
        let logger = Logger(label: "ToucanTestSuite")
        try FileManagerPlayground {
            Directory("src") {
                Directory("contents") {
                    contentAbout()
                    contentHome()
                    content404()
                    contentSitemap()
                    contentSiteFile()
                }
                Directory("pipelines") {
                    pipelineHtml()
                    pipelineSitemap()
                    pipeline404()
                }
                Directory("types") {
                    type404()
                    typePage()
                    typeSitemap()
                }
                Directory("themes") {
                    Directory("default") {
                        Directory("assets") {
                            Directory("css") {
                                themeCss()
                            }
                        }
                        Directory("templates") {
                            Directory("pages") {
                                themeHomeMustache()
                                themeDefaultMustache()
                                theme404Mustache()
                            }
                            themeHtmlMustache()
                            themeSitemapMustache()
                        }
                    }
                }
                configFile()
            }
        }
        .test {
            let input = $1.appending(path: "src/")
            let output = $1.appending(path: "docs/")
            try getToucan(input, output, logger).generate()

            let notfoundPath = output.appending(path: "404.html")
            #expect($0.fileExists(at: notfoundPath))

            let sitemapPath = output.appending(path: "sitemap.xml")
            #expect($0.fileExists(at: sitemapPath))
        }
    }

    @Test
    func postAndRssTest() async throws {
        let logger = Logger(label: "ToucanTestSuite")
        try FileManagerPlayground {
            Directory("src") {
                Directory("contents") {
                    Directory("posts") {
                        contentPost(index: 1)
                        contentPost(index: 2)
                        contentPost(index: 3)
                    }
                    contentAbout()
                    contentHome()
                    contentRss()
                    contentSiteFile()
                }
                Directory("pipelines") {
                    pipelineHtml()
                    pipelineRss()
                }
                Directory("types") {
                    typePage()
                    typePost()
                    typeRss()
                }
                Directory("themes") {
                    Directory("default") {
                        Directory("templates") {
                            Directory("pages") {
                                themeHomeMustache()
                                themeDefaultMustache()
                                themeHeaderMustache()
                                themeFooterMustache()
                            }
                            themeRssMustache()
                            themeHtmlMustache()
                        }
                    }
                }
                configFile()
            }
        }
        .test {
            let input = $1.appending(path: "src/")
            let output = $1.appending(path: "docs/")
            try getToucan(input, output, logger).generate()

            let rssPath = output.appending(path: "rss.xml")
            #expect($0.fileExists(at: rssPath))
        }
    }

    @Test
    func redirectTest() async throws {
        let logger = Logger(label: "ToucanTestSuite")
        try FileManagerPlayground {
            Directory("src") {
                Directory("contents") {
                    contentAbout()
                    contentHome()
                    Directory("redirectAbout") {
                        File(
                            "index.yml",
                            string: """
                                type: redirect
                                to: about
                                """
                        )
                    }
                }
                Directory("pipelines") {
                    pipelineHtml()
                    pipelineRedirect()
                }
                Directory("types") {
                    typePage()
                    typeRedirect()
                }
                Directory("themes") {
                    Directory("default") {
                        Directory("templates") {
                            Directory("pages") {
                                themeDefaultMustache()
                            }
                            themeRedirectMustache()
                            themeHtmlMustache()
                        }
                    }
                }
                configFile()
            }
        }
        .test {
            let input = $1.appending(path: "src/")
            let output = $1.appending(path: "docs/")
            try getToucan(input, output, logger).generate()

            let htmlPath = output.appending(path: "redirectAbout/index.html")
            #expect($0.fileExists(at: htmlPath))
        }
    }

}
