# Toucan

Toucan is a markdown-based Static Site Generator (SSG) written in Swift.

## Prerequisite
Ensure you have `Swift` installed. For instructions check [how to install swift](https://www.swift.org/install/)

## Install

Clone or download the repository & run:

```shell
# clone the repository & install toucan
git clone https://github.com/toucansites/toucan.git
cd toucan
make install
# alternatively, if you encounter permission errors:
# sudo !!
# verify installation
which toucan
```

## Available commands

### generate

This command will generate all the static files, based on a source & destination directory, it is possible to override the base url via an optional parameter. 

```shell
toucan generate ./src ./docs --base-url http://localhost:3000/
```

### watch

Watch the source folder to any changes, to automatically re-generate the site.

```shell
toucan watch ./src ./docs --base-url http://localhost:3000/
```

NOTE: version 1.0.0-beta.2 watch command only supports macOS, Linux support is coming soon.

### serve

Serves a given folder using an optional port number. Your site will be available under `http://localhost:3000/`, if you run like this:

```shell
toucan serve ./docs -p 3000
```
