public extension Templates.Mocks {

    static func sitemap() -> String {
        """
        <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
            {{#empty(urls)}}
            {{/empty(urls)}}
            {{^empty(urls)}}
            <url>
                {{#sitemap.tags}}
                <loc>{{permalink}}</loc>
                <lastmod>{{lastUpdate.formats.sitemap}}</lastmod>
                {{/sitemap.tags}}

                {{#sitemap.authors}}
                <loc>{{permalink}}</loc>
                <lastmod>{{lastUpdate.formats.sitemap}}</lastmod>
                {{/sitemap.authors}}

                {{#sitemap.posts}}
                <loc>{{permalink}}</loc>
                <lastmod>{{lastUpdate.formats.sitemap}}</lastmod>
                {{/sitemap.posts}}
            </url>
            {{/empty(urls)}}
        </urlset>
        """
    }
}
