---
type: post
title: AJAX calls using Vapor 4
description: Learn how to implement Asynchronous JavaScript and XML (AJAX) calls using Leaf templates and Vapor 4 as a server.
publication: 2020-12-18 16:20:00
tags: 
    - vapor
    - server
authors:
    - tibor-bodecs
---

## What is AJAX?

Asynchronous JavaScript and XML ([AJAX](https://en.wikipedia.org/wiki/Ajax_(programming))) is a technology that allows us you to send HTTP requests to your web server from a web page. Based on the response you can use JavaScript to manipulate the HTML Document Object Model ([DOM](https://www.w3schools.com/whatis/whatis_htmldom.asp)). In short, with the help of AJAX, you can ask for some data, then you can update the contents of the web site based on that.

The good thing about AJAX is that you don't have to reload the entire page, but you can update just a portion of the site. The HTTP request will work on the background so from a user perspective the whole browsing experience will seem faster, than a full page load. ⌛️

### Frontend vs backend

[AJAX](https://www.w3schools.com/whatis/whatis_ajax.asp) is a frontend technology. It's a simple JavaScript function call, but some smart people gave it a fancy name. The X in the name comes from the early days of the web, when servers usually returned a "pre-rendered" partial HTML string that you could inject into the DOM without further data manipulation. Nowadays computers are so powerful that most of the servers can return JSON data and then the client can build the necessary HTML structure before the insertion.

In order to support AJAX calls on the server side we only have to implement the endpoint that the frontend can ask for. The communication is made through a standard HTTP call, so from a backend developer perspective we don't really have to put any extra effort to support AJAX calls. 💪

## Creating the server

Enough from the introduction, we now know what is AJAX and we are going to build a simple Vapor server to render our HTML document using Leaf Tau.

> NOTE: Tau was an experimental release, bit it was pulled from the final Leaf 4.0.0 release.

Tau will be available later on as a standalone repository with some new features, until that you can still use it if you pin the Leaf dependency to the exact release tag... 🤫

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

Open the project with Xcode and set a custom working directory for the executable target. First we are going to build a very simple `index.leaf` file, you should add it to the `Resources/Views` directory. If there is no such directory structure in your project yet, please create the necessary folders.

```html
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>AJAX example</title>
  </head>
  <body>
    <h1>AJAX example</h1>
    
    <button type="button" onclick="performAJAXCall()">Request data</button>

    <div id="container"></div>

    <script>
    function performAJAXCall() {
      var xhttp = new XMLHttpRequest();
      xhttp.onreadystatechange = function() {
          if (this.readyState == 4 && this.status == 200) {
            document.getElementById("container").innerHTML = this.responseText;
          }
      };
      xhttp.open("GET", "/ajax", true);
      xhttp.send();
    }
    </script>

  </body>
</html>
```

Now if you take a closer look at our `index.leaf` file, you should notice that this template is actually a perfectly valid HTML file. We don't need anything special in order to perform AJAX calls, but only a few lines of HTML and JavaScript code.

We can use a simple button and use the `onclick` attribute to call a JavaScript function, in our case this function is defined between the script tags and it is called performAJAXCall, but of course you can change this name to anything you'd like to use.

We create `XMLHttpRequest` object and set the `onreadystatechange` property to a custom anonymous function. This is the response handler, it will be called when the server returned a response. You should check both the readyState property of the `XMLHttpRequest` object and the returned status code if you only want to perform some operation when a valid response arrived and the operation finished. In our case, we are going to update our container with the response text.

The very last step is to call the open method using a HTTP method as the first parameter, a URL as a second, and make it asynchronous with a third (true) boolean value. This will initialize the request, so we still have to use the send() function to actually send it to our web server.

We actually need a working Vapor server that can render the index page when you enter the `http://localhost:8080/` address to your browser. We also have to setup a new `/ajax` path and return some string that our frontend JavaScript code can place into the container HTML element, here's one possible implementation of our backend application.

```swift
import Vapor
import Leaf

public func configure(_ app: Application) throws {

    /// setup Leaf template engine
    LeafRenderer.Option.caching = .bypass
    app.views.use(.leaf)

    /// index route
    app.get { req in
        req.leaf.render(template: "index")
    }
    
    /// simple ajax response
    app.get("ajax") { req in
        "<strong>Lorem ipsum dolor sit amet</strong>"
    }
}
```

This is a 100% complete AJAX example using Vanilla JS (JavaScript without additional frameworks). It should work in most of the [major browsers](https://caniuse.com/?search=XMLHttpRequest) and it's just about 10 lines of code. 💪

## AJAX vs AJAJ

Asynchronous JavaScript and JSON. Let's be honest, this is the real deal and in 99% of the cases this is what you actually want to implement. First we're going to alter our server and return a JSON response instead of the plain old HTML string. 🤮

```swift
import Vapor
import Leaf

struct Album: Content {
    let icon: String
    let name: String
    let artist: String
    let year: String
    let link: String
}

public func configure(_ app: Application) throws {

    /// setup Leaf template engine
    LeafRenderer.Option.caching = .bypass
    app.views.use(.leaf)

    /// index route
    app.get { req in
        req.leaf.render(template: "index")
    }

    /// pretty simple ajaj response
    app.get("ajaj") { req  in
        [
            Album(icon: "❤️", name: "Amo", artist: "Bring me the Horizon", year: "2019", link: "https://music.apple.com/hu/album/amo/1439239477"),
            Album(icon: "🔥", name: "Black Flame", artist: "Bury Tomorrow", year: "2018", link: "https://music.apple.com/hu/album/black-flame/1368696224"),
            Album(icon: "💎", name: "Pressure", artist: "Wage War", year: "2019", link: "https://music.apple.com/hu/album/pressure/1470142125"),
            Album(icon: "☀️", name: "When Legends Rise", artist: "Godsmack", year: "2018", link: "https://music.apple.com/hu/album/when-legends-rise/1440902339"),
            Album(icon: "🐘", name: "Eat the Elephant", artist: "A Perfect Circle", year: "2018", link: "https://music.apple.com/hu/album/eat-the-elephant/1340651075"),
        ]
    }
}
```

If you open the `http://localhost:8080/ajaj` URL you should see the returned JSON response. It is an array of the album objects, we are going to parse this JSON using JavaScript and display the results as a HTML structure.

```html
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>AJAX example</title>
    <style>
        .album {
            border: 1px solid gray;
            border-radius: 8px;
            margin: 16px;
            padding: 16px;
            text-align: center;
        }
    </style>
  </head>
  <body>
    <h1>AJAX example</h1>
    
    <button type="button" onclick="performAJAXCall()">Request data</button>

    <div id="container"></div>

    <script>
    function performAJAXCall() {
      var xhttp = new XMLHttpRequest();
      xhttp.onreadystatechange = function() {
          if (this.readyState == 4 && this.status == 200) {
              var html = '';
              var albums = JSON.parse(this.responseText);
              if ( Array.isArray(albums) ) {
                  albums.forEach(function(album, index) {
                      html += '<div class="album">'
                      html += '<h1>' + album.icon + '</h1>';
                      html += '<h2>' + album.name + '</h2>';
                      html += '<p>' + album.artist + '</p>';
                      html += '<a href="' + album.link + '" target="_blank">Listen now</a>'
                      html += '</div>'
                  });
              }
              document.getElementById("container").innerHTML = html;
          }
      };
      xhttp.open("GET", "/ajaj", true);
      xhttp.send();
    }
    </script>

  </body>
</html>
```

The `XMLHttpRequest` method remains the same, but now take advantage of the built-in `JSON.parse` JavaScript function. This can parse any JSON object and returns the parsed object. We should always check if the result is the right type that we want to work with (in our case we only accept an array). Then we can use the properties of the album objects to construct our HTML code.

I'm not doing further validations and type checking, but you should always ensure that objects are not nil or undefined values. Anyway, this example shows us how to perform an AJAJ call, parse the response JSON and display the result in a nice way. 😅
