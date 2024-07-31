---
type: post
slug: file-upload-api-server-in-vapor-4
title: File upload API server in Vapor 4
description: Learn how to build a very simple file upload API server using Vapor 4 and URLSession upload task on the client side.
publication: 2020-12-30 16:20:00
tags: Vapor
authors:
  - tibor-bodecs
---

## A simple file upload server written in Swift

For this simple file upload tutorial we'll only use the Vapor Swift package as a dependency. 📦

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
    ],
    targets: [
        .target(
            name: "App",
            dependencies: [
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

You can setup the project with the required files using the [Vapor toolbox](https://github.com/vapor/toolbox), alternatively you can create everything by hand using the Swift Package Manager, long story short, we just need a starter Vapor project without additional dependencies. Now if you open the Package.swift file using Xcode, we can setup our routes by altering the `configure.swift` file.

```swift
import Vapor

public func configure(_ app: Application) throws {

    /// enable file middleware
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    /// set max body size
    app.routes.defaultMaxBodySize = "10mb"

    /// setup the upload handler
    app.post("upload") { req -> EventLoopFuture<String> in
        let key = try req.query.get(String.self, at: "key")
        let path = req.application.directory.publicDirectory + key
        return req.body.collect()
            .unwrap(or: Abort(.noContent))
            .flatMap { req.fileio.writeFile($0, at: path) }
            .map { key }
    }
}
```

First we use the `FileMiddleware`, this will allow us to server files using the Public directory inside our project folder. If you don't have a directory named Public, please create one, since the file upload server will need that. Don't forget to give proper [file system permissions](https://en.wikipedia.org/wiki/File-system_permissions) if necessary, otherwise we won't be able to write our data inside the directory. 📁

The next thing that we set is the default maximum body size. This property can limit the amount of data that our server can accept, you don't really want to use this method for large files because uploaded files will be stored in the system memory before we write them to the disk.

If you want to upload large files to the server you should consider streaming the file instead of collecting the file data from the HTTP body. The streaming setup will require a bit more work, but it's not that complicated, if you are interested in that solution, you should read the [Files API](https://docs.vapor.codes/4.0/files/) and the [body streaming](https://docs.vapor.codes/4.0/routing/#body-streaming) section using official Vapor docs site.

This time we just want a dead simple file upload API endpoint, that collects the incoming data using the HTTP body into a byte buffer object, then we simply write this buffer using the fileio to the disk, using the given key from the URL query parameters. If everything was done without errors, we can return the key for the uploaded file.

File upload tasks using the URLSession API
The Foundation frameworks gives us a nice API layer for common networking tasks. We can use the URLSession uploadTask method to send a new URLRequest with a data object to a given server, but IMHO this API is quite strange, because the URLRequest object already has a httpBody property, but you have to explicitly pass a "from: Data?" argument when you construct the task. But why? 🤔

```swift
import Foundation

extension URLSession {

    func uploadTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionUploadTask {
        uploadTask(with: request, from: request.httpBody, completionHandler: completionHandler)
    }
}
```

Anyway, I made a little extension method, so when I create the URLRequest I can set the httpBody property of it and safely pass it before the completion block and use the contents as the from parameter. Very strange API design choice from Apple... 🤐

We can put this little snippet into a simple executable Swift package (or of course we can create an entire application) to test our upload server. In our case I'll place everything into a `main.swift` file.

```swift
import Foundation
import Dispatch

extension URLSession {

    func uploadTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionUploadTask {
        uploadTask(with: request, from: request.httpBody, completionHandler: completionHandler)
    }
}


let fileData = try Data(contentsOf: URL(fileURLWithPath: "/Users/[user]]/[file].png"))
var request = URLRequest(url: URL(string: "http://localhost:8080/upload?key=\(UUID().uuidString).png")!)
request.httpMethod = "POST"
request.httpBody = fileData

let task = URLSession.shared.uploadTask(with: request) { data, response, error in
    guard error == nil else {
        fatalError(error!.localizedDescription)
    }
    guard let response = response as? HTTPURLResponse else {
        fatalError("Invalid response")
    }
    guard response.statusCode == 200 else {
        fatalError("HTTP status error: \(response.statusCode)")
    }
    guard let data = data, let result = String(data: data, encoding: .utf8) else {
        fatalError("Invalid or missing HTTP data")
    }
    print(result)
    exit(0)
}

task.resume()
dispatchMain()
```

The above example uses the `Dispatch` framework to wait until the asynchronous file upload finishes. You should change the location (and the extension) of the file if necessary before you run this script. Since we defined the upload route as a POST endpoint, we have to set the `httpMethod` property to match this, also we store the file data in the httpBody variable before we create our task. The upload URL should contain a key, that the server can use as a name for the file. You can add more properties of course or use header values to check if the user has proper authorization to perform the upload operation. Then we call the upload task extension method on the shared URLSession property. The nice thing about uploadTask is that you can run them on the background if needed, this is quite handy if it comes to iOS development. 📱

Inside the completion handler we have to check for a few things. First of all if there was an error, the upload must have failed, so we call the fatalError method to break execution. If the response was not a valid HTTP response, or the status code was not ok (200) we also stop. Finally we want to retrieve the key from the response body so we check the data object and convert it to a UTF8 string if possible. Now we can use the key combined with the domain of the server to access the uploaded file, this time I just printed out the result, but hey, this is just a demo, in a real world application you might want to return a JSON response with additional data. 😅

## Vanilla JavaScript file uploader

One more thing... you can use Leaf and some Vanilla JavaScript to upload files using the newly created upload endpoint. Actually it's really easy to implement a new endpoint and render a Leaf template that does the magic. You'll need some basic HTML and a few lines of JS code to submit the contents of the file as an array buffer. This is a basic example.

```html
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>File upload</title>
  </head>
  <body>
      <h1>File upload</h1>
      <input type="file" id="file" name="file" accept="image/*" /><br><br>
      <img id="preview" src="https://theswiftdev.com/images/logos/logo.png" width="256px">
      <script>
        document.getElementById('file').addEventListener("change", uploadImage);

        function uploadImage() {
            var xhr = new XMLHttpRequest();
            xhr.open("POST", "/upload?key=test.png", true);
            xhr.onreadystatechange = function() {
                if(xhr.readyState == 4 && xhr.status == 200) {
                    document.getElementById('preview').src = "/" + this.responseText;
                }
            };

            var file = document.getElementById('file').files[0];
            if (file) {
                var reader = new FileReader();
                reader.onload = function() {
                    xhr.send(reader.result);
                }
                reader.readAsArrayBuffer(file);
            }
        }
      </script>
  </body>
</html>
```

As you can see it's a standard `XHR` request combined with the [FileReader](https://developer.mozilla.org/en-US/docs/Web/API/FileReader) JavaScript API. We use the FileReader to convert our input to a binary data, this way our server can write it to the file system in the expected format. In most cases people are using a multipart-encoded form to access files on the server, but when you have to work with an API you can also transfer raw file data. If you want to learn more about XHR requests and AJAX calls, you should read my previous [article](https://theswiftdev.com/ajax-calls-using-vapor-4/).

I also have a [post](https://theswiftdev.com/file-upload-using-vapor-4/) about different file upload methods using standard HTML forms and a Vapor 4 server as a backend. I hope you'll find the right solution that you need for your application. 👍
