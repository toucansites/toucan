//
//  Mocks+Files.swift
//  Toucan
//
//  Created by gerp83 on 2025. 04. 15..
//

import Foundation
import FileManagerKitBuilder

extension File {
    enum Mocks {}
}

extension File.Mocks {

    // MARK: -

    static func replaceTransformer() -> File {
        .init(
            name: "replace",
            attributes: [.posixPermissions: 0o777],
            string: """
                #!/bin/bash
                # Replaces all colons `:` with dashes `-` in the given file.
                # Usage: replace-char --file <path>
                UNKNOWN_ARGS=()
                while [[ $# -gt 0 ]]; do
                    case $1 in
                        --file)
                            TOUCAN_FILE="$2"
                            shift
                            shift
                            ;;
                        -*|--*)
                            UNKNOWN_ARGS+=("$1" "$2")
                            shift
                            shift
                            ;;
                        *)
                            shift
                            ;;
                    esac
                done
                if [[ -z "${TOUCAN_FILE}" ]]; then
                    echo "❌ No file specified with --file."
                    exit 1
                fi
                echo "📄 Processing file: ${TOUCAN_FILE}"
                if [[ ${#UNKNOWN_ARGS[@]} -gt 0 ]]; then
                    echo "ℹ️ Ignored unknown options: ${UNKNOWN_ARGS[*]}"
                fi
                sed 's/:/-/g' "${TOUCAN_FILE}" > "${TOUCAN_FILE}.tmp" && mv "${TOUCAN_FILE}.tmp" "${TOUCAN_FILE}"
                echo "✅ Done replacing characters."
                """
        )
    }

    // MARK: -

    static func themeCss() -> File {
        File(
            name: "theme.css",
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

    // MARK: -

    static func theme404Mustache() -> MustacheFile {
        .init(
            name: "404",
            template: """
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

    static func themeDefaultMustache() -> MustacheFile {
        .init(
            name: "default",
            template: """
                {{<html}}
                {{$main}}
                <div class="page">
                    <div class="card">
                        <img src="{{page.image}}">
                    </div>

                    {{& page.contents.html}}
                </div>
                {{/main}}
                {{/html}}
                """
        )
    }

    static func themeHomeMustache() -> MustacheFile {
        .init(
            name: "home",
            template: """
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

    static func themeFooterMustache() -> MustacheFile {
        .init(
            name: "footer",
            template: """
                <footer>
                    <p>This site was generated using <a href="https://www.swift.org/" target="_blank">Swift</a> & <a href="https://github.com/toucansites/toucan" target="_blank">Toucan</a>.</p>

                    <p class="small">{{site.title}} &copy; {{site.generation.formats.year}}.</p>
                </footer>
                """
        )
    }

    static func themeHeaderMustache() -> MustacheFile {
        .init(
            name: "header",
            template: """
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

    static func themeHtmlMustache() -> MustacheFile {
        .init(
            name: "html",
            template: """
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

    static func themeRedirectMustache() -> MustacheFile {
        .init(
            name: "redirect",
            template: """
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

    static func themeRssMustache() -> MustacheFile {
        .init(
            name: "rss.mustache",
            template: """
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

    static func themeSitemapMustache() -> MustacheFile {
        .init(
            name: "sitemap.mustache",
            template: """
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

    // MARK: -

    static func notFoundPage() -> RawContentBundle {
        .init(
            name: "404",
            rawContent: Mocks.RawContents.notFoundPage()
        )
    }

    static func aboutPage() -> RawContentBundle {
        .init(
            name: "about",
            rawContent: Mocks.RawContents.aboutPage()
        )
    }

    static func aboutPageStyleCSS() -> File {
        File(
            name: "style.css",
            string: """
                #home h1 {
                    text-transform: uppercase;
                }
                """
        )
    }

    static func homePage() -> MarkdownFile {
        .init(
            name: "index",
            markdown: Mocks.RawContents.homePage().markdown
        )
    }

    static func post(
        id: Int,
        now: Date = .init(),
        publication: String,
        expiration: String,
        draft: Bool,
        featured: Bool,
        authorIds: [Int],
        tagIds: [Int]
    ) -> RawContentBundle {
        .init(
            name: "post-\(id)",
            rawContent: Mocks.RawContents.post(
                id: id,
                now: now,
                publication: publication,
                expiration: expiration,
                draft: draft,
                featured: featured,
                authorIds: authorIds,
                tagIds: tagIds
            )
        )
    }

    static func rssBundle() -> Directory {
        Directory(name: "rss.xml") {
            File(
                name: "index.yml",
                string: """
                    type: rss
                    """
            )
        }
    }

    static func sitemapBundle() -> Directory {
        Directory(name: "sitemap.xml") {
            File(
                name: "index.yml",
                string: """
                    type: sitemap
                    """
            )
        }
    }

    // MARK: - misc

    static func svg1() -> File {
        File(
            name: "test1.svg",
            string: """
                <svg width="800px" height="800px" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path fill-rule="evenodd" clip-rule="evenodd" d="M6.46967 10.0303C6.17678 9.73744 6.17678 9.26256 6.46967 8.96967L11.4697 3.96967C11.7626 3.67678 12.2374 3.67678 12.5303 3.96967L17.5303 8.96967C17.8232 9.26256 17.8232 9.73744 17.5303 10.0303C17.2374 10.3232 16.7626 10.3232 16.4697 10.0303L12.75 6.31066L12.75 14.5C12.75 15.2133 12.9702 16.3 13.6087 17.1868C14.2196 18.0353 15.2444 18.75 17 18.75C17.4142 18.75 17.75 19.0858 17.75 19.5C17.75 19.9142 17.4142 20.25 17 20.25C14.7556 20.25 13.2804 19.298 12.3913 18.0632C11.5298 16.8667 11.25 15.4534 11.25 14.5L11.25 6.31066L7.53033 10.0303C7.23744 10.3232 6.76256 10.3232 6.46967 10.0303Z" fill="#1C274C"/>
                </svg>
                """
        )
    }

    static func svg2() -> File {
        File(
            name: "test2.svg",
            string: """
                <svg width="800px" height="800px" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path fill-rule="evenodd" clip-rule="evenodd" d="M6.46967 10.0303C6.17678 9.73744 6.17678 9.26256 6.46967 8.96967L11.4697 3.96967C11.7626 3.67678 12.2374 3.67678 12.5303 3.96967L17.5303 8.96967C17.8232 9.26256 17.8232 9.73744 17.5303 10.0303C17.2374 10.3232 16.7626 10.3232 16.4697 10.0303L12.75 6.31066L12.75 14.5C12.75 15.2133 12.9702 16.3 13.6087 17.1868C14.2196 18.0353 15.2444 18.75 17 18.75C17.4142 18.75 17.75 19.0858 17.75 19.5C17.75 19.9142 17.4142 20.25 17 20.25C14.7556 20.25 13.2804 19.298 12.3913 18.0632C11.5298 16.8667 11.25 15.4534 11.25 14.5L11.25 6.31066L7.53033 10.0303C7.23744 10.3232 6.76256 10.3232 6.46967 10.0303Z" fill="#1C274C"/>
                </svg>
                """
        )
    }

    static func yaml1() -> File {
        File(
            name: "test1.yaml",
            string: """
                key1: value1
                key2: value2
                """
        )
    }

    static func yaml2() -> File {
        File(
            name: "test2.yaml",
            string: """
                key3: value3
                key4: value4
                """
        )
    }

}
