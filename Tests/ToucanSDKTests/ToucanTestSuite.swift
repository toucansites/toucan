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
                        File("index.yaml", string: """
                            type: page
                            description: Desc1
                            label: label1
                            """
                        )
                    }
                    /// No description, its required, but it has default value => No warning.
                    Directory("page2") {
                        File("index.yaml", string: """
                            type: page
                            title: Test2
                            label: label2
                            """
                        )
                    }
                    /// No label and its optional => No warning.
                    Directory("page3") {
                        File("index.yaml", string: """
                            type: page
                            title: Test3
                            description: Desc3
                            """
                        )
                    }
                    File("site.yaml", string: """
                        baseUrl: http://localhost:3000/
                        locale: en-US
                        title: Test
                        navigation:
                            - label: "Home"
                              url: "/"
                            - label: "About"
                              url: "/about/"
                        """
                    )
                }
                Directory("pipelines") {
                    File("html.yaml", string: """
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
                                File("default.mustache", string: """
                                    {{<html}}
                                    {{$main}}

                                    {{& page.contents.html}}

                                    {{/main}}
                                    {{/html}}
                                    """
                                )
                            }
                            File("html.mustache", string: """
                                <!DOCTYPE html>
                                <html {{#site.language}}lang="{{.}}"{{/site.language}}>
                                <head>
                                    <meta charset="utf-8">
                                    {{#page.noindex}}<meta name="robots" content="noindex">{{/page.noindex}}
                                    <meta name="viewport" content="width=device-width, initial-scale=1">
                                    <meta name="description" content="{{page.description}}">
                                    
                                    <meta property="og:url" content="{{page.permalink}}">
                                    <meta property="og:title" content="{{page.title}}">
                                    <meta property="og:description" content="{{page.description}}">
                                    {{#page.image}}<meta property="og:image" content="{{.}}" />{{/page.image}}

                                    <meta name="twitter:card" content="summary_large_image">
                                    <meta name="twitter:title" content="{{page.title}}">
                                    <meta name="twitter:description" content="{{page.description}}">
                                    {{#page.image}}<meta name="twitter:image" content="{{.}}">{{/page.image}}
                                    
                                    <meta name="mobile-web-app-capable" content="yes">
                                    <meta name="apple-touch-fullscreen" content="yes">

                                    <meta name="apple-mobile-web-app-capable" content="yes">
                                    <meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
                                    <meta name="apple-mobile-web-app-title" content="{{site.name}}">
                                    <meta name="apple-mobile-web-app-orientations" content="portrait-any">
                                    
                                    <meta name="color-scheme" content="light dark">
                                    <meta name="theme-color" content="#fff" media="(prefers-color-scheme: light)">
                                    <meta name="theme-color" content="#000" media="(prefers-color-scheme: dark)">

                                    <title>{{page.title}}</title>

                                    <link rel="canonical" href="{{page.permalink}}">
                                    {{#page.hreflang}}
                                    <link rel="alternate" hreflang="{{lang}}" href="{{url}}">
                                    {{/page.hreflang}}
                                    {{#page.prev}}<link rel="prev" href="{{permalink}}">{{/page.prev}}
                                    {{#page.next}}<link rel="next" href="{{permalink}}">{{/page.next}}

                                    <link rel="manifest" href="/manifest.json" />

                                    <link rel="stylesheet" href="{{site.baseUrl}}/css/modern-normalize.css">
                                    <link rel="stylesheet" href="{{site.baseUrl}}/css/modern-base.css">
                                    <link rel="stylesheet" href="{{site.baseUrl}}/css/variables.css">
                                    <link rel="stylesheet" href="{{site.baseUrl}}/css/base.css">
                                    <link rel="stylesheet" href="{{site.baseUrl}}/css/grid.css">
                                    <link rel="stylesheet" href="{{site.baseUrl}}/css/navigation.css">
                                    <link rel="stylesheet" href="{{site.baseUrl}}/css/footer.css">
                                    <link rel="stylesheet" href="{{site.baseUrl}}/css/theme.css">
                                    
                                    {{#page.css}}<link rel="stylesheet" href="{{.}}">{{/page.css}}

                                    {{> partials.links}}

                                    <link
                                        rel="stylesheet"
                                        href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/github.min.css"
                                        media="(prefers-color-scheme: light), (prefers-color-scheme: no-preference)">
                                    <link
                                        rel="stylesheet"
                                        href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/github-dark.min.css"
                                        media="(prefers-color-scheme: dark)"
                                    >

                                    <link rel="stylesheet" href="{{site.baseUrl}}/css/style.css">

                                    <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/highlight.min.js"></script>
                                    <script>hljs.highlightAll();</script>

                                </head>

                                <body>
                                    {{> partials.navigation}}

                                    <main id="page-container">
                                    {{$main}}
                                        <p>No content.</p>
                                    {{/main}}
                                    </main>

                                    {{> partials.footer}}

                                    {{#page.js}}<script src="{{.}}" async></script>{{/page.js}}
                                </body>
                                </html>
                                """
                            )
                        }
                        Directory("types") {
                            File("page.yaml", string: """
                                id: page
                                default: true
                                
                                properties:
                                    title:
                                        type: string
                                        required: true
                                    description:
                                        type: string
                                        required: false
                                        default: "---"
                                    label:
                                        type: string
                                        required: false
                                """
                            )
                        }
                    }
                }
                File("config.yaml", string: """
                    dateFormats:
                        input: 
                            format: "yyyy-MM-dd HH:mm:ss"
                        output:
                            year: 
                                format: "y"
                    """
                )
            }
        }
        .test {
            let input = $1.appending(path: "src/")
            let output = $1.appending(path: "docs/")

            let toucan = Toucan(
                input: input.path(),
                output: output.path(),
                baseUrl: "http:localhost:3000",
                logger: logging.logger
            )
            
            try toucan.generate()
            
            let results = logging.handler.messages.filter {
                $0.description.contains("warning") &&
                $0.description.contains("slug=page1") &&
                $0.description.contains("Missing content property: `title`")
            }
            
            #expect(results.count == 1)
        }
    }
}
