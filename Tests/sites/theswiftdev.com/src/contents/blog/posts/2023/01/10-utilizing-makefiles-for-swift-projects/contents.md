---
slug: utilizing-makefiles-for-swift-projects
title: Utilizing Makefiles for Swift projects
description: In this tutorial I'll show you how to use Makefiles for server-side Swift projects to help running utility tasks in a more simple way.
publication: 2023-01-10 16:20:00
tags: Swift, Makefile
---

[Make](https://en.wikipedia.org/wiki/Make_(software)) is a build automation software that you can use to automatically run various commands. If you want to run something, you have to specify your commands (more precisely: build targets) through Makefiles. In this quick tutorial I'll show you some of my best practices for Swift projects. 😉

Usually I create a Makefile for my server-side Swift projects and place some of the most used [Swift Package Manager](https://theswiftdev.com/swift-package-manager-tutorial/) commands there.

```
# My Makefile - for server side Swift projects

build:
    swift build

update: 
    swift package update

release:
    swift build -c release
    
test:
    swift test --parallel

clean:
    rm -rf .build
```

This way, for example, I can simply run the make release command to create a release version of my Swift package. I usually end-up adding even more complex commands to the Makefile, another common scenario is, when the package has an executable target. I usually create an install and uninstall command to quickly setup or remove the binary product locally. 🏗️

```
install: release
    install ./.build/release/my-app /usr/local/bin/my-app

uninstall:
    rm /usr/local/bin/my-app
```

As you might know, nowadays I mostly create [Vapor-based apps](https://theswiftdev.gumroad.com/l/practical-server-side-swift) (or [Hummingbird](https://github.com/hummingbird-project/hummingbird), but that deserves a separate post), so it's really convenient to have a dedicated set of commands inside my Makefile to manage the state of the server application. 💧

```
start:
    my-app serve --port 8080 &
    
stop:
    @lsof -i :8080 -sTCP:LISTEN | awk 'NR > 1 {print $$2}' | xargs kill -15

restart: stop start

reset: stop
    rm -f ./Resources/db.sqlite
```

By using the & at the end of the start command the server will run in the background, and using the @ character before the lsof command will silence the output of the make command (By default the make command will echo out your commands as well).

Since everything should work under Linux as well I often use Docker to run the app in a container. I have [a Docker cheat-sheet](https://theswiftdev.com/server-side-swift-projects-inside-docker-using-vapor-4/), but I'm also a lazy developer, so I made a few helpers in the Makefile.

```
#
# Dockerfile:
# ----------------------------------------
#
# FROM swift:5.7-amazonlinux2
# 
# WORKDIR /my-app
#
# ----------------------------------------
#

docker-build-image:
    docker build -t my-app-image .

docker-run:
    docker run --name my-app-instance \
        -v $(PWD):/my-app \
        -w /my-app \
        -e "PS1=\u@\w: " \
        -it my-app-image \
        --rm
```

First you have to build the image for the Swift application, for this purpose you also have to create a Dockerfile next to the Makefile, but afterwards you can create a disposable docker instance from it by using the make docker-run command. 🐳

There are two more topics I'd like to talk about. The first one is related to [code coverage generation](https://theswiftdev.com/code-coverage-for-swift-package-manager-based-apps/) for Swift package manager based apps. Here is what I have in my Makefile to support this:

```
test-with-coverage:
    swift test --parallel --enable-code-coverage

# 
# Install dependencies (on macOS):
# ----------------------------------------
# brew install llvm
# echo 'export PATH="/usr/local/opt/llvm/bin:$PATH"' >> ~/.zshrc
# ----------------------------------------
# 
code-coverage: test-with-coverage
    llvm-cov report \
        .build/x86_64-apple-macosx/debug/myAppPackageTests.xctest/Contents/MacOS/myAppPackageTests \
        -instr-profile=.build/x86_64-apple-macosx/debug/codecov/default.profdata \
        -ignore-filename-regex=".build|Tests" \
        -use-color
```

You can easily generate code coverage data by running the make code-coverage command. If you want to know more about the underlying details, please refer to the linked article.

The very last thing is going to be about documentation. Apple released [DocC](https://github.com/apple/swift-docc) for Swift quite a long time ago and now it seems like a lot of people are using it. Initially I was not a huge fan of DocC, but now I am for sure. It is possible to simplify the doc generation process through Makefiles and I tend to run the make docs-preview command quite often to have a quick sneak peak of the API. 🔨

```
docs-preview:
    swift package --disable-sandbox preview-documentation --target MyLibrary

docs-generate:
    swift package generate-documentation \
        --target MyLibrary

docs-generate-static:
    swift package --disable-sandbox \
        generate-documentation \
        --transform-for-static-hosting \
        --hosting-base-path "MyLibrary" \
        --target MyLibrary \
        --output-path ./docs
```

Of course you can add more targets to your Makefile to automate your workflow as needed. These are just a few common practices that I'm currently using for my server-side Swift projects. iOS developers can also take advantage of Makefiles, there are some quite lenghty [xcodebuild related commands](https://theswiftdev.com/deep-dive-into-swift-frameworks/) that you can simplify a lot by using a Makefile. 💪
