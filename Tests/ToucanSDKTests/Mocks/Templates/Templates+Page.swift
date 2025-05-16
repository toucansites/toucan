//
//  Templates+Page.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 04. 03..

public extension Templates.Mocks {

    static func page(_ img: String = "<img src=\"{{page.image}}\">") -> String {
        """
        <html>
        <head>
            <title>{{page.title}} - {{site.title}}</title>
            <meta name="description" content="{{page.description}}">
        </head>
        <body>
        <div class="author-card">
            \(img)
        </div>
        {{& page.contents.html}}
        </body>
        </html>
        """
    }

}
