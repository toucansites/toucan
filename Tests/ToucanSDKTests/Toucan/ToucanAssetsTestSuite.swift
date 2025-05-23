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
    func testMinifyCSSAsset() async throws {
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
                            File(
                                "style.css",
                                string: """
                                    html {
                                        margin: 0;
                                        padding: 0;
                                    }
                                    body {
                                        background: red;
                                    }
                                    """
                            )
                        }
                    }
                }
                Directory("pipelines") {
                    File(
                        "html.yml",
                        string: """
                            id: html
                            assets:
                                behaviors:
                                    - id: minify-css
                                      input:
                                        name: "style" 
                                        ext: "css"
                                      output:
                                        name: "style.min"
                                        ext: "css"

                            contentTypes: 
                                include:
                                    - page
                            engine: 
                                id: mustache
                                options:
                                    contentTypes: 
                                        page:
                                            template: "pages.default"
                            output:
                                path: "{{slug}}"
                                file: index
                                ext: html
                            """
                    )
                }
                Directory("types") {
                    typePage()
                }
                Directory("themes") {
                    Directory("default") {
                        Directory("templates") {
                            Directory("pages") {
                                themeDefaultMustache(svg: "{{page.svg}}")
                            }
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

            let cssPath = output.appending(path: "assets/page1/style.min.css")
            #expect($0.fileExists(at: cssPath))

            let contents = try cssPath.loadContents()
            #expect(
                contents.contains(
                    "html{margin:0;padding:0}body{background:red}"
                )
            )
        }
    }

    @Test
    func testSASSAsset() async throws {
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
                            File(
                                "style.sass",
                                string: """
                                    $font-stack: Helvetica, sans-serif
                                    $primary-color: #333

                                    body
                                      font: 100% $font-stack
                                      color: $primary-color
                                    """
                            )
                        }
                    }
                }
                Directory("pipelines") {
                    File(
                        "html.yml",
                        string: """
                            id: html
                            assets:
                                behaviors:
                                    - id: compile-sass
                                      input:
                                        name: "style" 
                                        ext: "sass"
                                      output:
                                        name: "style.min"
                                        ext: "css"

                            contentTypes: 
                                include:
                                    - page
                            engine: 
                                id: mustache
                                options:
                                    contentTypes: 
                                        page:
                                            template: "pages.default"
                            output:
                                path: "{{slug}}"
                                file: index
                                ext: html
                            """
                    )
                }
                Directory("types") {
                    typePage()
                }
                Directory("themes") {
                    Directory("default") {
                        Directory("templates") {
                            Directory("pages") {
                                themeDefaultMustache(svg: "{{page.svg}}")
                            }
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

            let assetsPath = output.appending(path: "assets/page1/")

            #expect($0.listDirectory(at: assetsPath).count == 1)

            let cssPath = assetsPath.appending(path: "style.min.css")
            #expect($0.fileExists(at: cssPath))

            let contents = try cssPath.loadContents()
            #expect(
                contents.contains(
                    """
                    body {
                      font: 100% Helvetica, sans-serif;
                      color: #333;
                    }
                    """
                )
            )
        }
    }

    @Test
    func testSASSAssetModuleLoader() async throws {
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
                            File(
                                "_colors.scss",
                                string: """
                                    $primary: blue;
                                    """
                            )
                            File(
                                "style.scss",
                                string: """
                                    @use "colors";

                                    body {
                                      color: colors.$primary;
                                    }
                                    """
                            )
                        }
                    }
                }
                Directory("pipelines") {
                    File(
                        "html.yml",
                        string: """
                            id: html
                            assets:
                                behaviors:
                                    - id: compile-sass
                                      input:
                                        name: "style" 
                                        ext: "scss"
                                      output:
                                        name: "style.min"
                                        ext: "css"

                            contentTypes: 
                                include:
                                    - page
                            engine: 
                                id: mustache
                                options:
                                    contentTypes: 
                                        page:
                                            template: "pages.default"
                            output:
                                path: "{{slug}}"
                                file: index
                                ext: html
                            """
                    )
                }
                Directory("types") {
                    typePage()
                }
                Directory("themes") {
                    Directory("default") {
                        Directory("templates") {
                            Directory("pages") {
                                themeDefaultMustache(svg: "{{page.svg}}")
                            }
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

            let assetsPath = output.appending(path: "assets/page1/")

            #expect($0.listDirectory(at: assetsPath).count == 1)

            let cssPath = assetsPath.appending(path: "style.min.css")
            #expect($0.fileExists(at: cssPath))

            let contents = try cssPath.loadContents()
            #expect(
                contents.contains(
                    """
                    body {
                      color: blue;
                    }
                    """
                )
            )
        }
    }

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
                              behaviors:
                                - id: copy
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
                Directory("types") {
                    typePage()
                }
                Directory("themes") {
                    Directory("default") {
                        Directory("templates") {
                            Directory("pages") {
                                themeDefaultMustache(svg: "{{page.svg}}")
                            }
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
                              behaviors:
                                - id: copy
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
                Directory("types") {
                    typePage()
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
                              behaviors:
                                - id: copy
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
                Directory("types") {
                    typePage()
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
                              behaviors:
                                - id: copy
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
                Directory("types") {
                    typePage()
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
