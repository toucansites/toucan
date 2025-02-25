public extension Templates.Mocks {

    static func redirect() -> String {
        """
        <!DOCTYPE html>
        <html {{#site.language}}lang="{{.}}"{{/site.language}}>
            <meta charset="utf-8">
            <title>Redirecting&hellip;</title>
            <link rel="canonical" href="{{redirect.to}}">
            <script>location="{{redirect.to}}"</script>
            <meta http-equiv="refresh" content="0; url={{redirect.to}}">
            <meta name="robots" content="noindex">
            <h1>Redirecting&hellip;</h1>
            <a href="{{redirect.to}}">Click here if you are not redirected.</a>
        </html>
        """
    }
}
