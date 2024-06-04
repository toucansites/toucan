---
slug: the-anatomy-of-vapor-commands
title: The anatomy of Vapor commands
description: Learn how to build and run your existing Vapor apps using various command line arguments, flags and environments.
publication: 2020-03-25 16:20:00
tags: Vapor
---

## The Vapor toolbox

The very first thing I want to show you (again) is the [Vapor toolbox](https://docs.vapor.codes/3.0/getting-started/toolbox/) command line application. It's a nice little convenient tool for initializing new Vapor applications from scratch. You can use it to build, run, update, test and even deploy (to Heroku) your project.

```sh
# create & run a new project
vapor new myProject
cd myProject
vapor build
vapor run
```

Personally I'm not using it too much, except when I create a new project. I'd love to generate additional "boilerplate" code for controllers, models using the toolbox, but unfortunately this feature is not implemented yet. The [loopback-cli](https://loopback.io/getting-started.html) is a great example tho... 🙏

You can run `vapor --help` to see all the available commands.

## Serve

Every server needs to listen for incoming requests on some port. The serve command starts the Vapor application and fires up the HTTP server. You can specify the hostname and the port using some additional flags. The bind flag combines the hostname and port flags into one, they both have short and long versions, feel free to pick your favorite command format. 😉

```sh
# by default Vapor runs the serve command
swift run Run

# the serve command starts the server
swift run Run serve
swift run Run serve --hostname "localhost" --port 8080
swift run Run serve -h "localhost" -p 8080
swift run Run serve --bind "localhost:8080"
swift run Run serve -b "localhost:8080"
```

You should know that this is the default command, so if you simply run your app without any arguments, the serve command will be executed behind the scenes. 💀

## Migrate

When you [work with databases using Fluent](https://theswiftdev.com/a-tutorial-for-beginners-about-the-fluent-postgresql-driver-in-vapor-4/), you need a schema first. You can only populate the database with actual data after the main structure exists. This process is called migration. You'll also have to migrate your database if you change something in your Fluent code (for example you introduce a new field for a model). You can perform a migration by running:

```sh
# run Fluent migrations
swift run Run migrate

# run migrations without the confirmation
swift run Run migrate --auto-migrate

# revert last migration
swift run Run migrate --revert
```

The cli will show you what needs to be done in order to keep your DB up-to-date. You can double check everything one more time before you proceed, or you can skip the entire confirmation dialog by using the `--auto-migrate` option. Be extremely careful with auto migrations! ⚠️

## Log levels

You might have noticed that there are a bunch of Vapor messages in your console. Well, the good news is that you can filter them by log level. There are two ways of doing this. The first option is to provide a `log` flag with one of the following values:

- trace
- debug
- info
- notice
- warning
- error
- critical

> WARN: The `--log` flag has no short variant, don't try to use `-l`.

If you want to trace, debug and info logs, you can run the app like this:

```sh
# set log level
swift run Run --log notice
```

The second option is to set a `LOG_LEVEL` variable before you run the app.

```sh
# set log level using a variable
LOG_LEVEL=notice swift run Run

# set log level using an exported environmental variable
export LOG_LEVEL=notice
swift run Run
# unset log level
unset LOG_LEVEL
```

The exported variable will be around until you close the terminal window or you remove it.

## Environment

Every Vapor application can run in development or production mode. The default mode is development, but you can explicitly set this using the command line:

```sh
# .env.development
DB_URL="postgres://myuser:mypass@localhost:5432/mydb"

# run in development mode using the .env.development file
swift run Run --env development
swift run Run -e dev

# .env
DB_URL="postgres://realuser:realpass@localhost:5432/realdb"

# run in production mode using the .env file
swift run Run --env production
swift run Run -e prod
```

> NOTE: It is possible to store environmental variables in a dot env file. The `.env.development` file will be loeaded in development mode and the `.env` file in production mode. You can also use the `.env.testing` file for the test environment.

You can also override environmental variables with a local variable, like the way we defined the `LOG_LEVEL` before. So let's say if you have a DB_URL in your production `.env` file, but you still want to use the dev database, you can run Vapor like this:

```sh
DB_URL="postgres://myuser:mypass@localhost:5432/mydb" swift run Run --env production
```
Environment variables are super cool, you should play around with them to get familiar.

## Routes

This is very handy command to quickly display all the connected endpoints that your app has.

```
# prints all the routes information
swift run Run routes

# +--------+----------------+
# | GET    | /              |
# +--------+----------------+
# | GET    | /hello/        |
# +--------+----------------+
# | GET    | /todos         |
# +--------+----------------+
# | POST   | /todos         |
# +--------+----------------+
# | DELETE | /todos/:todoID |
# +--------+----------------+
```

If you need more info about how routing works in Vapor 4, you should check the [official docs](https://docs.vapor.codes/4.0/routing/#viewing-routes).

## Boot

Honestly: I've never used the boot command before, but it's there. 🤷‍♂️

```sh
# boots the app providers & exists
swift run Run boot
```

Can somebody tell me a use case for this?

## Custom commands

It is possible to write your custom commands [using the brand new Command API](https://theswiftdev.com/how-to-write-swift-scripts-using-the-new-command-api-in-vapor-4/) in Vapor 4. If you are interested in writing Swift scripts, you should continue reading the linked article. 📚

There are lots of other Swift compiler flags (e.g. `-Xswiftc -g` to make `Backtrace.print()` work) that you can use during the build process. If you are interested in those please let me know and maybe I'll make an article about it in the not so distant future.

