---
type: post
slug: server-side-swift-projects-inside-docker-using-vapor-4
title: Server side Swift projects inside Docker using Vapor 4
description: Learn how to setup Vapor 4 projects inside a Docker container. Are you completely new to Docker? This article is just for you.
publication: 2020-04-19 16:20:00
tags: Vapor, Docker
authors:
  - tibor-bodecs
---

## What the heck is Docker?

Operating-system-level virtualization is called containerization technology. It's more lightweight than virtual machines, since all the containers are run by a single operating system kernel.

[Docker](https://www.docker.com/) used to run software packages in these self-contained isolated environments. These containers bundle their own tools, libraries and configuration files. They can communicate with each other through well-defined channels. Containers are being made from images that specify their precise contents. You can find plenty of Docker images on [DockerHub](https://hub.docker.com/).

Docker is extremely useful if you don't want to spend hours to setup & configure your work environment. It helps the software deployment process, so patches, hotfixes and new code releases can be delivered more frequently. In other words it's a [DevOps](https://en.wikipedia.org/wiki/DevOps) tool.

> NOTE: Guess what: you can use Swift right ahead through a single Docker container, you don't even need to install anything else on your computer, but Docker. 🐳

## Docker architecture in a nutshell

There is a nice get to know post about [the Docker ecosystem](https://nickjanetakis.com/blog/get-to-know-dockers-ecosystem), but if you want to get a detailed overview you should read the Docker [glossary](https://docs.docker.com/glossary/). In this tutorial I'm going to focus on images and containers. Maybe a little bit on the hub, engine & machines. 😅

### Docker engine

Lightweight and powerful open source containerization technology combined with a work flow for building and containerizing your applications.

### Docker image

Docker [images](http://www.projectatomic.io/blog/2015/07/what-are-docker-none-none-images/) are the basis (templates) of containers.

### Docker container

A container is a runtime instance of a docker image.

### Docker machine

A tool that lets you install Docker Engine on virtual hosts, and manage the hosts with docker-machine commands.

### Docker hub
A centralized resource for working with Docker and its components.

So just a little clarification: Docker images can be created through Dockerfiles, these are the templates for running containers. Imagine them like "pre-built install disks" for your container environments. If we approach this from an object-oriented programming perspective, then an image is a class definition and the container is the instance created from it. 💾

## How to run Swift in a Docker container?

Let me show you how to run Swift under Linux inside a [Docker](https://forums.swift.org/t/kickstarting-new-official-docker-support-for-swift/15487) container. First of all, install Docker (fastest way is `brew install docker`), start the app itself (give it some permissions), and pull the official Swift Docker image from the cloud by using the `docker pull swift` command. 😎

> NOTE: You can also use the official [Vapor Docker images](https://github.com/vapor/docker) for server side Swift development.

### Packaging Swift code into an image

The first thing I'd like to teach you is how to create a custom Docker image & pack all your Swift source code into it. Just create a new Swift project `swift package init --type=executable` inside a folder and also make a new `Dockerfile`:

```
FROM swift
WORKDIR /app
COPY . ./
CMD swift package clean
CMD swift run
```

The FROM directive tells Docker to set our base image, which will be the previously pulled official Swift Docker image with some minor changes. Let's make those changes right ahead! We're going to add a new WORKDIR that's called /app, and from now on we'll literally work inside that. The COPY command will copy our local files to the remote (working) directory, CMD will run the given command if you don't specify an external command e.g. run shell. 🐚

Please note that we could use the [ADD](https://nickjanetakis.com/blog/docker-tip-2-the-difference-between-copy-and-add-in-a-dockerile) instruction instead of COPY or the [RUN](http://goinbigdata.com/docker-run-vs-cmd-vs-entrypoint/) instuction instead of CMD, but there are slight differneces (see the links).

Now build, tag & finally run the image. 🔨

```sh
# build the image
docker build -t my-swift-image .

# run the container based on the image and remove it after exit
docker run --rm my-swift-image
```

Congratulations, you just made your first Docker image, used your first Docker container with Swift, but wait... is it necessary to re-build every time a code change happens? 🤔

## Editing Swift code inside a Docker container on-the-fly

The first option is that you execute a bash `docker run -it my-swift-image` bash and log in to your container so you'll be able to edit Swift source files inside of it & build the whole package by using `swift build` or you can run `swift test` if you'd just like to test your app under [Linux](https://oleb.net/blog/2017/03/testing-swift-packages-on-linux/).

This method is a little bit inconvenient, because all the Swift files are copied during the image build process so if you would like to pull out changes from the container you have to manually copy everything, also you can't use your favorite editor inside a terminal window. 🤐

Second option is to run the original Swift image, instead of our custom one and attach a local directory to it. Imagine that the sources are under the current directory, so you can use:

```sh
docker run --rm -v $(pwd):/app -it swift
```

This command will start a new container with the local folder mapped to the remote app directory. Now you can use Xcode or anything else to make modifications, and run your Swift package, by entering `swift run` to the command line. Pretty simple. 🏃

## How to run a Vapor 4 project using Docker?

You can run a server side Swift application through [Docker](https://bygri.github.io/2018/05/14/developing-deploying-vapor-docker.html). If reate a new Vapor 4 project using the toolbox (vapor new myProject), the generated project will also include both a `Dockerfile` and a `docker-compose.yml` file, those are pretty good starting points, let's take a look at them.

```sh
# Build image
FROM vapor/swift:5.2 as build
WORKDIR /build
COPY ./Package.* ./
RUN swift package resolve
COPY . .
RUN swift build --enable-test-discovery -c release -Xswiftc -g

# Run image
FROM vapor/ubuntu:18.04
WORKDIR /run
COPY --from=build /build/.build/release /run
COPY --from=build /usr/lib/swift/ /usr/lib/swift/
COPY --from=build /build/Public /run/Public
ENTRYPOINT ["./Run"]
CMD ["serve", "--env", "production", "--hostname", "0.0.0.0"]
```

The Dockerfile separates the build and run process into two distinct images, which totally makes sense since the final product is a binary executable file (with additional resources), so you won't need the Swift compiler at all in the run image, this makes it extremely lightweight. 🐋

```sh
docker build -t vapor-image .

# simply run the container instance & bind the port
docker run --name vapor-server -p 8080:8080 vapor-image

# run the instance, bind the port, see logs remove after exit (CTRL+C)
docker run --rm -p 8080:8080 -it vapor-image
```

Building and running the image is pretty straightforward, we use the `-p` parameter to map the port inside the container to our local port. This will allow the Docker container to "listen on the given port" and if you visit the `http://localhost:8080` you should see the proper response generated by the server. Vapor is running inside a container and it works like magic! ⭐️

## Using Fluent in a separate Docker container

The docker-compose command can be used to start multiple docker containers at once. You can have separate containers for every single service, like your Swift application, or the database that you are going to use. You can deploy & start all of your microservices with just one command. 🤓

As I mentioned before, the starter template comes with a compose file somewhat like this:

```
version: '3.7'

volumes:
  db_data:

x-shared_environment: &shared_environment
  LOG_LEVEL: ${LOG_LEVEL:-debug}
  DATABASE_HOST: db
  DATABASE_NAME: vapor_database
  DATABASE_USERNAME: vapor_username
  DATABASE_PASSWORD: vapor_password

services:
  app:
    image: dockerproject:latest
    build:
      context: .
    environment:
      <<: *shared_environment
    depends_on:
      - db
    ports:
      - '8080:80'
    command: ["serve", "--env", "production", "--hostname", "0.0.0.0", "--port", "80"]
  migrate:
    image: dockerproject:latest
    build:
      context: .
    environment:
      <<: *shared_environment
    depends_on:
      - db
    command: ["migrate", "--yes"]
    deploy:
      replicas: 0
  revert:
    image: dockerproject:latest
    build:
      context: .
    environment:
      <<: *shared_environment
    depends_on:
      - db
    command: ["migrate", "--revert", "--yes"]
    deploy:
      replicas: 0
  db:
    image: postgres:12.1-alpine
    volumes:
      - db_data:/var/lib/postgresql/data/pgdata
    environment:
      PGDATA: /var/lib/postgresql/data/pgdata
      POSTGRES_USER: vapor_username
      POSTGRES_PASSWORD: vapor_password
      POSTGRES_DB: vapor_database
    ports:
      - '5432:5432'
```

The main thing to remember here is that you should NEVER `run docker-compose up`, because it'll run every single container defined in the compose file including the app, db, migrations and revert. You don't really want that, instead you can use individual components by providing the identifier after the up argument. Again, here are your options:

```sh
# Build images:
docker-compose build

# Run app
docker-compose up app
# Run database
docker-compose up db
# Run migrations:
docker-compose up migrate

# Stop all:
docker-compose down
# Stop & wipe database
docker-compose down -v
```

You should always start with the database container, since the server requires a working database instance. Despite fact that the `docker-compose` command can [manage dependencies](https://docs.docker.com/compose/compose-file/#devices), still you won't be able to automate the startup process completely, because the PostgreSQL database service needs just a little extra time to boot up. In a production environment you could solve this issue by using [health checks](https://docs.docker.com/compose/startup-order/). Honestly I've never tried this, feel free to tell me your story. 😜

Anyway, as you can see the `docker-compose.yaml` file contains all the necessary configuration. Under each key there is a specific [Vapor command](https://theswiftdev.com/the-anatomy-of-vapor-commands/) that Docker will execute during the container initialization process. You can also see that there is a shared environment section for all the apps where you can change the configuration or introduce a new environmental variable according to your needs. Environment variables will be passed to the images (you can [reach out to other containers](https://docs.docker.com/compose/networking/) by using the service names) and the API service will be exposed on port 8080. You can even add your own custom command by following the exact same pattern. 🌍

Ready? Just fire up a terminal window and enter `docker-compose up db` to [start the PostgreSQL database](https://theswiftdev.com/how-to-set-up-pgsql-for-fluent-4/) container. Now you can run both the migration and the app container at once by executing the `docker-compose up migrate app` command in a new terminal tab or window.

If you visit `http://localhost:8080` after everything is up and running you'll see that the server is listening on the given port and it is communicating with the database server inside another container. You can also "get into the containers" - if you want to run a special script - by executing `docker exec -it bash`. This is pretty cool, isn't it? 🐳 +🐘 +💧 = ❤️

## Docker cheatsheet for beginners

If you want to learn [Docker commands](https://github.com/wsargent/docker-cheat-sheet), but you don't know where to start here is a nice list of cli commands that I use to manage containers, images and many more using Docker from terminal. Don't worry you don't have to remember any of these commands, you can simply bookmark this page and everything will be just a click away. Enjoy! 😉

### Docker machine commands

- Create new: `docker-machine create MACHINE`
- List all: `docker-machine ls`
- Show env: `docker-machine env default`
- Use: `eval "$(docker-machine env default)"`
- Unset: `docker-machine env -u`
- Unset: `eval $(docker-machine env -u)`

### Docker image commands

- Download: `docker pull IMAGE[:TAG]`
- Build from local Dockerfile: `docker build -t TAG .`
- Build with user and tag: `docker build -t USER/IMAGE:TAG .`
- List: `docker image ls or docker images`
- List all: `docker image ls -a` or `docker images -a`
- Remove (image or tag): `docker image rm IMAGE or docker rmi IMAGE`
- Remove all [dangling](http://www.projectatomic.io/blog/2015/07/what-are-docker-none-none-images/) (nameless): `docker image prune`
- Remove all unused: `docker image prune -a`
- Remove all: `docker rmi $(docker images -aq)`
- Tag: `docker tag IMAGE TAG`
- Save to file: `docker save IMAGE > FILE`
- Load from file: `docker load -i FILE`

### Docker container commands

- Run from image: `docker run IMAGE`
- Run with name: `docker run --name NAME IMAGE`
- Map a port: `docker run -p HOST:CONTAINER IMAGE`
- Map all ports: `docker run -P IMAGE`
- Start in background: `docker run -d IMAGE`
- Set hostname: `docker run --hostname NAME IMAGE`
- Set domain: `docker run --add-host HOSTNAME:IP IMAGE`
- Map local directory: `docker run -v HOST:TARGET IMAGE`
- Change entrypoint: `docker run -it --entrypoint NAME IMAGE`
- List running: `docker ps` or `docker container ls`
- List all: `docker ps -a` or `docker container ls -a`
- Stop: docker stop ID or `docker container stop ID`
- Start: `docker start ID`
- Stop all: `docker stop $(docker ps -aq)`
- Kill (force stop): `docker kill ID` or `docker container kill ID`
- Remove: `docker rm ID` or `docker container rm ID`
- Remove running: `docker rm -f ID`
- Remove all stopped: `docker container prune`
- Remove all: `docker rm $(docker ps -aq)`
- Rename: `docker rename OLD NEW`
- Create image from container: `docker commit ID`
- Show modified files: `docker diff ID`
- Show mapped ports: `docker port ID`
- Copy from container: `docker cp ID:SOURCE TARGET`
- Copy to container: `docker cp TARGET ID:SOURCE`
- Show logs: `docker logs ID`
- Show processes: `docker top ID`
- Start shell: `docker exec -it ID bash`

### Other useful Docker commands

- Log in: `docker login`
- Run compose file: `docker-compose`
- Get info about image: `docker inspect IMAGE`
- Show stats of running containers: `docker stats`
- Show version: `docker version`

