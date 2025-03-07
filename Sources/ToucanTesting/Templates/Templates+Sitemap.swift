public extension Templates.Mocks {

    static func sitemap() -> String {
        """
        <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
            {{#empty(urls)}}
            {{/empty(urls)}}
            {{^empty(urls)}}
            <url>
                {{#page.tags}}
                <loc>{{permalink}}</loc>
                <lastmod>{{lastUpdate.formats.sitemap}}</lastmod>
                {{/page.tags}}

                {{#page.authors}}
                <loc>{{permalink}}</loc>
                <lastmod>{{lastUpdate.formats.sitemap}}</lastmod>
                {{/page.authors}}

                {{#page.posts}}
                <loc>{{permalink}}</loc>
                <lastmod>{{lastUpdate.formats.sitemap}}</lastmod>
                {{/page.posts}}
            </url>
            {{/empty(urls)}}
        </urlset>
        """
    }
}
