# Toucan

Toucan is a markdown-based Static Site Generator (SSG) written in Swift.

## Roadmap

### Must fix before 1.0-alpha.1

- proper context building, with css, js, etc.
- full context -> proper context + recursive issue
- render content pagination 
- proper asset management & minor fixes related to asset urls
- proper toc api
- proper content query api $prev, $next, $same, etc...
- noindex slug removal
- proper multiple file extension support (md + markdown, yaml + yml)
- do not wipe output? :think:


### 1.0-alpha.1

+ noindex tag support (site + page level):
    noindex: true
    <meta name="robots" content="noindex">
    
+ draft content:
    draft: true -> not being rendered.

+ publication date, expiration date support for posts:
    publication: 2023-04-22 12:01:01
    expiration: 2024-04-22 12:01:01
    
    filter posts based on actual date.

+ canonical url support:
    self-referencing by default:
        <link rel="canonical" href="https://example.com/" />
    override:
        canonical: https://foo.com/bar/baz
        
    pagination canonicals:
        <link rel="prev" href="https://example.com/posts/page/1" />
        <link rel="next" href="https://example.com/posts/page/3" />

+ hreflang attributes support
    gb site:
        <link rel="canonical" href="https://example.com/gb/" /> 
        <link rel=“alternate” hreflang=“en-gb” href=“https://example.com/gb/” />  
        <link rel=“alternate” hreflang=“en” href=“https://example.com/” />  
        <link rel=“alternate” hreflang=“x-default” href=“https://example.com/” />  
    us site:
        <link rel="canonical" href="https://example.com/" /> 
        <link rel=“alternate” hreflang=“en-gb” href=“https://example.com/gb/” />  
        <link rel=“alternate” hreflang=“en” href=“https://example.com/” />  
        <link rel=“alternate” hreflang=“x-default” href=“https://example.com/” />

    site / material config:
        hreflang:
            - lang: en
              url: https://www.example.com/
            - lang: en-gb
              url: https://www.example.com/gb/
            - lang: x-default
              url: https://www.example.com/
 
- demo template design
- toucan user guides
- Swift 5.10 docker
- toucan installer
- toucan website
- file watcher
- web server & preview
- schema.org + json-ld support


### 1.0+

- date x y ago feature
? add current path check (to mark menu as current)
- image resize & optimize support
- content transformers -> call script using markdown input -> output
    - plugins/a "markdwon" >> plugins/b >> etc... (last one built-in stuff)
- sitemap index support
- content importer
    - jekyll
    - hugo
    - ghost
    - wordpress
    - medium
    - notion
- publish subcommand 
    - github pages
    - aws bucket?
    

## Directory structure

https://docs.hummingbird.codes/2.0/documentation/hummingbird/transforms/

```
src
    contents
        posts
            post1
                post1.md
                post1-cover.jpg
        pages
            page1
                contents.md

        404.md
        index.md
        home.md

    templates
        index.html
        home.html
        home-posts.html
        404.html
        page.html
        post.html

    public
        * (everyting copied as it is)
```

## Metadata keys

Required:
- slug
- title
- description
- date

Optional:
- template


## Configuration

site.config.md

- site.baseUrl: 
- site.language:
- site.title: 
- site.description: 
- site.imageUrl: 

- posts.slug = posts
- posts.limit = 10

## Pagination & tags

reserved slugs:
/css
/images
/js

/index.html                 index page 

/page1/index.html           page entries
/page2/index.html

/post1/index.html           post entries
/post2/index.html

/posts/index.html           list of all blog posts, paginated
/posts/page/1/index.html    canonical = /posts/index.html
/posts/page/2/index.html
/posts/page/3/index.html

/tags/index.html            list of all tags (not paginated)
/tags/foo/index.html
/tags/bar/index.html

/authors/index.html         list of all authors (not paginated)
/authors/tibor-bodecs/index.html




## Template render pipeline


index->home->post
index->404
index->page
index->post


site->index->post

site.html
@@@
site.title
site.slug
site.description

index.html
@@@
site.index.title
site.index.description

global variables
{site.index}

local variables:
{$.title}
{$.description}
{$.tags|<a href="asdf">$</a>}


search:
    index.json
        [
            {
                "keywords": [
                    "foo", 
                    "bar", 
                    "baz"
                ]
                "item": {
                    "title": "",
                    "description": "",
                    "permalink": ""
                    "image": ""
                }
            }
        ]

    javascript api call
