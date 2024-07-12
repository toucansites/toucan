---
title: Commands
description: Commands
category: getting-started
order: 5
---

# Commands
---

Toucan includes three built-in subcommands to generate static sites: _generate_, _watch_, and _serve_. 

## Generate

The generate command creates distribution files from a source directory.

```sh
toucan generate ./src ./dist
```

## Watch

The watch command monitors a source directory for changes and automatically rebuilds the distribution files when changes occur in the source folder.

```sh
toucan watch ./src ./dist
``` 

## Serve

The serve command runs a web server to serve a source directory.

```sh
toucan serve ./dist -h localhost -p 3000
toucan serve ./dist --host localhost --port 3000
``` 

You can specify a hostname and port parameter to bind your web server to a given address. This allows you to preview your website at http://localhost:3000/.
