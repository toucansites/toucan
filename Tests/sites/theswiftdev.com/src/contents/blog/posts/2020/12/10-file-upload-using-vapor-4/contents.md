---
slug: file-upload-using-vapor-4
title: File upload using Vapor 4
description: Learn how to implement a basic HTML file upload form using the Leaf template engine and Vapor, all written in Swift of course.
publication: 2020-12-10 16:20:00
tags: Vapor
---

## Building a file upload form

Let's start with a basic Vapor project, we're going to use Leaf (the Tau release) for rendering our HTML files. You should note that Tau was an experimental release, the changes were reverted from the final 4.0.0 Leaf release, but you can still use Tau if you pin the exact version in your manifest file. Tau will be published later on in a standalone repository... 🤫

```swift
// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "myProject",
    platforms: [
       .macOS(.v10_15)
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor", from: "4.35.0"),
        .package(url: "https://github.com/vapor/leaf", .exact("4.0.0-tau.1")),
        .package(url: "https://github.com/vapor/leaf-kit", .exact("1.0.0-tau.1.1")),
    ],
    targets: [
        .target(
            name: "App",
            dependencies: [
                .product(name: "Leaf", package: "leaf"),
                .product(name: "LeafKit", package: "leaf-kit"),
                .product(name: "Vapor", package: "vapor"),
            ],
            swiftSettings: [
                .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release))
            ]
        ),
        .target(name: "Run", dependencies: [.target(name: "App")]),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "App"),
            .product(name: "XCTVapor", package: "vapor"),
        ])
    ]
)
```

Now if you open the project with Xcode, don't forget to setup a custom working directory first, because we're going to create templates and Leaf will look for those view files under the current working directory by default. We are going to build a very simple `index.leaf` file, you can place it into the `Resources/Views` directory.

```html
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>File upload example</title>
  </head>
  <body>
    <h1>File upload example</h1>

    <form action="/upload" method="post" enctype="multipart/form-data">
        <input type="file" name="file"><br><br>
        <input type="submit" value="Submit">
    </form>
  </body>
</html>
```

As you can see, it's a standard file upload form, when you want to upload files using the browser you always have to use the `multipart/form-data` encryption type. The browser will pack every field in the form (including the file data with the original file name and some meta info) using a special format and the server application can parse the contents of this. Fortunately Vapor has built-in support for easy decoding multipart form data values. We are going to use the POST /upload route to save the file, let's setup the router first so we can render our main page and we are going to prepare our upload path as well, but we will respond with a dummy message for now.

```swift
import Vapor
import Leaf

public func configure(_ app: Application) throws {

    /// config max upload file size
    app.routes.defaultMaxBodySize = "10mb"
    
    /// setup public file middleware (for hosting our uploaded files)
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    /// setup Leaf template engine
    LeafRenderer.Option.caching = .bypass
    app.views.use(.leaf)

    /// index route
    app.get { req in
        req.leaf.render(template: "index")
    }
    
    /// upload handler
    app.post("upload") { req in
        "Upload file..."
    }
}
```

You can put the snippet above into your configure.swift file then you can try to build and run your server and visit `http://localhost:8080`, then try to upload any file. It won't actually upload the file, but at least we are prepared to write our server side Swift code to process the incoming form data. ⬆️

## File upload handler in Vapor

Now that we have a working uploader form we should parse the incoming data, get the contents of the file and place it under our Public directory. You can actually move the file anywhere on your server, but for this example we are going to use the Public directory so we can simply test if everthing works by using the `FileMiddleware`. If you don't know, the file middleware serves everything (publicly available) that is located inside your Public folder. Let's code.

```swift
app.post("upload") { req -> EventLoopFuture<String> in
    struct Input: Content {
        var file: File
    }
    let input = try req.content.decode(Input.self)
    
    let path = app.directory.publicDirectory + input.file.filename
    
    return req.application.fileio.openFile(path: path,
                                           mode: .write,
                                           flags: .allowFileCreation(posixMode: 0x744),
                                           eventLoop: req.eventLoop)
        .flatMap { handle in
            req.application.fileio.write(fileHandle: handle,
                                         buffer: input.file.data,
                                         eventLoop: req.eventLoop)
                .flatMapThrowing { _ in
                    try handle.close()
                    return input.file.filename
                }
        }
}
```

So, let me explain what just happened here. First we define a new Input type that will contain our file data. There is a File type in Vapor that helps us decoding multipart file upload forms. We can use the content of the request and decode this type. We gave the file name to the file input form previously in our leaf template, but of course you can change it, but if you do so you also have to align the property name inside the Input struct.

