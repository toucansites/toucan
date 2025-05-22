//
//  Mocks+Templates.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 21..
//

import ToucanSource

extension Mocks.Templates {

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

    static func page(_ img: String = "<img src=\"{{page.image}}\">") -> String {
        """
        <html>
        <head>
            <title>{{page.title}} - {{site.title}}</title>
            <meta name="description" content="{{page.description}}">
        </head>
        <body>
        <div class="author-card">
            \(img)
        </div>
        {{& page.contents.html}}
        </body>
        </html>
        """
    }

    static func post() -> String {
        """
        <html>
            <head>
            </head>
            <body>
                {{page.title}}<br>
                Date<br>
                {{page.publication.date.full}}<br>
                Time<br>
                {{page.publication.time.short}}<br>
            </body>
        </html>
        """
    }

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

    static func rss() -> String {
        """
        <rss xmlns:atom="http://www.w3.org/2005/Atom" version="2.0">
        <channel>
            <title>{{site.title}}</title>
            <description>{{site.description}}</description>
            <link>{{site.baseUrl}}</link>
            <language>{{site.locale}}</language>
            <lastBuildDate>{{site.generation.formats.rss}}</lastBuildDate>
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
