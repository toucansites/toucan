//
//  ToucanAssetsTestSuite.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 04. 29..

import Testing
import Logging
import Foundation
import FileManagerKitTesting
import ToucanTesting
@testable import ToucanSDK

@Suite
struct ToucanAssetsTestSuite: ToucanTestSuite {

    @Test
    func testLoadSvg() async throws {
        let logger = Logger(label: "ToucanTestSuite")
        try FileManagerPlayground {
            Directory("src") {
                Directory("contents") {
                    Directory("page1") {
                        File(
                            "index.yaml",
                            string: """
                                title: title
                                type: page
                                description: Desc1
                                label: label1
                                """
                        )
                        Directory("assets") {
                            svg1()
                        }
                    }
                }
                Directory("pipelines") {
                    File(
                        "html.yml",
                        string: """
                            id: html
                            contentTypes: 
                                include:
                                    - page
                            engine: 
                                id: mustache
                                options:
                                    contentTypes: 
                                        page:
                                            template: "pages.default"
                            assets:
                              properties:
                                - action: load
                                  property: svg
                                  resolvePath: false
                                  input:
                                    name: "test1"
                                    ext: svg
                                
                            output:
                                path: "{{slug}}"
                                file: index
                                ext: html
                            """
                    )
                }
                Directory("themes") {
                    Directory("default") {
                        Directory("templates") {
                            Directory("pages") {
                                themeDefaultMustache(svg: "{{page.svg}}")
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
            try getToucan(input, output, logger).generate()

            let svgPath = output.appending(path: "assets/page1/test1.svg")
            #expect($0.fileExists(at: svgPath))

            let htmlPath = output.appending(path: "page1/index.html")
            #expect($0.fileExists(at: htmlPath))

            let contents = try htmlPath.loadContents()
            #expect(contents.contains("/svg"))
        }
    }

    @Test
    func testLoadMoreSvg() async throws {
        let logger = Logger(label: "ToucanTestSuite")
        try FileManagerPlayground {
            Directory("src") {
                Directory("contents") {
                    Directory("page1") {
                        File(
                            "index.yaml",
                            string: """
                                title: title
                                type: page
                                description: Desc1
                                label: label1
                                """
                        )
                        Directory("assets") {
                            svg1()
                            svg2()
                        }
                    }
                }
                Directory("pipelines") {
                    File(
                        "html.yml",
                        string: """
                            id: html
                            contentTypes: 
                                include:
                                    - page
                            engine: 
                                id: mustache
                                options:
                                    contentTypes: 
                                        page:
                                            template: "pages.default"
                            assets:
                              properties:
                                - action: load
                                  property: svg
                                  resolvePath: false
                                  input:
                                    name: "*"
                                    ext: svg
                                
                            output:
                                path: "{{slug}}"
                                file: index
                                ext: html
                            """
                    )
                }
                Directory("themes") {
                    Directory("default") {
                        Directory("templates") {
                            Directory("pages") {
                                themeDefaultMustache(
                                    svg: """
                                            {{page.svg.test1}}
                                            {{page.svg.test2}}
                                        """
                                )
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
            try getToucan(input, output, logger).generate()

            let svgPath = output.appending(path: "assets/page1/test1.svg")
            #expect($0.fileExists(at: svgPath))

            let svgPath2 = output.appending(path: "assets/page1/test1.svg")
            #expect($0.fileExists(at: svgPath2))

            let htmlPath = output.appending(path: "page1/index.html")
            #expect($0.fileExists(at: htmlPath))

            let contents = try htmlPath.loadContents()
            #expect(contents.contains("/svg"))
        }
    }

    @Test
    func testParse() async throws {
        let logger = Logger(label: "ToucanTestSuite")
        try FileManagerPlayground {
            Directory("src") {
                Directory("contents") {
                    Directory("page1") {
                        File(
                            "index.yaml",
                            string: """
                                title: title
                                type: page
                                description: Desc1
                                label: label1
                                """
                        )
                        Directory("assets") {
                            yaml1()
                        }
                    }
                }
                Directory("pipelines") {
                    File(
                        "html.yml",
                        string: """
                            id: html
                            contentTypes: 
                                include:
                                    - page
                            engine: 
                                id: mustache
                                options:
                                    contentTypes: 
                                        page:
                                            template: "pages.default"
                            assets:
                              properties:
                                - action: parse
                                  property: yaml
                                  resolvePath: false
                                  input:
                                    name: "test1"
                                    ext: yaml
                                
                            output:
                                path: "{{slug}}"
                                file: index
                                ext: html
                            """
                    )
                }
                Directory("themes") {
                    Directory("default") {
                        Directory("templates") {
                            Directory("pages") {
                                themeDefaultMustache(
                                    yaml:
                                        """
                                        {{page.yaml.key1}}
                                        {{page.yaml.key2}}
                                        """
                                )
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
            try getToucan(input, output, logger).generate()

            let svgPath = output.appending(path: "assets/page1/test1.yaml")
            #expect($0.fileExists(at: svgPath))

            let htmlPath = output.appending(path: "page1/index.html")
            #expect($0.fileExists(at: htmlPath))

            let contents = try htmlPath.loadContents()
            #expect(contents.contains("value1"))
            #expect(contents.contains("value2"))
        }
    }

    @Test
    func testParseMore() async throws {
        let logger = Logger(label: "ToucanTestSuite")
        try FileManagerPlayground {
            Directory("src") {
                Directory("contents") {
                    Directory("page1") {
                        File(
                            "index.yaml",
                            string: """
                                title: title
                                type: page
                                description: Desc1
                                label: label1
                                """
                        )
                        Directory("assets") {
                            yaml1()
                            yaml2()
                        }
                    }
                }
                Directory("pipelines") {
                    File(
                        "html.yml",
                        string: """
                            id: html
                            contentTypes: 
                                include:
                                    - page
                            engine: 
                                id: mustache
                                options:
                                    contentTypes: 
                                        page:
                                            template: "pages.default"
                            assets:
                              properties:
                                - action: parse
                                  property: yaml
                                  resolvePath: false
                                  input:
                                    name: "*"
                                    ext: yaml
                                
                            output:
                                path: "{{slug}}"
                                file: index
                                ext: html
                            """
                    )
                }
                Directory("themes") {
                    Directory("default") {
                        Directory("templates") {
                            Directory("pages") {
                                themeDefaultMustache(
                                    yaml:
                                        """
                                        {{page.yaml.test1.key1}}
                                        {{page.yaml.test1.key2}}
                                        {{page.yaml.test2.key3}}
                                        {{page.yaml.test2.key4}}
                                        """
                                )
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
            try getToucan(input, output, logger).generate()

            let svgPath = output.appending(path: "assets/page1/test1.yaml")
            #expect($0.fileExists(at: svgPath))

            let htmlPath = output.appending(path: "page1/index.html")
            #expect($0.fileExists(at: htmlPath))

            let contents = try htmlPath.loadContents()
            #expect(contents.contains("value1"))
            #expect(contents.contains("value2"))
            #expect(contents.contains("value3"))
            #expect(contents.contains("value4"))
        }
    }

}
