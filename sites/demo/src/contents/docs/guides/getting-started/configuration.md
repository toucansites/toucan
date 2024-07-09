---
title: Configuration
description: Configuration
category: getting-started
order: 3
---

# Configuration

The site configuration for Toucan is stored in a config.yaml file, though the .yml extension can also be used.


## Examples

In this section, we provide both a minimal and a complete example for the Toucan configuration file.


### Minimal

Here’s an minimal example of a complete site configuration:

```yaml
site:
    baseUrl: http://localhost:3000/
    title: Example site
    description: This is an example website.
```

### Complete

Here’s an example of a complete site configuration:

```yaml
site:
    baseUrl: http://localhost:3000/
    language: en-US
    title: Scientific Titans Blog
    description: This is a demo blog using completely fake content.
    dateFormat: "yyyy.MM.dd. HH:mm"
    noindex: false
    hreflang:
        - lang: en
          url: https://www.example.com/
        - lang: en-gb
          url: https://www.example.com/gb/
        - lang: x-default
          url: https://www.example.com/


assets:
    input:
        folder: "assets"
    output:
        folder: ""

themes:
    use: "default"
    folder: "themes"
    templates:
        folder: "templates"
    assets:
        folder: "assets"
    overrides:
        folder: "theme_overrides"

contents:
    folder: "contents"
    assets:
        output:
            folder: "assets"
            
    pagination:
        limit: 10

    blog:
        authors:
            folder: "blog/authors"
            slugPrefix: "blog/authors"
        tags:
            folder: "blog/tags"
            slugPrefix: "blog/tags"
        posts:
            folder: "blog/posts"
            slugPrefix: "blog/posts"
    docs:
        categories:
            folder: "docs/categories"
            slugPrefix: "docs"
        guides:
            folder: "docs/guides"
            slugPrefix: "docs"
    pages:
        custom:
            folder: "pages/custom"
            slugPrefix: ""

pages:
    main:
        home:
            path: "pages/home"
        notFound:
            path: "pages/404"
    blog:
        home:
            path: "pages/blog/home"
        authors:
            path: "pages/blog/authors"
        tags:
            path: "pages/blog/tags"
        posts:
            path: "pages/blog/posts"
    docs:
        home:
            path: "pages/docs/home"
        categories:
            path: "pages/docs/categories"
        guides:
            path: "pages/docs/guides"

userDefined:
    foo:
        bar: baz
        baz: abc

```



## Reference

This section provides a complete reference for the Toucan configuration file, detailing all available settings.

### Site

Site related configuration values:

- `baseUrl`: **String** - The base url of the entire website.
- `language`: **String** - The [ISO 639-1](https://www.w3schools.com/tags/ref_language_codes.asp) lang code for the website, can be a [country code](https://www.w3schools.com/tags/ref_country_codes.asp).
- `title`: **String** - The title of the website. Scientific Titans Blog
- `description`: **String** - The description of the website. 
- `dateFormat`: **String** - default value: "yyyy.MM.dd. HH:mm"
- `noindex`: **Bool** - default value: `false`
- `hreflang`: **Dictionary** - 



### Assets

### Themes

### Contents

### Pages

### UserDefined
