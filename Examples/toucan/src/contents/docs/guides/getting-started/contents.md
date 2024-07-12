---
title: Contents
description: Contents
category: getting-started
order: 3
---

# Contents
---

Every page on the site is represented in markdown format and loaded from the contents directory.

## Directory structure

The contents directory includes a special folder called pages for “static” pages. These static pages are defined by the Toucan generation process; most are optional, but the `home.md` and `404.md` files are required. The exception is the pages/custom folder, which can be used to define custom “dynamic” page contents.

Dynamic page contents have their own directories. These directories are searched for markdown files, which are then loaded and used during the site generation process. There are several other content types, and the locations of these can be configured.

For example:

- `contents/blog/authors` - All authors will be loaded from here.
- `contents/blog/posts` - All posts will be loaded from here.
- `contents/docs/guides` - All guides will be loaded from here.
- `contents/pages/custom` - All dynamic custom pages will be loaded from here.

Please note that all of these paths can be customized using the [configuration](/docs/getting-started/configuration/) file.

Here is a quick overview of the directory structure:

```sh
.
├── assets
├── config.yml
├── contents
│   ├── blog
│   │   ├── authors
│   │   │   └── my-author.md
│   │   ├── posts
│   │   │   └── my-post.md
│   │   └── tags
│   │       └── my-tag.md
│   ├── docs
│   │   ├── categories
│   │   │   └── my-category.md
│   │   └── guides
│   │       └── my-category
│   │           └── my-guide.md
│   └── pages
│       ├── blog
│       │   ├── authors.md
│       │   ├── home.md
│       │   ├── posts.md
│       │   └── tags.md
│       ├── custom
│       │   └── my-page.md
│       ├── docs
│       │   ├── categories.md
│       │   ├── guides.md
│       │   └── home.md
│       ├── 404.md
│       ├── home.md
│       └── pages.md
└── themes
```

Lorem ipsum dolor sit amet 4

## Static pages

Static pages feature custom template variables that can be used to build different layouts for various needs. Here is a list of the available static page options:

### Generic 

- `pages/home.md` - The home page
- `pages/404.md` - The not found home page
- `pages/pages.md` - Custom pages home page

### Blog 

- `pages/blog/home.md` - Blog home page
- `pages/blog/authors.md` - Authors page
- `pages/blog/posts.md` - Paginated posts page
- `pages/blog/tags.md` - Tags page

### Docs 

- `pages/docs/home.md` - Docs home page
- `pages/docs/categories.md` - Categories page
- `pages/docs/guides.md` - Guides page


## Dynamic page contents

Dynamic pages are contents of the same type, such as blog posts, guides, or custom pages. These contents are rendered using the "single" page templates. More information about these templates can be found in the template guides.

Here is a list of the availble dynamic page contents:

### Generic 

- `pages/custom` - All the custom pages 

### Blog 

- `blog/authors` - All the authors
- `blog/tags` - All the tags
- `blog/posts` - All the posts

### Docs 

- `docs/categories` - All the authors
- `docs/guides` - All the guides


## Configuration

The entire content directory structure can be customized using the [configuration](/docs/getting-started/configuration/#contents) file.
