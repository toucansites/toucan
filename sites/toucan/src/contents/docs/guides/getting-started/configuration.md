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

Site-related configuration values:

#### `baseUrl`
**Type:** String
**Description:** The base URL of the entire website.
**Example:**

```yaml
baseUrl: http://example.com
```

#### `language`
**Type:** String
**Description:** The [ISO 639-1](https://www.w3schools.com/tags/ref_language_codes.asp) language code for the website, can be a [country code](https://www.w3schools.com/tags/ref_country_codes.asp).
**Example:**

```yaml
language: en
```

#### `title`

**Type:** String
**Description:** The title of the website.
**Example:**

```yaml
title: Scientific Titans Blog
```

#### `description`

**Type:** String
**Description:** The description of the website.
**Example:**

```yaml
description: A blog about the greatest scientific minds and their discoveries.
```

#### `dateFormat`

**Type:** String
**Description:** The date format used on the website.
**Default Value:** `"yyyy.MM.dd. HH:mm"`
**Example:**

```yaml
dateFormat: "yyyy.MM.dd. HH:mm"
```

#### `noindex`

**Type:** Bool
**Description:** If `true`, the site will be marked as not indexable by search engines.
**Default Value:** `false`
**Example:**

```yaml
noindex: false
```

#### `hreflang`
**Type:** Array of objects
**Description:** The array of hreflang objects for specifying alternate language versions of the site.

##### `hreflang.lang`
**Type:** String
**Description:** The [ISO 639-1](https://www.w3schools.com/tags/ref_language_codes.asp) language code for the website, can be a [country code](https://www.w3schools.com/tags/ref_country_codes.asp).

##### `hreflang.url`
**Type:** String
**Description:** The full URL of the site in the specified language.

**Example:**

```yaml
hreflang:
    - lang: en
      url: http://example.com/en/
    - lang: es
      url: http://example.com/es/
```


### Assets

Asset management related configuration values:

#### `input`

**Type:** Object
**Description:** The configuration for the assets input. The contents of this folder will be copied to the output folder.


##### `input.folder`

**Type:** String
**Description:** The location of the assets folder.
**Default Value:** "assets"
**Example:**

```yaml
input:
    folder: "assets"
```

#### `output`

**Type:** Object
**Description:** The configuration for the assets output. If the destination folder name is empty the root folder will be used.


##### `output.folder`

**Type:** String
**Description:** The location of the destination folder.
**Default Value:** ""
**Example:**

```yaml
output:
    folder: ""
```


### Themes

Theme related configuration values:

#### `use`

**Type:** String
**Description:** The name of the selected theme.
**Default Value:** `default`
**Example:**

```yaml
use: "default"
```

#### `folder`

**Type:** String
**Description:** The location of the themes folder inside the src directory.
**Default Value:** `themes`
**Example:**

```yaml
folder: "themes"
```

#### `templates`

**Type:** Object
**Description:** The configuration for the theme templates.


##### `templates.folder`

**Type:** String
**Description:** The location of the templates folder inside the theme folder.
**Default Value:** "templates"
**Example:**

```yaml
templates:
    folder: "templates"
```

#### `assets`

**Type:** Object
**Description:** The configuration for the theme assets.


##### `assets.folder`

**Type:** String
**Description:** The location of the assets folder inside the theme folder.
**Default Value:** "assets"
**Example:**

```yaml
assets:
    folder: "templates"
```

#### `overrides`

**Type:** Object
**Description:** The configuration for the theme overrides.


##### `overrides.folder`

**Type:** String
**Description:** The location of the theme overrides folder inside the src folder.
**Default Value:** "theme_overrides"
**Example:**

```yaml
overrides:
    folder: "theme_overrides"
```

### Contents

### Pages

### UserDefined
