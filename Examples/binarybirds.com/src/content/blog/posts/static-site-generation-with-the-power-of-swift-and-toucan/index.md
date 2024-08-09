---
type: post
title: Static site geneneration with the power of Swift and Toucan
description: Toucan is a lightweight static site generator written in Swift. This article will guide you through the process of creating your own website using it.
image: ./static-site-generation-with-the-power-of-swift-and-toucan/cover.jpg
publication: 2023-04-24 18:32:25
tags:
  - swift
  - product-updates
authors:
  - tibor-bodecs
---

## Installation

Toucan is available on [GitHub](https://github.com/binarybirds/toucan) as an open source Swift package. Feel free to clone the repository and run `make install` to make the `toucan` command available.

```
git clone https://github.com/BinaryBirds/Toucan.git
cd Toucan
make install
```

## Usage

Toucan has 3 subcommands:

- generate
- watch
- serve

You should be able to generate a new website by using the `generate` command. You just need a project template that is compatible with the static site generator. We're going to release an official template project for this purpose later on, but for now feel free to grab the source code of [this website](https://github.com/binarybirds/site) and use that as a starter project.

```
toucan generate ./src ./docs
```

By using the `watch` command you should be able to watch for file changes and auto-generate the static site, based on your source folder.

```
toucan watch ./src ./docs
```

The `serve` command will launch a basic web server, that you can use to preview your static site.

```
toucan serve ./docs
```

## Project structure

The `src` directory is where your content and template files should be located. There are three key directories that toucan will use to generate your website.

- `contents` - Your content using Markdown
- `public` - Public files
- `templates` - Template files

### Contents

The contents folder is organized the following way:

- `posts` - Place your blog posts under this folder
- `pages` - Place your page contents this folder
- `404.md` - The content configuration for the not found page
- `home.md` - The content configuration for the home page
- `index.md` - The content configuration for the entire site

Toucan will try to recursively discover all the `content.md` files under the posts and pages directory, and process everything based on those. You can also add cover image support by placing a `cover.jpg` file next to them.

You can easily embed images, just create an `images` folder next to your `content.md` file and you can reference those images without path prefixes, this also support dark mode variants, if you suffix the images with `~dark`.

### Public files

Everything what is located inside the public folder will be copied recursively during site generation process. This means you can reference these files when building your templates or writing your content. Feel free to use this folder for your CSS and public image assets.

### Templates

The templates folder should contain the following files:

- `index.html` - Tha index template file
- `404.html` - The not found template
- `home.html` - The home template file
- `home-posts.html` - Post template for the home page
- `page.html` - Template file for individual pages
- `post.html` - Template file for posts

Templates are plain old HTML files, feel free to modify them as you wish, you can use a few built-in variables to make them a bit more dynamic. Variables are in between `{}` characters.

- `baseUrl` - Returns the base URL of the site
- `title` - The title of the page
- `description` - The description of the page
- `image` - The cover image of the page
- `slug` - The slug of the page
- `permalink` - The permalink of the page
- `contents` - Used to embed other contents
- `date` - The date of the post
- `tags` - The tag list for the post

## Markdown

You can write your content as [Markdown](https://daringfireball.net/projects/markdown/syntax) text and toucan will generate HTML files out of it. Markdown files can have an additional metadata section, this is where you can specify the following attributes:

- `slug` - Slug of your content
- `title`: Title of your content
- `description` - Description of your content
- `date` - Date of your post (e.g. 2023/04/24)
- `tags` - Tags for your post, separated by a coma

The `index.md` file is a special content file, this is where you can set up the following things:

- `baseUrl` - Base URL of your site (e.g. `./`, `/`, `https://mywebsite.com`)
- `language` - Language of your site (e.g. en-US)
- `title` - title of your site
- `description` - Description of your site

The `404.md` file is useful if you want to deploy your site using GitHub pages with a [custom 404 page](https://docs.github.com/en/pages/getting-started-with-github-pages/creating-a-custom-404-page-for-your-github-pages-site).

## Summary

Toucan is a brand new project and we know it's far from perfect, but if you are looking for a simple solution to host static sites using [GitHub pages](https://pages.github.com) and you'd like to focus more on your content and less on the infrastructure it can be an ideal choice. Feel free to [contact us](https://github.com/BinaryBirds/Toucan/discussions/1) if you want to know more about it or submit an issue, maybe even a PR on GitHub. 😉
