//
//  Mocks+Views.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 21..
//

@testable import ToucanSource

extension Mocks.Views {
    static func all(
        contextValue: String = "{{.}}"
    ) -> Template {
        .init(
            metadata: .init(
                name: "Mock",
                description: "Mock template",
                url: "",
                version: "1.0.0-beta.5",
                generatorVersions: ["1.0.0-beta.5"],
                license: .init(name: "", url: ""),
                author: .init(name: "", url: ""),
                demo: .init(url: ""),
                tags: []
            ),
            components: .init(
                assets: [],
                views: [
                    .init(id: "html", path: "", contents: html()),
                    .init(id: "redirect", path: "", contents: redirect()),
                    .init(id: "rss", path: "", contents: rss()),
                    .init(id: "sitemap", path: "", contents: sitemap()),

                    .init(id: "pages.default", path: "", contents: page()),
                    .init(id: "pages.404", path: "", contents: notFound()),
                    .init(id: "pages.context", path: "", contents: context(value: contextValue)),

                    .init(id: "docs.category.default", path: "", contents: category()),
                    .init(id: "docs.guide.default", path: "", contents: guide()),

                    .init(id: "blog.post.default", path: "", contents: post()),
                    .init(id: "blog.author.default", path: "", contents: author()),
                    .init(id: "blog.tag.default", path: "", contents: tag()),

                    .init(id: "partials.blog.author", path: "", contents: partialAuthor()),
                    .init(id: "partials.blog.tag", path: "", contents: partialTag()),
                    .init(id: "partials.blog.post", path: "", contents: partialPost()),

                    .init(id: "partials.docs.category", path: "", contents: partialCategory()),
                    .init(id: "partials.docs.guide", path: "", contents: partialGuide()),
                ]
            ),
            overrides: .init(assets: [], views: []),
            content: .init(assets: [], views: [])
        )
    }

