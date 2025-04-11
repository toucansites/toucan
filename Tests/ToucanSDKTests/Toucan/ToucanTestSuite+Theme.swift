//
//  ToucanTestSuite+Theme.swift
//  Toucan
//
//  Created by gerp83 on 2025. 04. 09.
//

import Testing
import Logging
import Foundation
import FileManagerKitTesting
import ToucanTesting
@testable import ToucanSDK

extension ToucanTestSuite {

    func themeCss() -> File {
        File(
            "theme.css",
            string: """
                header, footer, .page {
                    max-width: 800px;
                    margin: 0 auto;
                }
                header {
                    text-align: center;
                    border-bottom: 1px dotted black;
                    padding-bottom: 16px;
                }
                footer {
                    text-align: center;
                    border-top: 1px dotted black;
                    padding-top: 16px;
                }
                .page {
                    padding-top: 16px;
                    padding-bottom: 16px;
                }
                header #logo img {
                    width: 64px;
                }
                """
        )
    }

    func theme404Mustache() -> File {
        File(
            "404.mustache",
            string: """
                {{<html}}
                {{$main}}

                <div id="not-found" class="page">
                    {{& page.contents.html}}
                </div>

                {{/main}}
                {{/html}}
                """
        )
    }

    func themeDefaultMustache() -> File {
        File(
            "default.mustache",
            string: """
                {{<html}}
                {{$main}}

                <div class="page">
                    {{& page.contents.html}}
                </div>

                {{/main}}
                {{/html}}
                """
        )
    }

    func themeHomeMustache() -> File {
        File(
            "home.mustache",
            string: """
                {{<html}}
                {{$main}}

                <div class="page">
                    <div id="home">
                        {{& page.contents.html}}
                    </div>
                </div>

                {{/main}}
                {{/html}}
                """
        )
    }

    func themeFooterMustache() -> File {
        File(
            "footer.mustache",
            string: """
                <footer>
                    <p>This site was generated using <a href="https://www.swift.org/" target="_blank">Swift</a> & <a href="https://github.com/toucansites/toucan" target="_blank">Toucan</a>.</p>

                    <p class="small">{{site.title}} &copy; {{site.generation.formats.year}}.</p>
                </footer>
                """
        )
    }

    func themeHeaderMustache() -> File {
        File(
            "header.mustache",
            string: """
                <header>
                    <a id="logo" href="/">
                        <img
                            src="{{site.baseUrl}}/images/logo.png"
                            alt="Logo of {{site.title}}"
                            title="{{site.title}}"
                        >
                    </a>

                    <nav>
                        <div class="navigation">
                            {{#site.navigation}}
                            <a href="{{url}}"{{#class}} class="{{.}}"{{/class}}>{{label}}</a>
                            {{/site.navigation}}
                        </div>
                    </nav>
                </header>
                """
        )
    }

