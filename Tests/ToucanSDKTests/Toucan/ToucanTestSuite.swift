//
//  ToucanTestSuite.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 04. 15..

import Testing
import Logging
import Foundation
import FileManagerKitTesting
import ToucanTesting
@testable import ToucanSDK

@Suite
struct ToucanTestSuite {

    @Test
    func propertyValidationLogs() async throws {
        let logging = Logger.inMemory(label: "ToucanTestSuite")
        try FileManagerPlayground {
            Directory("src") {
                Directory("contents") {
                    /// No title, but its required  => Warning.
                    Directory("page1") {
                        File(
                            "index.yaml",
                            string: """
                                type: page
                                description: Desc1
                                label: label1
                                """
                        )
                    }
                    /// No description, its required, but it has default value => No warning.
                    Directory("page2") {
                        File(
                            "index.yaml",
                            string: """
                                type: page
                                title: Test2
                                label: label2
                                """
                        )
                    }
                    /// No label and its optional => No warning.
                    Directory("page3") {
                        File(
                            "index.yaml",
                            string: """
                                type: page
                                title: Test3
                                description: Desc3
                                """
                        )
                    }
                    contentSiteFile()
                }
                Directory("pipelines") {
                    pipelineHtml()
                }
                Directory("themes") {
                    Directory("default") {
                        Directory("templates") {
                            Directory("pages") {
                                themeDefaultMustache()
                            }
                            themeHtmlMustache()
                        }
                        Directory("types") {
                            typePage()
                        }
                    }
                }
                configFile()
            }
        }
        .test {
            let input = $1.appending(path: "src/")
            let output = $1.appending(path: "docs/")
            try getToucan(input, output, logging.logger).generate()

            let results = logging.handler.messages.filter {
                $0.description.contains("warning")
                    && $0.description.contains("slug=page1")
                    && $0.description.contains(
                        "Missing content property: `title`"
                    )
            }

            #expect(results.count == 1)
        }
    }

    @Test
    func duplicateSlugs() async throws {
        let logger = Logger(label: "ToucanTestSuite")
        try FileManagerPlayground {
            Directory("src") {
                Directory("contents") {
                    Directory("page1") {
                        File(
                            "index.yaml",
                            string: """
                                type: page
                                title: Test1
                                slug: duplicate/slug
                                """
                        )
                    }
                    Directory("page2") {
                        File(
                            "index.yaml",
                            string: """
                                type: page
                                title: Test2
                                slug: duplicate/slug
                                """
                        )
                    }
                }
                Directory("pipelines") {
                    pipelineHtml()
                }
                Directory("themes") {
                    Directory("default") {
                        Directory("templates") {
                            Directory("pages") {
                                themeDefaultMustache()
                            }
                            themeHtmlMustache()
                        }
                        Directory("types") {
                            typePage()
                        }
                    }
                }
                configFile()
            }
        }
        .test {
            let input = $1.appending(path: "src/")
            let output = $1.appending(path: "docs/")
            do {
                try getToucan(input, output, logger).generate()
            }
            catch Toucan.Error.duplicateSlugs(let slugs) {
                #expect(slugs == ["duplicate/slug"])
            }
        }
    }

    @Test(arguments: ["index.md", "index.yml"])
    func invalidFrontMatter(_ file: String) async throws {
        let logger = Logger(label: "ToucanTestSuite")
        try FileManagerPlayground {
            Directory("src") {
                Directory("contents") {
                    Directory("page1") {
                        File(
                            file,
                            string: """
                                type: page
                                title missingColor
                                """
                        )
                    }
                }
                Directory("pipelines") {
                    pipelineHtml()
                }
                Directory("themes") {
                    Directory("default") {
                        Directory("templates") {
                            Directory("pages") {
                                themeDefaultMustache()
                            }
                            themeHtmlMustache()
                        }
                        Directory("types") {
                            typePage()
                        }
                    }
                }
                configFile()
            }
        }
        .test {
            let input = $1.appending(path: "src/")
            let output = $1.appending(path: "docs/")
            do {
                try getToucan(input, output, logger).generate()
            }
            catch let error as RawContentLoader.Error {
                switch error {
                case .invalidFrontMatter(let path):
                    #expect(path == "page1/\(file)")
                }
            }
        }
    }

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
                Directory("themes") {
                    Directory("default") {
                        Directory("templates") {
                            Directory("pages") {
                                themeDefaultMustache()
                            }
                            themeHtmlMustache()
                        }
                        Directory("types") {
                            typePage()
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
                        Directory("types") {
                            type404()
                            typePage()
                            typeSitemap()
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
                        Directory("types") {
                            typePage()
                            typePost()
                            typeRss()
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
                Directory("themes") {
                    Directory("default") {
                        Directory("templates") {
                            Directory("pages") {
                                themeDefaultMustache()
                            }
                            themeRedirectMustache()
                            themeHtmlMustache()
                        }
                        Directory("types") {
                            typePage()
                            typeRedirect()
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

    private func getToucan(
        _ input: URL,
        _ output: URL,
        _ logger: Logger
    ) -> Toucan {
        let toucan = Toucan(
            input: input.path(),
            output: output.path(),
            baseUrl: "http:localhost:3000",
            logger: logger
        )
        return toucan
    }

}
