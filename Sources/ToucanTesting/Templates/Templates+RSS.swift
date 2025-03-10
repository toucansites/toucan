public extension Templates.Mocks {

    static func rss() -> String {
        """
        <rss xmlns:atom="http://www.w3.org/2005/Atom" version="2.0">
        <channel>
            <title>{{site.title}}</title>
            <description>{{site.description}}</description>
            <link>{{site.baseUrl}}</link>
            <language>{{site.language}}</language>
            <lastBuildDate>{{site.lastBuildDate.formats.rss}}</lastBuildDate>
            <pubDate>{{site.lastUpdate.formats.rss}}</pubDate>
            <ttl>250</ttl>
            <atom:link href="{{site.baseUrl}}/rss.xml" rel="self" type="application/rss+xml"/>

            {{#page.posts}}
            <item>
                <guid isPermaLink="true">{{permalink}}</guid>
                <title><![CDATA[ {{title}} ]]></title>
                <description><![CDATA[ {{description}} ]]></description>
                <link>{{permalink}}</link>
                <pubDate>{{publication.formats.rss}}</pubDate>
            </item>
            {{/page.posts}}
            {{#page.tags}}
            <item>
                <guid isPermaLink="true">{{permalink}}</guid>
                <title><![CDATA[ {{title}} ]]></title>
                <description><![CDATA[ {{description}} ]]></description>
                <link>{{permalink}}</link>
                <pubDate>{{publication.formats.rss}}</pubDate>
            </item>
            {{/page.tags}}
            {{#page.authors}}
            <item>
                <guid isPermaLink="true">{{permalink}}</guid>
                <title><![CDATA[ {{name}} ]]></title>
                <description><![CDATA[ {{description}} ]]></description>
                <link>{{permalink}}</link>
                <pubDate>{{publication.formats.rss}}</pubDate>
            </item>
            {{/page.authors}}
        </channel>
        </rss>
        """
    }
}
