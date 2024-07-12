---
title: Basics
description: Basics
category: getting-started
order: 1
---

# Basics
---

Toucan is a static site generator written in Swift that converts Markdown files into HTML files using a theme. No additional dependencies or plugins are required; everything is bundled into the Toucan binary, which can be installed by following the provided installation guides.

## Directory structure

To start using Toucan, a source (`src`) directory is required for the site. This directory should contain all the assets, contents, and theme files. This guide will explore a minimal setup using the default theme.

### A minimal example

Below is an example of a minimal directory structure:

```sh
.
├── assets
├── config.yml
├── contents
│   └── pages
│       ├── 404.md
│       └── home.md
└── themes
    └── default
        ├── assets
        └── templates
```

## Assets folder

The contents of the assets folder in the `src` directory are copied to the `dist` folder unchanged. A different location can be set by modifying the `input.folder` variable in the assets configuration. The destination folder can be specified by overriding `output.folder` in the assets section of the configuration file. 

## Configuration

The configuration file defines the structure of the content. It allows changes to folder names, slug prefixes, and various site settings.

A minimal site configuration (`config.yml`) is provided below. For more configuration options, refer to the complete [configuration](/docs/getting-started/configuration/) reference.

```yml
site:
    baseUrl: http://localhost:3000/
    title: Minimal example
    description: This is a minimal toucan example

```
 
## Contents

The contents folder contains the main contents of the website. The contents are separated into two categories: static pages and regular contents.

- Static pages are predefined pages with special capabilities and purposes, such as the home page and the not found page. These usually represent a single page within the site.
- Regular contents can be part of a collection, such as blog posts, documentation guides, or similar.
    
Other content types will be explored in the content management section. Now, let’s meet the first two static pages.


### The home page

The home page is the main page of the website. Its contents can be updated by altering the `home.md` file:

```md
---
title: Home title
description: Home description 
---

Welcome to the home page.

```

### The 404 page

A 404 page is an error page displayed when a web server cannot find the requested resource. This typically happens when a user tries to access a page that does not exist or has been moved without updating the links. The number 404 is the HTTP status code for "Not Found." The page informs users that the URL they requested is not available.

A sample 404 page file (`404.md`) is shown below:

```md
---
title: Not found
description: Page not found
---

This page does not exists.

```


## Themes

The themes folder contains the website’s themes. Multiple themes can be copied to this folder, and switching between them is done by altering the `themes.use` value in the configuration.​ By default, the theme located in the `default` folder will be loaded. More information about the themes can be found [here](/docs/getting-started/themes/).


## Site generation


To generate the site, run the following command. The generated website will be located inside the dist folder.

```sh
toucan generate ./src ./dist
```
