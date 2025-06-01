//
//  ToucanTestSuite+Types.swift
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

    func type404() -> File {
        File(
            name: "not-found.yml",
            string: """
                id: not-found
                paths:
                    - 404
                properties:
                    title:
                        type: string
                        required: true
                        default: null
                """
        )
    }

    func typePage() -> File {
        File(
            name: "page.yml",
            string: """
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

    func typePost() -> File {
        File(
            name: "post.yml",
            string: """
                id: post
                paths:
                    - posts
                properties:
                    featured:
                        type: bool
                        required: false
                        default: false
                    publication:
                        type: date
                        required: true
                queries:
                    prev:
                        contentType: post
                        limit: 1
                        filter:
                            key: publication
                            operator: lessThan
                            value: "{{publication}}"
                        orderBy: 
                            - key: publication
                              direction: desc

                    next:
                        contentType: post
                        limit: 1
                        filter:
                            key: publication
                            operator: greaterThan
                            value: "{{publication}}"
                        orderBy: 
                            - key: publication
                              direction: asc
                """
        )
    }

    func typeRedirect() -> File {
        File(
            name: "redirect.yml",
            string: """
                id: redirect
                properties:
                    to: 
                        type: string
                        required: true
                    code:
                        type: int
                        required: false
                        default: 301
                """
        )
    }

    func typeRss() -> File {
        File(
            name: "rss.yml",
            string: """
                id: rss
                """
        )
    }

    func typeSitemap() -> File {
        File(
            name: "sitemap.yml",
            string: """
                id: sitemap
                """
        )
    }

}
