//
//  Templates+Default.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 03. 26..

public extension Templates.Mocks {

    static func `default`() -> String {
        """
        <html>
        <head>
        </head>
        <body>
        {{page.title}}
        </body>
        </html>
        """
    }
}
