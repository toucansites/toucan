//
//  ToucanTestSuite+Types.swift
//  Toucan
//
//  Created by gerp83 on 2025. 04. 09.
//

import Testing
import Logging
import Foundation
import FileManagerKitTesting
import ToucanTesting
@testable import ToucanSDK
    
extension ToucanTestSuite {
    
    func type404() -> File {
        File(
            "not-found.yml",
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
            "page.yml",
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
            "post.yml",
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
            "redirect.yml",
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
            "rss.yml",
            string: """
                id: rss
                """
        )
    }
    
    func typeSitemap() -> File {
        File(
            "sitemap.yml",
            string: """
                id: sitemap
                """
        )
    }
    
}
