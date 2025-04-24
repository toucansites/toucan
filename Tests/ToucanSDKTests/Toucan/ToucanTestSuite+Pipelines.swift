//
//  ToucanTestSuite+Pipelines.swift
//  Toucan
//
//  Created by gerp83 on 2025. 04. 15..
//

import Testing
import Logging
import Foundation
import FileManagerKitTesting
import ToucanTesting
@testable import ToucanSDK

extension ToucanTestSuite {

    func pipelineHtml(
        needPost: Bool = false,
        rootUrl: String? = nil,
        rootName: String? = nil
    ) -> File {
        File(
            "html.yml",
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

}
