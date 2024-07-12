---
title: Themes
description: Themes
category: getting-started
order: 4
---

# Themes
---

A theme is composed of theme asset files and template files. Toucan uses the [Mustache](https://mustache.github.io/mustache.5.html) template engine to render HTML content. 

## Directory structure

A typical directory structure for a template looks like this: 

```sh
.
├── assets
│   ├── css
│   │   ├── theme.style.css
│   └── js
│       └── theme.main.js
└── templates
    ├── blocks
    │   ├── footer.mustache
    │   ├── icons.mustache
    │   ├── navigation.mustache
    │   ├── pagination.mustache
    │   └── toc.mustache
    ├── blog
    │   ├── authors.mustache
    │   ├── blocks
    │   │   ├── author.mustache
    │   │   ├── post.mustache
    │   │   └── tag.mustache
    │   ├── home.mustache
    │   ├── posts.mustache
    │   ├── single
    │   │   ├── author.mustache
    │   │   ├── post.mustache
    │   │   └── tag.mustache
    │   └── tags.mustache
    ├── docs
    │   ├── blocks
    │   │   ├── categories.mustache
    │   │   ├── category.mustache
    │   │   └── guide.mustache
    │   ├── categories.mustache
    │   ├── guides.mustache
    │   ├── home.mustache
    │   └── single
    │       ├── category.mustache
    │       └── guide.mustache
    ├── index.mustache
    ├── main
    │   ├── 404.mustache
    │   └── home.mustache
    ├── pages
    │   ├── home.mustache
    │   └── single
    │       └── page.mustache
    ├── redirect.mustache
    ├── rss.mustache
    └── sitemap.mustache
```

## Assets

The assets directory is simply copied to the `dist` folder. Assets can be referenced using the site base URL.

```
&lt;link rel="stylesheet" href="{{site.baseUrl}}css/theme.style.css"&gt;
&lt;!-- or --&gt;
&lt;link rel="stylesheet" href="/css/theme.style.css"&gt;
```
Alternatively, assets can be referenced by using the absolute path with a leading slash (`/`).

## Templates

A template is a predefined layout and structure used to generate the HTML content of a website. It consists of various template files that define the appearance and functionality of different parts of the site. These templates are processed by a template engine, like Mustache, to produce the final HTML pages by combining the templates with the content.

### Top level templates

There are four main template files in a typical Toucan theme:

- `index.mustache` - Defines the main frame for every HTML file.
- `rss.mustache` - Defines the rss.xml output.
- `sitemap.mustache` - Defines the sitemap.xml output.
- `redirect.mustache` - Used to redirect pages.

### Page templates

Page templates are used to render a single page. Such as the `main/home.mustache` and the `main/404.mustache`. Every page template is embedded into the index.mustache template they can alter the body of the final html output by defining a custom main block. 

Toucan uses the following page templates:

- `main/home.mustache` - The home page template.
- `main/404.mustache` - The not found page template.

- `blog/home.mustache` - The blog home page template.
- `blog/authors.mustache` - The authors page template.
- `blog/tags.mustache` - The tags page template.
- `blog/posts.mustache` - The paginated posts page template.
- `blog/single/author.mustache` - The single author template.
- `blog/single/post.mustache` - The single post template.
- `blog/single/tag.mustache` - The single tag template.

- `docs/home.mustache` - The docs home page template.
- `docs/categories.mustache` - The docs categories template. 
- `docs/guides.mustache` - The docs guides template.
- `docs/single/category.mustache` - The single category template.
- `docs/single/guide.mustache` - The single guide template.

- `pages/home.mustache` - The pages home template.
- `pages/single/page.mustache` - The single page template.

### Block templates

Templates can also include other templates, Mustache has built-in support for this. Partial templates are called blocks, they are always located in a blocks folder.


## Using a theme

Switching between themes is done by altering the `themes.use` value in the [configuration](/docs/getting-started/configuration/#themes). By default, the theme located in the default folder will be loaded. 

## Building themes

See the [theme reference guides](/docs/themes/) for more information.
