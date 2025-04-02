public extension Templates.Mocks {

    static func pageLink() -> String {
        """
        <html>
        <head>
            <title>{{page.title}} - {{site.title}}</title>
            <meta name="description" content="{{page.description}}">
        </head>
        <body>
        {{& page.contents.html}}
        </body>
        </html>
        """
    }
}
