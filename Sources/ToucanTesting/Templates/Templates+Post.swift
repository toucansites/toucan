//
//  Templates+Post.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 03. 26..

public extension Templates.Mocks {

    static func post() -> String {
        """
        <html>
            <head>
            </head>
            <body>
                {{page.title}}<br>
                Date<br>
                {{page.publication.date.full}}<br>
                Time<br>
                {{page.publication.time.short}}<br>
            </body>
        </html>
        """
    }
}
