//
//  ToucanTestSuite+Pipelines.swift
//  Toucan
//
//  Created by gerp83 on 2025. 04. 15..
//

import Testing
import Logging
import Foundation
import FileManagerKitBuilder

@testable import ToucanSDK

extension ToucanTestSuite {

    func pipelineHtml(
        needPost: Bool = false,
        rootUrl: String? = nil,
        rootName: String? = nil
    ) -> File {
        File(
            name: "html.yml",
            string: """
                id: html
                contentTypes: 
                    include:
                        - page
                        \(needPost ? "-post" : "")
                engine: 
                    id: mustache
                    options:
                        contentTypes: 
                            page:
                                template: "pages.default"
                            \(needPost ? """
                            post:
                                    template: "pages.default"
                            """ : "")
                \(rootUrl != nil && rootName != nil ? """
                transformers:
                        page:
                            run:
                                - name: replace
                                  path: \(rootUrl ?? "")/\(rootName ?? "")/src/transformers
                            isMarkdownResult: false
                """ : "")
                output:
                    path: "{{slug}}"
                    file: index
                    ext: html
                """
        )
    }

    func pipelineApi(
        definesType: Bool = true,
        engineOptions: String? = nil
    ) -> File {
        File(
            name: "api.yml",
            string: """
                id: api
                definesType: \(definesType ? "true" : "false")

                queries: 
                    posts:
                        contentType: post
                        scope: detail
                        orderBy:
                            - key: publication
                              direction: desc

                contentTypes:
                    include:
                        - api

                engine: 
                    id: json
                    \(engineOptions == nil ? "" : engineOptions!)

                output:
                    path: "api"
                    file: posts
                    ext: json
                """
        )
    }

    func pipelinePaginatedApi(definesType: Bool = true) -> File {
        File(
            name: "api.yml",
            string: """
                id: api
                definesType: \(definesType ? "true" : "false")

                iterators:
                    api.posts.pagination:
                        contentType: post
                        scope: detail
                        limit: 2
                        orderBy:
                            - key: title
                              direction: asc

                contentTypes:
                    include:
                        - api

                engine: 
                    id: json

                output:
                    path: "api"
                    file: "{{iterator.current}}"
                    ext: json
                """
        )
    }

    func pipeline404(addTransformers: Bool = false) -> File {
        File(
            name: "404.yml",
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
            name: "sitemap.yml",
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
            name: "redirect.yml",
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
            name: "rss.yml",
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
