# Toucan

Toucan is a markdown-based Static Site Generator (SSG) written in Swift.

## Installation

## Compile from source

Make sure you have Swift 6+ installed. See [how to install swift](https://www.swift.org/install/) for instructions.

To build Toucan from source, run the following commands:

```shell
# clone the Toucan repository
git clone https://github.com/toucansites/toucan.git
cd toucan

# install Toucan on your system under /usr/local/bin
make install
# enter your password, if needed

# verify
which toucan
# should return /usr/local/bin/toucan

# uninstall, remove Toucan from your system
make uninstall
# enter your password, if needed
```

## Quickstart

To quickly bootstrap a Toucan-based static site, run the following commands:

```shell
toucan init my-site
cd my-site
toucan generate
toucan serve
# Visit: http://localhost:3000
```

## Documentation

The complete documentation for Toucan is available on [toucansites.com](https://toucansites.com/docs/).
