//
//  PipelineTestSuite.swift
//  Toucan
//
//  Created by Binary Birds on ..

//
//  PipelineTestSuite.swift
//
//  Created by gerp83 on 2025. 04. 23.
//

import Testing
import Logging
import Foundation
import FileManagerKitTesting
import ToucanTesting
@testable import ToucanSDK

protocol PipelineTestSuite {}

extension PipelineTestSuite {

    func pipeline404(addTransformers: Bool = false) -> File {
        File(
            "404.yml",
            string: """
                id: not-found
                contentTypes: 
                    include:
                        - not-found
                \(addTransformers ? """
                transformers:
                        post:
                            run: 
                                - name: swiftinit
                                  url: src/transformers
                            isMarkdownResult: false
                        issue:
                            run: 
                                - name: issue
                            isMarkdownResult: false
                """ : "")
                engine: 
                    id: mustache
                    options:
                        contentTypes: 
                            not-found:
                                template: "pages.404"
                output:
                    path: ""
                    file: 404
                    ext: html
                """
        )
    }

    func pipelineSitemap(_ assets: String? = nil) -> File {
        File(
            "sitemap.yml",
            string: """
                id: sitemap
                queries:
                    pages:
                        contentType: page
                        scope: list
                        orderBy:
                            - key: lastUpdate
                              direction: desc
                contentTypes: 
                    include:
                        - sitemap
                \(assets ?? "")
                engine: 
                    id: mustache
                    options:
                        contentTypes: 
                            sitemap:
                                template: "sitemap"
                output:
                    path: ""
                    file: sitemap
                    ext: xml
                """
        )
    }

    func pipelineRedirect() -> File {
        File(
            "redirect.yml",
            string: """
                id: redirect
                contentTypes: 
                    include:
                        - redirect
                engine: 
                    id: mustache
                    options:
                        contentTypes: 
                            redirect:
                                template: "redirect"
                output:
                    path: "{{slug}}"
                    file: index
                    ext: html
                """
        )
    }

    func pipelineRss() -> File {
        File(
            "rss.yml",
            string: """
                id: rss
                queries:
                    posts:
                        contentType: post
                        scope: list
                        orderBy:
                            - key: lastUpdate
                              direction: desc
                contentTypes: 
                    include:
                        - rss
                    lastUpdate:
                        - post
                engine: 
                    id: mustache
                    options:
                        contentTypes: 
                            rss:
                                template: "rss"
                output:
                    path: ""
                    file: rss
                    ext: xml
                """
        )
    }

}