    static func redirect() -> String {
        #"""
        <!DOCTYPE html>
        <html{{#site.language}} lang="{{.}}"{{/site.language}}>
          <meta charset="utf-8">
          <title>Redirecting&hellip;</title>
          <link rel="canonical" href="{{baseUrl}}/{{page.to}}">
          <script>location="{{baseUrl}}/{{page.to}}"</script>
          <meta http-equiv="refresh" content="0; url={{baseUrl}}/{{page.to}}">
          <meta name="robots" content="noindex">
          <h1>Redirecting&hellip;</h1>
          <a href="{{baseUrl}}/{{page.to}}">Click here if you are not redirected.</a>
        </html>
        """#
    }

    static func rss() -> String {
        #"""
        <rss xmlns:atom="http://www.w3.org/2005/Atom" version="2.0">
        <channel>
            <title>{{site.name}}</title>
            <description>{{site.description}}</description>
            <link>{{baseUrl}}</link>
            <language>{{site.language}}</language>
            <lastBuildDate>{{generation.formats.rss}}</lastBuildDate>
            <pubDate>{{lastUpdate.formats.rss}}</pubDate>
            <ttl>250</ttl>
            <atom:link href="{{baseUrl}}/rss.xml" rel="self" type="application/rss+xml"/>

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
        """#
    }

    static func sitemap() -> String {
        #"""
        <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
            <url>

            {{#context.pages}}
                <loc>{{permalink}}</loc>
                <lastmod>{{lastUpdate.formats.sitemap}}</lastmod>
            {{/context.pages}}

            {{#context.posts}}
                <loc>{{permalink}}</loc>
                <lastmod>{{lastUpdate.formats.sitemap}}</lastmod>
            {{/context.posts}}

            {{#context.authors}}
                <loc>{{permalink}}</loc>
                <lastmod>{{lastUpdate.formats.sitemap}}</lastmod>
            {{/context.authors}}

            {{#context.tags}}
                <loc>{{permalink}}</loc>
                <lastmod>{{lastUpdate.formats.sitemap}}</lastmod>
            {{/context.tags}}

            {{#context.categories}}
                <loc>{{permalink}}</loc>
                <lastmod>{{lastUpdate.formats.sitemap}}</lastmod>
            {{/context.categories}}

            {{#context.guides}}
                <loc>{{permalink}}</loc>
                <lastmod>{{lastUpdate.formats.sitemap}}</lastmod>
            {{/context.guides}}

            </url>
        </urlset>
        """#
    }

    static func html() -> String {
        #"""
        <!DOCTYPE html>
        <html {{#site.locale}}lang="{{.}}"{{/site.locale}}>
        <head>
            <meta charset="utf-8">
            {{#page.noindex}}<meta name="robots" content="noindex">{{/page.noindex}}
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <meta name="description" content="{{page.description}}">

            <title>{{page.title}}</title>

            <link rel="canonical" href="{{page.permalink}}">
            {{#page.hreflang}}
            <link rel="alternate" hreflang="{{lang}}" href="{{url}}">
            {{/page.hreflang}}
            {{#page.prev}}<link rel="prev" href="{{permalink}}">{{/page.prev}}
            {{#page.next}}<link rel="next" href="{{permalink}}">{{/page.next}}

            <link rel="stylesheet" href="{{baseUrl}}/css/style.css">
            <link rel="stylesheet" href="{{baseUrl}}/css/template.css">

            {{#page.css}}<link rel="stylesheet" href="{{.}}">{{/page.css}}
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
        """#
    }

    static func notFound() -> String {
        #"""
        {{<html}}
        {{$main}}

        <div id="not-found" class="wrapper">
            {{& page.contents.html}}
        </div>

        {{/main}}
        {{/html}}
        """#
    }

    static func navigation() -> String {
        #"""
        <header id="navigation">
            <nav>
                <div class="menu-items">
                    {{#site.navigation}}
                    <a href="{{url}}"{{#class}} class="{{.}}"{{/class}}>{{label}}</a>
                    {{/site.navigation}}
                </div>
            </nav>
        </header>
        """#
    }

    static func footer() -> String {
        #"""
        <footer id="site-footer">
            <p>Toucan</p>
        </footer>
        """#
    }

    static func page() -> String {
        #"""
        {{<html}}
        {{$main}}

        {{& page.contents.html}}

        {{/main}}
        {{/html}}
        """#
    }

    static func context(
        value: String
    ) -> String {
        #"""
        \#(value)
        """#
    }

    static func post() -> String {
        #"""
        {{<html}}
        {{$main}}
        <article class="post">

            <header>
                {{#page.image}}<img src="{{page.image}}" alt="{{page.title}}">{{/page.image}}
                <div class="meta">
                    <time datetime="{{page.publication.formats.iso8601}}">{{page.publication.date.short}} {{page.publication.time.short}}</time>
                    {{#page.contents.readingTime}} &middot; <span class="reading-time">{{.}} min read</span>{{/page.contents.readingTime}}
                </div>
                <h1>{{page.title}}</h1>
                <hr>
                <p class="excerpt">{{page.description}}</p>


            </header>

            <section>

            {{& page.contents.html}}

            </section>

            <footer class="grid grid-221">
                <div class="author-list">
                {{#page.authors}}
                    <a href="{{permalink}}">
                    {{#image}}<img class="medium rounded" src="{{image}}" alt="{{title}}">{{/image}}
                    </a>
                {{/page.authors}}
                </div>
                <div class="tag-list">
                {{#page.tags}}
                    <a href="{{permalink}}"><small>{{title}}</small></a>
                {{/page.tags}}
                </div>
            </footer>

            <section>
            {{#empty(page.related)}}
            {{/empty(page.related)}}
            {{^empty(page.related)}}
            <h4>Related articles</h4>
            <br>
            <div class="grid grid-221">
            {{#page.related}}
                {{> partials.blog.post}}
            {{/page.related}}
            </div>
            {{/empty(page.related)}}
            </section>

        </article>

        <div class="fixed-toc">
        {{> partials.outline }}
        </div>

        {{/main}}
        {{/html}}
        """#
    }

    static func posts() -> String {
        #"""
        {{<html}}
        {{$main}}

        {{& page.contents.html}}

        <div id="posts" class="wrapper">

            {{#empty(iterator.items)}}
            Empty.
            {{/empty(iterator.items)}}
            {{^empty(iterator.items)}}
            <div class="grid grid-321">
            {{#iterator.items}}
                {{> partials.blog.post}}
            {{/iterator.items}}
            </div>
            {{/empty(iterator.items)}}

            {{#empty(iterator.links)}}
            {{/empty(iterator.links)}}
            {{^empty(iterator.links)}}
            <div class="pagination">
            {{#iterator.links}}
                {{> partials.pagination}}
            {{/iterator.links}}
            </div>
            {{/empty(iterator.links)}}

        </div>

        {{/main}}
        {{/html}}
        """#
    }

    static func tags() -> String {
        #"""
        {{<html}}
        {{$main}}

        {{& page.contents.html}}

        <div id="tags" class="wrapper">
            {{#empty(context.tags)}}
            Empty.
            {{/empty(context.tags)}}
            {{^empty(context.tags)}}
            <div class="grid grid-221">
            {{#context.tags}}
                {{> partials.blog.tag}}
            {{/context.tags}}

            </div>
            {{/empty(context.tags)}}
        </div>

        {{/main}}
        {{/html}}    
        """#
    }

    static func authors() -> String {
        #"""
        {{<html}}
        {{$main}}

        {{& page.contents.html}}

        <div id="authors" class="wrapper">

            {{#empty(context.authors)}}
            Empty.
            {{/empty(context.authors)}}
            {{^empty(context.authors)}}
            <div class="grid grid-221">
            {{#context.authors}}
                {{> partials.blog.author}}
            {{/context.authors}}
            </div>
            {{/empty(context.authors)}}

        </div>

        {{/main}}
        {{/html}}
        """#
    }

    static func blogHome() -> String {
        #"""
        {{<html}}
        {{$main}}

        {{& page.contents.html}}

        <div id="blog" class="wrapper">

            {{#empty(context.posts)}}
            Empty.
            {{/empty(context.posts)}}
            {{^empty(context.posts)}}
            <div id="blog-posts" class="grid grid-321">
            {{#context.posts}}
                {{> partials.blog.post}}
            {{/context.posts}}
            </div>
            {{/empty(context.posts)}}

            <br>
            <a href="/articles/page/1" class="cta">Browse all articles</a>


            <h2>Tags</h2>
            <br>
            {{#empty(context.tags)}}
            Empty.
            {{/empty(context.tags)}}
            {{^empty(context.tags)}}
                <div class="grid grid-221">
            {{#context.tags}}
                {{> partials.blog.tag}}
            {{/context.tags}}
            </div>
            {{/empty(context.tags)}}

            <h2>Authors</h2>
            <br>
            {{#empty(context.authors)}}
            Empty.
            {{/empty(context.authors)}}
            {{^empty(context.authors)}}
                <div class="grid grid-221">
            {{#context.authors}}
                {{> partials.blog.author}}
            {{/context.authors}}
            </div>
            {{/empty(context.authors)}}

        </div>
        {{/main}}
        {{/html}}
        """#
    }

    static func tag() -> String {
        #"""
        {{<html}}
        {{$main}}

        <div id="tag">
            <header>
                {{#page.image}}<img class="medium" src="{{.}}" alt="{{page.title}}">{{/page.image}}
                <h1>{{page.title}}</h1>
                <hr>
                <p>{{page.description}}</p>
                <p>{{count(page.posts)}} articles</p>
            </header>

            {{& page.contents.html}}

            {{#empty(page.posts)}}
            Empty.
            {{/empty(page.posts)}}
            {{^empty(page.posts)}}
            <div class="grid grid-321">
            {{#page.posts}}
                {{> partials.blog.post}}
            {{/page.posts}}
            </div>
            {{/empty(page.posts)}}
        </div>

        {{/main}}
        {{/html}}
        """#
    }

    static func author() -> String {
        #"""
        {{<html}}
        {{$main}}
        <div id="author-page">

            <header>
                {{#page.image}}<img class="large rounded" src="{{.}}" alt="{{page.title}}">{{/page.image}}
                <h1>{{page.title}}</h1>
                <hr>
                <p>{{page.description}}</p>
                <p>{{count(page.posts)}} articles</p>
            </header>

            {{& page.contents.html}}

            {{#empty(page.posts)}}
            Empty.
            {{/empty(page.posts)}}
            {{^empty(page.posts)}}
            <div class="grid grid-321">
            {{#page.posts}}
                {{> partials.blog.post}}
            {{/page.posts}}
            </div>
            {{/empty(page.posts)}}

        </div>

        {{/main}}
        {{/html}}

        """#
    }

    static func category() -> String {
        #"""
        {{<html}}
        {{$main}}
        <div id="docs">
            <div class="left">
                {{> partials.docs.categories }}
            </div>
            <div class="center">
                <article>
                    <a href="/docs/">Docs</a>
                    {{& page.contents.html}}

                    {{#empty(page.guides)}}
                    {{/empty(page.guides)}}
                    {{^empty(page.guides)}}
                    <h2>Guides</h2>
                    <ul>
                    {{#page.guides}}
                        <li><a href="{{permalink}}">{{title}}</a></li>
                    {{/page.guides}}
                    </ul>
                    {{/empty(page.guides)}}
                </article>
            </div>
            <div class="right">
                {{> partials.outline }}
            </div>
        </div>
        {{/main}}
        {{/html}}
        """#
    }

    static func guide() -> String {
        #"""
        {{<html}}
        {{$main}}

        <div id="docs">
            <div class="left">
                {{> partials.docs.categories }}
            </div>
            <div class="center">
                <article>
                    {{#page.category}}
                    <a href="{{permalink}}">{{title}}</a>
                    {{/page.category}}

                    {{& page.contents.html}}


                    <section>
                    <div class="grid grid-2">
                    {{^page.guide.prev}}
                    <div></div>
                    {{/page.guide.prev}}
                    {{#page.guide.prev}}
                    <div class="prev">
                        <h4>&larr; Prev guide</h4>
                        <small>{{category.title}}</small>
                        <a href="{{permalink}}">{{title}}</a>
                    </div>
                    {{/page.guide.prev}}

                    {{^page.guide.next}}
                    <div></div>
                    {{/page.guide.next}}
                    {{#page.guide.next}}
                    <div class="next">
                        <h4 style="text-align: right;">Next guide &rarr;</h4>
                        <small>{{category.title}}</small>
                        <a href="{{permalink}}">{{title}}</a>
                    </div>
                    {{/page.guide.next}}
                    </div>
                    </section>

                </article>
            </div>
            <div class="right">
                {{> partials.outline }}
            </div>
        </div>
        {{/main}}
        {{/html}}
        """#
    }

    static func docsHome() -> String {
        #"""
        {{<html}}
        {{$main}}
        <div id="docs">
            <div class="left">
                {{> partials.docs.categories }}
            </div>
            <div class="center">
                <article>
                    {{& page.contents.html}}

                </article>
            </div>
            <div class="right">
                {{> partials.outline }}
            </div>
        </div>
        {{/main}}
        {{/html}}

        """#
    }

    static func home() -> String {
        #"""
        {{<html}}
        {{$main}}

        {{& page.contents.html}}

        <div class="centered">
        <h2>Most recent</h2>

        <p>Latest static site generator news, Toucan updates and releases.</p>
        </div>
        {{#empty(context.posts)}}
        Empty.
        {{/empty(context.posts)}}
        {{^empty(context.posts)}}
        <div class="grid grid-321">
        {{#context.posts}}
            {{> partials.blog.post}}
        {{/context.posts}}
        </div>
        {{/empty(context.posts)}}

        <div class="centered">
            <br>
        <a href="/articles/page/1/" class="cta">Browse all articles</a>
        </div>

        {{/main}}
        {{/html}}
        """#
    }

    static func partialAuthor() -> String {
        #"""
        <div class="card centered">
            {{#image}}
            <a href="{{permalink}}">
                <img class="large rounded" src="{{.}}" alt="{{title}}">
            </a>
            {{/image}}
            <h2><a href="{{permalink}}">{{title}}</a></h2>
            <p>{{count(posts)}} articles</p>
        </div>
        """#
    }

    static func partialPost() -> String {
        #"""
        <div class="post card">
            {{#featured}}<span class="featured">featured</span>{{/featured}}

            {{#image}}
            <a href="{{permalink}}" target="">
                <img src="{{image}}" alt="{{title}}">
            </a>
            {{/image}}
            <div class="meta">
                <time datetime="{{publication.formats.iso8601}}">{{publication.date.short}}</time>
                {{#contents.readingTime}} &middot; <span class="reading-time">{{.}} min read</span>{{/contents.readingTime}}
            </div>

            <h2 class="title"><a href="{{permalink}}" target="">{{title}}</a></h2>
            <hr>
            <p>{{description}}</p>

            <div class="grid grid-221">
                <div class="author-list">
                {{#authors}}
                    <a href="{{permalink}}">
                    {{#image}}<img class="small rounded" src="{{image}}" alt="{{title}}">{{/image}}
                    </a>
                {{/authors}}
                </div>

                <div class="tag-list">
                {{#tags}}
                    <a href="{{permalink}}"><small>{{title}}</small></a>
                {{/tags}}
                </div>
            </div>
        </div>

        """#
    }

    static func partialTag() -> String {
        #"""
        <div class="card centered">
            {{#image}}
            <a href="{{permalink}}">
                <img class="medium" src="{{.}}" alt="{{title}}">
            </a>
            {{/image}}
            <h2><a href="{{permalink}}">{{title}}</a></h2>
            <p>{{count(posts)}} articles</p>
        </div>

        """#
    }

    static func partialCategories() -> String {
        #"""
        <aside>
            <ul>
            {{#context.categories}}
                <li class="category">
                    <a href="{{permalink}}">{{title}}</a>
                    <ul>
                    {{#guides}}
                        <li><a href="{{permalink}}">{{title}}</a></li>
                    {{/guides}}
                    </ul>
                </li>
            {{/context.categories}}
            </ul>
        </aside>

        """#
    }

    static func partialCategory() -> String {
        #"""
        <a href="{{permalink}}">
        <h2 class="title">{{title}}</h2>
        </a>
        """#
    }

    static func partialGuide() -> String {
        #"""
        <a href="{{permalink}}">
        <h2 class="title">{{title}}</h2>
        </a>
        """#
    }
}
