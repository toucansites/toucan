public extension Templates.Mocks {

    static func post() -> String {
        """
        <html>
        <head>
        </head>
        <body>
        {{title}}<br>
        Date<br>
        {{publication.date.full}}<br>
        Time<br>
        {{publication.time.short}}<br>
        </body>
        </html>
        """
    }
}
