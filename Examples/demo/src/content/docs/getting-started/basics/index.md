---
type: guide
title: Basics
description: Basics
category: getting-started
order: 1
---

# Basics

---

Toucan is a static site generator written in Swift that converts Markdown files into HTML files using a theme. No additional dependencies or plugins are required; everything is bundled into the Toucan binary, which can be installed by following the provided installation guides.

## Toucan 101

To start using Toucan, a src directory is required for the site. This directory should contain all the assets, contents, and theme files.

### Directory structure

Below is an example of a minimal directory structure:

```sh
.
├── assets
│   ├── css
│   └── images
├── config.yml
├── contents
├── themes
|   └── default
└── pages
    ├── 404.md
    └── home.md
```

### Configuration

A minimal site configuration (config.yml) is provided below. For more configuration options, refer to the complete configuration reference.

```yml
site:
    baseUrl: http://localhost:3000/
    title: Minimal example
    description: This is a minimal toucan example

```
 
### The 404 page

A sample 404 page file (404.md) is shown below:

```md
---
title: Not found
description: Page not found
---

This page does not exists.

```

### The home page

A basic home page looks like this;

```md
---
title: Home title
description: Home description 
---

Welcome to the home page.

```

### Site generation


To generate the site, run the following command. The generated website will be located inside the dist folder.

```sh
toucan generate ./src ./dist
```

 