After we have an input (please note that we don't validate the submitted request yet) we can start uploading our file. We ask for the location of the public directory, we append the incoming file name (to keep the original name, but you can generate a new name for the uploaded file as well) and we use the non-blocking file I/O API to create a file handler and write the contents of the file into the disk. The fileio API is part of [SwiftNIO](https://github.com/apple/swift-nio), which is great because it's a non-blocking API, so our server will be more performant if we use this instead of the regular `FileManager` from the Foundation framework. After we opened the file, we write the file data (which is a `ByteBuffer` object, bad naming...) and finally we close the opened file handler and return the uploaded file name as a future string. If you haven't heard about futures and promises you should read about them, because they are everywhere on the server side Swift world. Can't wait for async / awake support, right? 😅

We will enhance the upload result page just a little bit. Create a new `result.leaf` file inside the views directory.

```html
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>File uploaded</title>
  </head>
  <body>
    <h1>File uploaded</h1>

    #if(isImage):
        <img src="#(fileUrl)" width="256px"><br><br>
    #else:
    <a href="#(fileUrl)" target="_blank">Show me!</a><br><br>
    #endif
    
    <a href="/">Upload new one</a>
  </body>
</html>
```

So we're going to check if the uploaded file has an image extension and pass an `isImage` parameter to the template engine, so we can display it if we can assume that the file is an image, otherwise we're going to render a simple link to view the file. Inside the post upload handler method we are going to add a date prefix to the uploaded file so we will be able to upload multiple files even with the same name.

```swift
app.post("upload") { req -> EventLoopFuture<View> in
    struct Input: Content {
        var file: File
    }
    let input = try req.content.decode(Input.self)

    guard input.file.data.readableBytes > 0 else {
        throw Abort(.badRequest)
    }

    let formatter = DateFormatter()
    formatter.dateFormat = "y-m-d-HH-MM-SS-"
    let prefix = formatter.string(from: .init())
    let fileName = prefix + input.file.filename
    let path = app.directory.publicDirectory + fileName
    let isImage = ["png", "jpeg", "jpg", "gif"].contains(input.file.extension?.lowercased())

    return req.application.fileio.openFile(path: path,
                                           mode: .write,
                                           flags: .allowFileCreation(posixMode: 0x744),
                                           eventLoop: req.eventLoop)
        .flatMap { handle in
            req.application.fileio.write(fileHandle: handle,
                                         buffer: input.file.data,
                                         eventLoop: req.eventLoop)
                .flatMapThrowing { _ in
                    try handle.close()
                }
                .flatMap {
                    req.leaf.render(template: "result", context: [
                        "fileUrl": .string(fileName),
                        "isImage": .bool(isImage),
                    ])
                }
        }
}
```

If you run this example you should be able to view the image or the file straight from the result page.

## Multiple file upload using Vapor

By the way, you can also upload multiple files at once if you add the multiple attribute to the HTML file input field and use the `files[]` value as name.

```html
<input type="file" name="files[]" multiple><br><br>
```

To support this we have to alter our upload method, don't worry it's not that complicated as it looks at first sight. 😜

```swift
app.post("upload") { req -> EventLoopFuture<View> in
    struct Input: Content {
        var files: [File]
    }
    let input = try req.content.decode(Input.self)

    let formatter = DateFormatter()
    formatter.dateFormat = "y-m-d-HH-MM-SS-"
    let prefix = formatter.string(from: .init())
    
    struct UploadedFile: LeafDataRepresentable {
        let url: String
        let isImage: Bool
        
        var leafData: LeafData {
            .dictionary([
                "url": url,
                "isImage": isImage,
            ])
        }
    }
    
    let uploadFutures = input.files
        .filter { $0.data.readableBytes > 0 }
        .map { file -> EventLoopFuture<UploadedFile> in
            let fileName = prefix + file.filename
            let path = app.directory.publicDirectory + fileName
            let isImage = ["png", "jpeg", "jpg", "gif"].contains(file.extension?.lowercased())
            
            return req.application.fileio.openFile(path: path,
                                                   mode: .write,
                                                   flags: .allowFileCreation(posixMode: 0x744),
                                                   eventLoop: req.eventLoop)
                .flatMap { handle in
                    req.application.fileio.write(fileHandle: handle,
                                                 buffer: file.data,
                                                 eventLoop: req.eventLoop)
                        .flatMapThrowing { _ in
                            try handle.close()
                            return UploadedFile(url: fileName, isImage: isImage)
                        }
                    
                }
        }

    return req.eventLoop.flatten(uploadFutures).flatMap { files in
        req.leaf.render(template: "result", context: [
            "files": .array(files.map(\.leafData))
        ])
    }
}
```

The trick is that we have to parse the input as an array of files and turn every possible upload into a future upload operation. We can filter the upload candidates by readable byte size, then we map the files into futures and return an `UploadedFile` result with the proper file URL and is image flag. This structure is a LeafDataRepresentable object, because we want to pass it as a context variable to our result template. We also have to change that view once again.

```html
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Files uploaded</title>
  </head>
  <body>
    <h1>Files uploaded</h1>

    #for(file in files):
        #if(file.isImage):
        <img src="#(file.url)" width="256px"><br><br>
        #else:
        <a href="#(file.url)" target="_blank">#(file.url)</a><br><br>
        #endif
    #endfor
    
    <a href="/">Upload new files</a>
  </body>
</html>
```

Well, I know this is a dead simple implementation, but it's great if you want to practice or learn how to implement file uploads using server side Swift and the Vapor framework. You can also upload files directly to a cloud service using this technique, there is a library called Liquid, which is similar to Fluent, but for file storages. Currently you can use [Liquid](https://github.com/binarybirds/liquid/) to upload files to the [local storage](https://github.com/binarybirds/liquid-local-driver) or you can use an [AWS S3](https://github.com/BinaryBirds/liquid-aws-s3-driver) bucket or you can write your own driver using [LiquidKit](https://github.com/BinaryBirds/liquid-kit). The API is pretty simple to use, after you configure the driver you can upload files with just a few lines of code.
