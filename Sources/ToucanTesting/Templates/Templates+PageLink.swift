public extension Templates.Mocks {

    static func pageLink() -> String {
        """
        <html>
        <head>
            <title>{{page.title}} - {{site.title}}</title>
            <meta name="description" content="{{page.description}}">
        </head>
        <body>
        {{title}}
        </body>
        </html>
        """
    }
}
