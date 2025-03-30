public extension Templates.Mocks {

    static func redirect() -> String {
        """
        <!DOCTYPE html>
        <html {{#site.locale}}lang="{{.}}"{{/site.locale}}>
            <meta charset="utf-8">
            <title>Redirecting&hellip;</title>
            <link rel="canonical" href="{{page.to}}">
            <script>location="{{page.to}}"</script>
            <meta http-equiv="refresh" content="0; url={{page.to}}">
            <meta name="robots" content="noindex">
            <h1>Redirecting&hellip;</h1>
            <a href="{{page.to}}">Click here if you are not redirected.</a>
        </html>
        """
    }
}