    func themeHtmlMustache() -> File {
        File(
            "html.mustache",
            string: """
                <!DOCTYPE html>
                <html {{#site.locale}}lang="{{.}}"{{/site.locale}}>
                <head>
                    <meta charset="utf-8">
                    {{#page.noindex}}<meta name="robots" content="noindex">{{/page.noindex}}
                    <meta name="viewport" content="width=device-width, initial-scale=1">
                    <meta name="description" content="{{page.description}}">
                    
                    <meta property="og:url" content="{{page.permalink}}">
                    <meta property="og:title" content="{{page.title}}">
                    <meta property="og:description" content="{{page.description}}">
                    {{#page.image}}<meta property="og:image" content="{{.}}" />{{/page.image}}

                    <meta name="twitter:card" content="summary_large_image">
                    <meta name="twitter:title" content="{{page.title}}">
                    <meta name="twitter:description" content="{{page.description}}">
                    {{#page.image}}<meta name="twitter:image" content="{{.}}">{{/page.image}}
                    
                    <meta name="mobile-web-app-capable" content="yes">
                    <meta name="apple-touch-fullscreen" content="yes">

                    <meta name="apple-mobile-web-app-capable" content="yes">
                    <meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
                    <meta name="apple-mobile-web-app-title" content="{{site.name}}">
                    <meta name="apple-mobile-web-app-orientations" content="portrait-any">
                    
                    <meta name="color-scheme" content="light dark">
                    <meta name="theme-color" content="#fff" media="(prefers-color-scheme: light)">
                    <meta name="theme-color" content="#000" media="(prefers-color-scheme: dark)">

                    <title>{{page.title}}</title>

                    <link rel="canonical" href="{{page.permalink}}">
                    {{#page.hreflang}}
                    <link rel="alternate" hreflang="{{lang}}" href="{{url}}">
                    {{/page.hreflang}}
                    {{#page.prev}}<link rel="prev" href="{{permalink}}">{{/page.prev}}
                    {{#page.next}}<link rel="next" href="{{permalink}}">{{/page.next}}

                    <link rel="manifest" href="/manifest.json" />

                    <link rel="stylesheet" href="{{site.baseUrl}}/css/modern-normalize.css">
                    <link rel="stylesheet" href="{{site.baseUrl}}/css/modern-base.css">
                    <link rel="stylesheet" href="{{site.baseUrl}}/css/variables.css">
                    <link rel="stylesheet" href="{{site.baseUrl}}/css/base.css">
                    <link rel="stylesheet" href="{{site.baseUrl}}/css/grid.css">
                    <link rel="stylesheet" href="{{site.baseUrl}}/css/navigation.css">
                    <link rel="stylesheet" href="{{site.baseUrl}}/css/footer.css">
                    <link rel="stylesheet" href="{{site.baseUrl}}/css/theme.css">
                    
                    {{#page.css}}<link rel="stylesheet" href="{{.}}">{{/page.css}}

                    {{> partials.links}}

                    <link
                        rel="stylesheet"
                        href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/github.min.css"
                        media="(prefers-color-scheme: light), (prefers-color-scheme: no-preference)">
                    <link
                        rel="stylesheet"
                        href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/github-dark.min.css"
                        media="(prefers-color-scheme: dark)"
                    >

                    <link rel="stylesheet" href="{{site.baseUrl}}/css/style.css">

                    <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/highlight.min.js"></script>
                    <script>hljs.highlightAll();</script>

                </head>

                <body>
                    {{> partials.navigation}}

                    <main id="page-container">
                    {{$main}}
                        <p>No content.</p>
                    {{/main}}
                    </main>

                    {{> partials.footer}}

                    {{#page.js}}<script src="{{.}}" async></script>{{/page.js}}
                </body>
                </html>
                """
        )
    }

    func themeRedirectMustache() -> File {
        File(
            "redirect.mustache",
            string: """
                <!DOCTYPE html>
                <html {{#site.locale}}lang="{{.}}"{{/site.locale}}>
                  <meta charset="utf-8">
                  <title>Redirecting&hellip;</title>
                  <link rel="canonical" href="{{site.baseUrl}}/{{page.to}}">
                  <script>location="{{site.baseUrl}}/{{page.to}}"</script>
                  <meta http-equiv="refresh" content="0; url={{site.baseUrl}}/{{page.to}}">
                  <meta name="robots" content="noindex">
                  <h1>Redirecting&hellip;</h1>
                  <a href="{{site.baseUrl}}/{{page.to}}">Click here if you are not redirected.</a>
                </html>
                """
        )
    }

    func themeRssMustache() -> File {
        File(
            "rss.mustache",
            string: """
                <rss xmlns:atom="http://www.w3.org/2005/Atom" version="2.0">
                <channel>
                    <title>{{site.name}}</title>
                    <description>{{site.description}}</description>
                    <link>{{site.baseUrl}}</link>
                    <language>{{site.locale}}</language>
                    <lastBuildDate>{{site.generation.formats.rss}}</lastBuildDate>
                    <pubDate>{{site.lastUpdate.formats.rss}}</pubDate>
                    <ttl>250</ttl>
                    <atom:link href="{{site.baseUrl}}/rss.xml" rel="self" type="application/rss+xml"/>

                {{#context.posts}}
                <item>
                    <guid isPermaLink="true">{{permalink}}</guid>
                    <title><![CDATA[ {{title}} ]]></title>
                    <description><![CDATA[ {{description}} ]]></description>
                    <link>{{permalink}}</link>
                    <pubDate>{{publication.formats.rss}}</pubDate>
                </item>
                {{/context.posts}}

                </channel>
                </rss>
                """
        )
    }

    func themeSitemapMustache() -> File {
        File(
            "sitemap.mustache",
            string: """
                <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
                    {{#empty(urls)}}
                    {{/empty(urls)}}
                    {{^empty(urls)}}

                    <url>
                        {{#page.pages}}
                            <loc>{{permalink}}</loc>
                            <lastmod>{{lastUpdate.formats.sitemap}}</lastmod>
                        {{/page.pages}}
                    </url>

                    {{/empty(urls)}}
                </urlset>
                """
        )
    }

}
