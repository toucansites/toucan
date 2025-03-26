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
