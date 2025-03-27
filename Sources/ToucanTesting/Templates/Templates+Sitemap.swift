public extension Templates.Mocks {

    static func sitemap() -> String {
        """
        <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
            {{#empty(urls)}}
            {{/empty(urls)}}
            {{^empty(urls)}}
            <url>
                {{#context.pages}}
                <loc>{{permalink}}</loc>
                <lastmod>{{lastUpdate.formats.sitemap}}</lastmod>
                {{/context.pages}}

                {{#context.tags}}
                <loc>{{permalink}}</loc>
                <lastmod>{{lastUpdate.formats.sitemap}}</lastmod>
                {{/context.tags}}

                {{#context.authors}}
                <loc>{{permalink}}</loc>
                <lastmod>{{lastUpdate.formats.sitemap}}</lastmod>
                {{/context.authors}}

                {{#context.posts}}
                <loc>{{permalink}}</loc>
                <lastmod>{{lastUpdate.formats.sitemap}}</lastmod>
                {{/context.posts}}
            </url>
            {{/empty(urls)}}
        </urlset>
        """
    }
}
