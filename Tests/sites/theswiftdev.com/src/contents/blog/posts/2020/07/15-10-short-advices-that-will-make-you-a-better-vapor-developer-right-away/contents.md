---
slug: 10-short-advices-that-will-make-you-a-better-vapor-developer-right-away
title: 10 short advices that will make you a better Vapor developer right away
description: As a beginner server side Swift developer you'll face many obstackles. I'll show you how to avoid the most common ones.
publication: 2020-07-15 16:20:00
tags: Vapor
---

## Set a custom working directory in Xcode with just a few clicks

So you have your [very first Vapor project](https://theswiftdev.com/beginners-guide-to-server-side-swift-using-vapor-4/) up and running in Xcode, but for some strange reason Vapor can't read your local `.env` file, Leaf can't find the templates or maybe there is no `db.sqlite` file in the current project directory at all. You might ask the question:

> Why the hell is Xcode trying to look for my files in the DerivedData folder?

The answer is pretty simple, you can setup a custom working directory within Xcode, you just have to right click your target name and select the Edit Scheme... menu item. If you don't specify a custom working directory under the Run scheme options tab, Xcode will use the default location to look up user files, that's called the working directory and it's hidden under the DerivedData folder.

Tip #1: set up the working directory before you run the project, so you don't have to deal with the derived data issues anymore. Also if you remove the hidden `.swiftpm` folder from your project, you'll have to repeat the setup process again. 💪

## Always stop previous server instances to avoid address in use errors

If you hit the "address already used" message in the console that can only mean one thing: something blocks the port that your server is trying to use. You can always start the Activity Monitor application and search for the server (Run), or you can use the `lsof -i :8080 -sTCP:LISTEN` command to check the port, but nowadays I'm using a more practical approach to fix this issue.

I'm using a pre-actions run script as part of the scheme runner operation. You can open the same Edit Scheme... menu item and click a little arrow next to your scheme name, this will allow you to setup both pre and post-actions that can run before or after the actual run process. Now the trick is that I always try to kill the previous process using a pre-action script.

```sh
lsof -i :8080 -sTCP:LISTEN |awk 'NR > 1 {print $2}'|xargs kill -15
```

Tip #2: always kill the previous server instance before you build & run a new one using a pre-actions script, this will eliminate the address in use errors from your life forever. 😎

## Run the migration scripts automatically

One common mistake is that you forget to migrate the database before you run the project. This can be avoided if you call the `autoMigrate()` method in the configuration function, so the server can perform the necessary migrations before it starts to listen for incoming connections.

```swift
import Vapor
import Fluent
import FluentSQLiteDriver

public func configure(_ app: Application) throws {
    //...
    app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)
    try app.autoMigrate().wait()
}
```

Tip #3: don't forget to run your [Fluent](https://theswiftdev.com/get-started-with-the-fluent-orm-framework-in-vapor-4/) database migrations, you can simply automate by calling the `autoMigrate` method from Swift. Be careful, sometimes when you work in a production environment you don't want to run automatic migrations in every single case. 🙈

## Install the latest toolbox version with brew

We're in a transition period between Vapor 3 and Vapor 4, this was causing some trouble for many of my readers. There is a [command line utility](https://docs.vapor.codes/4.0/install/macos/) for Vapor, but the thing is that if are not using the latest version of it might generates a project based on an older (version 3) template. If you want to install a specific version of the Vapor toolbox you can do that by running the following commands:

```sh
git clone https://github.com/vapor/toolbox.git
cd toolbox
git checkout <desired version>
swift build -c release --disable-sandbox --enable-test-discovery
mv .build/release/vapor /usr/local/bin
```

Tip #4: always make sure that you are using the right version of the Vapor toolbox. 🔨

## Use .env files to safely store secrets

Never hardcode secrets or sensitive data into your Swift files. You can use environmental variables for this purpose, even better you can store your secrets in a file called `.env` so you don't have to export them always before you run the project. With a relatively easy trick you can also [store multiline strings in your .env](https://theswiftdev.com/how-to-store-keys-in-env-files/) file.

Tip #5: keep your secrets safe using `.env` files. Never commit them to the repository, you can use the `.gitignore` file to ignore them automatically. This way your secrets will be safe and you can run the app using various environments (development, production, testing, etc.).

## Learn the new command API, to build better tools

It is quite essential to run various scripts on the server side. Backend developers always create tools for common tasks, e.g. I have a script that can minify CSS files for me or another one for moving the views to the Resources folder, but there are many other things that you can use scripts for. Fortunately you don't have to learn bash anymore, but can write scripts using your favorite programming language: Swift. You can use [swift-sh](https://github.com/mxcl/swift-sh) or the official [Swift argument parser](https://github.com/apple/swift-argument-parser), but the best part of being a full-stack Swift developer is that [Vapor has such an amazing command API](https://theswiftdev.com/how-to-write-swift-scripts-using-the-new-command-api-in-vapor-4/).

Tip #6: learn the Vapor command API so you can create your own backend tools and scripts without learning anything about shell scripts, zsh or bash at all. 🐚

## Use https & letsencrypt for better security

If you have never heard about the [Let's Encrypt](https://letsencrypt.org/) service or you don't know what's the main [difference between HTTP and HTTPS](https://www.cloudflare.com/learning/ssl/why-is-http-not-secure/), you should definitely take a look at the linked pages. Virtual privacy, security is more important nowadays than it was ever before. 🛡

Tip #7: use HTTPS by default, don't risk giving out sensitive by data using unencrypted channels. Pro tip: you can test your server's certificate and configuration using the free [SSL Labs](https://www.ssllabs.com/ssltest/) testing tool.

## Use the SQLLite driver for rapid development

I already mentioned that it's good to automatically migrate your Fluent database during development, but what if you mess up something and you have to reset the entire database? Well you can perform a complete reset using both the PostgreSQL, MySQL or MongoDB drivers, but isn't it way more easy to delete just one single file?

Tip #8: if you don't have specific requirements or needs for a given database driver, just use the FluentSQLiteDriver for development purposes. You can iterate way faster, you can reset the db with just a few clicks and start over everything right ahead. 💡

## Always update your project to avoid bugs

Why the hell is my cookie parser broken? Why is this feature not working? Why is the server crashing? Well, sometimes things can go wrong, people make mistakes, but the good news is that team Vapor is doing an amazing job. This is an extremely friendly and helpful community (one of the best if it comes to Swift developers) you can always ask questions on the official [Discord server](https://discord.com/invite/vapor) (just look for the proper channel for your question), or file a bug report on the [GitHub repositories](https://github.com/vapor).

Tip #9: however, before you raise a new issue, you should try to update your Swift dependencies. Vapor related package releases are coming quite often so it is worth to start your day by hitting the File > Swift Packages > Update to Latest Package Versions button in Xcode. ✅

## Use nginx for faster performance

Nginx is an extremely fast easy to use HTTP & proxy server. Nginx can be used as a [proxy server](https://docs.vapor.codes/4.0/deploy/nginx/), this way it can forward the incoming traffic to your Vapor application. It can also help you as a load balancer, you can setup your HTTPS SSL certificate once using nginx, plus you can completely ditch the file middleware since nginx can server static content as well.

Tip #10: use nginx combined with your Vapor server if you want to achieve better safety, scalability and performance. By the way enabling HTTP/2 is just a few lines of configuration. 😉

## Conclusion

Becoming a full-stack Swift developer can be hard, but hopefully these tips will help you to overcome the initial difficulties. If you don't know where to start or what to do next, you should take a look at my recently released [Practical Server Side Swift book](https://gumroad.com/l/practical-server-side-swift). It was made for Vapor 4, it can help you to build modular and scalable web applications through a real-world example project.
