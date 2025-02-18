public extension Templates.Mocks {

    static func rss() -> String {
        """
        <rss xmlns:atom="http://www.w3.org/2005/Atom" version="2.0">
        <channel>
            <title>{{title}}</title>
            <description>{{description}}</description>
            <link>{{baseUrl}}</link>
            <language>{{language}}</language>
            <lastBuildDate>{{lastBuildDate}}</lastBuildDate>
            <pubDate>{{lastUpdate}}</pubDate>
            <ttl>250</ttl>
            <atom:link href="{{baseUrl}}rss.xml" rel="self" type="application/rss+xml"/>

        {{#items}}
        <item>
            <guid isPermaLink="true">{{permalink}}</guid>
            <title><![CDATA[ {{title}} ]]></title>
            <description><![CDATA[ {{description}} ]]></description>
            <link>{{permalink}}</link>
            <pubDate>{{publicationDate}}</pubDate>
        </item>
        {{/items}}

        {{#posts}}
        <item>
            <guid isPermaLink="true">{{permalink}}</guid>
            <title><![CDATA[ {{title}} ]]></title>
            <description><![CDATA[ {{description}} ]]></description>
            <link>{{permalink}}</link>
            <pubDate>{{publication.formats.rss}}</pubDate>
        </item>
        {{/posts}}

        {{#tags}}
        <item>
            <guid isPermaLink="true">{{permalink}}</guid>
            <title><![CDATA[ {{title}} ]]></title>
            <description><![CDATA[ {{description}} ]]></description>
            <link>{{permalink}}</link>
            <pubDate>{{publication.formats.rss}}</pubDate>
        </item>
        {{/tags}}

        {{#authors}}
        <item>
            <guid isPermaLink="true">{{permalink}}</guid>
            <title><![CDATA[ {{name}} ]]></title>
            <description><![CDATA[ {{description}} ]]></description>
            <link>{{permalink}}</link>
            <pubDate>{{publication.formats.rss}}</pubDate>
        </item>
        {{/authors}}

        </channel>
        </rss>
        """
    }
}
