---
slug: websockets-for-beginners-using-vapor-4-and-vanilla-javascript
title: Websockets for beginners using Vapor 4 and Vanilla JavaScript
description: Learn how to create a websocket server using Swift & Vapor. Multiplayer game development using JavaScript in the browser.
publication: 2020-05-28 16:20:00
tags: Vapor, websocket
---

## What the heck is a websocket?

The HTTP protocol is a fundamental building block of the internet, you can use a browser to request a website using a request-response based communication model. The web browser submits a HTTP request to the server, then the server responds with a response. The response contains status information, content related headers and the message body. In most cases after you receive some kind of response the connection will be closed. End of story.

The communication model described above can be ideal for most of the websites, but what happens when you would like to constantly transmit data over the network? Just think about real-time web applications or games, they need a constant data flow between the server and the client. Initiating a connection is quite an expensive task, you could keep the connection alive with some hacky tricks, but fortunately there is a better approach. 🍀

The [Websocket](https://en.wikipedia.org/wiki/WebSocket) communication model allows us to continuously send and receive messages in both direction (full-duplex) over a single TCP connection. A socket can be used to communicate between two different processes on different machines using standard file descriptors. This way we can have a dedicated channel to a given server through a socket and use that channel any time to deliver or receive messages instead of using requests & responses.

Websockets can be used to notify the client if something happens on the server, this comes handy in many cases. If you want to build a communication heavy application such as a messenger or a multiplayer game you should definitely consider using this kind of technology.

## Websockets in Vapor 4

Vapor 4 comes with built-in websockets support without additional dependencies. The underlying SwiftNIO framework provides the functionality, so we can hook up a websocket service into our backend app with just a few lines of Swift code. You can check the [official documentation](http://docs.vapor.codes/4.0/websockets/) for the available websocket API methods, it is pretty straightforward. 💧

In this tutorial we are going to build a massively multiplayer online [tag game](https://en.wikipedia.org/wiki/Tag_(game)) using websockets. Start a new project using the `vapor new myProject` command, we don't need a database driver this time. Delete the `routes.swift` file and the `Controllers` folder. Feel free to clean up the configuration method, we don't need to have anything there just yet.

The very first thing that we want to achieve is an identification system for the websocket clients. We have to uniquely identify each client so we can send messages back to them. You should create a `Websocket` folder and add a new `WebsocketClient.swift` file inside of it.

```swift
import Vapor

open class WebSocketClient {
    open var id: UUID
    open var socket: WebSocket

    public init(id: UUID, socket: WebSocket) {
        self.id = id
        self.socket = socket
    }
}
```

We are going to store all the connected websocket clients and associate every single one with a unique identifier. The unique identifier will come from the client, but of course in a real world server you might want to ensure the uniqueness on the server side by using some kind of generator.

The next step is to provide a storage for all the connected clients. We are going to build a new `WebsocketClients` class for this purpose. This will allow us to add, remove or quickly find a given client based on the unique identifier. 🔍

```swift
import Vapor

open class WebsocketClients {
    var eventLoop: EventLoop
    var storage: [UUID: WebSocketClient]
    
    var active: [WebSocketClient] {
        self.storage.values.filter { !$0.socket.isClosed }
    }

    init(eventLoop: EventLoop, clients: [UUID: WebSocketClient] = [:]) {
        self.eventLoop = eventLoop
        self.storage = clients
    }
    
    func add(_ client: WebSocketClient) {
        self.storage[client.id] = client
    }

    func remove(_ client: WebSocketClient) {
        self.storage[client.id] = nil
    }
    
    func find(_ uuid: UUID) -> WebSocketClient? {
        self.storage[uuid]
    }

    deinit {
        let futures = self.storage.values.map { $0.socket.close() }
        try! self.eventLoop.flatten(futures).wait()
    }
}
```

We are using the `EventLoop` object to close every socket connection when we don't need them anymore. Closing a socket is an async operation that's why we have to flatten the futures and wait before all of them are closed.

Clients can send any kind of data (`ByteBuffer`) or text to the server, but it would be real nice to work with JSON objects, plus if they could provide the associated unique identifier right next to the incoming message that would have other benefits.

To make this happen we will create a generic `WebsocketMessage` object. There is a [hacky solution](https://github.com/BastianInuk/DrinkServer/blob/master/Sources/App/Controllers/MachineController.swift) to decode incoming messages from JSON data. [Bastian Inuk](https://x.com/BastianInuk/) showed me this one, but I believe it is pretty simple & works like a charm. Thanks for letting me borrow your idea. 😉

```swift
import Vapor

struct WebsocketMessage<T: Codable>: Codable {
    let client: UUID
    let data: T
}

extension ByteBuffer {
    func decodeWebsocketMessage<T: Codable>(_ type: T.Type) -> WebsocketMessage<T>? {
        try? JSONDecoder().decode(WebsocketMessage<T>.self, from: self)
    }
}
```

That's about the helpers, now we should figure out what kind of messages do we need, right?

First of all, we'd like to store a client after a successful connection event happens. We are going to use a `Connect` message for this purpose. The client will send a simple connect boolean flag, right after the connection was established so the server can save the client.

```swift
import Foundation

struct Connect: Codable {
    let connect: Bool
}
```

We are building a game, so we need players as clients, let's subclass the `WebSocketClient` class, so we can store additional properties on it later on.

```swift
import Vapor

final class PlayerClient: WebSocketClient {
    
    public init(id: UUID, socket: WebSocket, status: Status) {
        super.init(id: id, socket: socket)
    }
}
```

Now we have to make a `GameSystem` object that will be responsible for storing clients with associated identifiers and decoding & handling incoming websocket messages.

```swift
import Vapor

class GameSystem {
    var clients: WebsocketClients

    init(eventLoop: EventLoop) {
        self.clients = WebsocketClients(eventLoop: eventLoop)
    }

    func connect(_ ws: WebSocket) {
        ws.onBinary { [unowned self] ws, buffer in
            if let msg = buffer.decodeWebsocketMessage(Connect.self) {
                let player = PlayerClient(id: msg.client, socket: ws)
                self.clients.add(player)
            }
        }
    }
}
```

We can hook up the `GameSystem` class inside the config method to a websocket channel using the built-in `.webSocket` method, that's part of the Vapor 4 framework by default.

```swift
import Vapor

public func configure(_ app: Application) throws {
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    let gameSystem = GameSystem(eventLoop: app.eventLoopGroup.next())

    app.webSocket("channel") { req, ws in
        gameSystem.connect(ws)
    }
    
    app.get { req in
        req.view.render("index.html")
    }
}
```

We are also going to render a new view called `index.html`, the plaintext renderer is the default in Vapor so we don't have to set up Leaf if we want to display with basic HTML files.

```html
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Sockets</title>
</head>

<body>
    <div style="float: left; margin-right: 16px;">
        <canvas id="canvas" width="640" height="480" style="width: 640px; height: 480px; border: 1px dashed #000;"></canvas>
        <div>
            <a href="javascript:WebSocketStart()">Start</a>
            <a href="javascript:WebSocketStop()">Stop</a>
        </div>
    </div>

    <script src="js/main.js"></script>
</body>
</html>
```

We can save the snippet from above under the `Resources/Views/index.html` file. The canvas will be used to render our 2d game, plus will need some additional JavaScript magic to start and stop the websocket connection using the control buttons. ⭐️

## A websocket client using JavaScript

Create a new `Public/js/main.js` file with the following contents, I'll explain everything below.

```js
function blobToJson(blob) {
    return new Promise((resolve, reject) => {
        let fr = new FileReader();
        fr.onload = () => {
            resolve(JSON.parse(fr.result));
        };
        fr.readAsText(blob);
    });
}

function uuidv4() {
    return ([1e7]+-1e3+-4e3+-8e3+-1e11).replace(/[018]/g, c => (c ^ crypto.getRandomValues(new Uint8Array(1))[0] & 15 >> c / 4).toString(16));
}

WebSocket.prototype.sendJsonBlob = function(data) {
    const string = JSON.stringify({ client: uuid, data: data })
    const blob = new Blob([string], {type: "application/json"});
    this.send(blob)
};

const uuid = uuidv4()
let ws = undefined

function WebSocketStart() {
    ws = new WebSocket("wss://" + window.location.host + "/channel")
    ws.onopen = () => {
        console.log("Socket is opened.");
        ws.sendJsonBlob({ connect: true })
    }

    ws.onmessage = (event) => {
        blobToJson(event.data).then((obj) => {
            console.log("Message received.");
        })
    };

    ws.onclose = () => {
        console.log("Socket is closed.");
    };
}

function WebSocketStop() {
    if ( ws !== undefined ) {
        ws.close()
    }
}
```

We need some helper methods to convert JSON to [blob](https://developer.mozilla.org/en-US/docs/Web/API/Blob) and vica versa. The `blobToJson` function is an asynchronous method that returns a new `Promise` with the parsed JSON value of the original binary data. In JavaScript can use the `.then` method to chain promises. 🔗

The `uuidv4` method is a unique identifier generator, it's far from perfect, but we can use it to create a somewhat unique client identifier. We will call this in a few lines below.

In JavaScript you can extend a built-in functions, just like we extend structs, classes or protocols in Swift. We are extending the `WebSocket` object with a helper method to send JSON messages with the client UUID encoded as blob data (`sendJsonBlob`).

When the `main.js` file is loaded all the top level code gets executed. The `uuid `constant will be available for later use with a unique value, plus we construct a new `ws` variable to store the opened websocket connection locally. If you take a quick look at the HTML file you can see that there are two `onClick` listeners on the links, the `WebSocketStart` and `WebSocketStop` methods will be called when you click those buttons. ✅

Inside the start method we are initiating a new WebSocket connection using a URL string, we can use the `window.location.host` property to get the domain with the port. The schema should be `wss` for secure (HTTPS) connections, but you can also use the `ws` for insecure (HTTP) ones.

There are three event listeners that you can subscribe to. They work like delegates in the iOS world, once the connection is established the `onopen` handler will be called. In the callback function we send the connect message as a blob value using our previously defined helper method on the WebSocket object.

If there is an incoming message (`onmessage`) we can simply log it using the `console.log` method, if you bring up the inspector panel in a browser there is a Console tab where you will be able to see these kind of logs. If the connection is closed (`onclose`) we do the same. When the user clicks the stop button we can use the close method to manually terminate the websocket connection.

Now you can try to build & run what we have so far, but don't expect more than raw logs. 😅

## Building a websocket game

We will build a 2d catcher game, all the players are going to be represented as little colorful circles. A white dot will mark your own player and the catcher is going to be tagged with a black circle. Players need positions, colors and we have to send the movement controls from the client to the server side. The client will take care of the rendering, so we need to push the position of every connected player through the websocket channel. We will use a fixed size canvas for the sake of simplicity, but I'll show you how to add support for HiDPI displays. 🎮

Let's start by updating the server, so we can store everything inside the `PlayerClient`.

```swift
import Vapor

final class PlayerClient: WebSocketClient {

    struct Status: Codable {
        var id: UUID!
        var position: Point
        var color: String
        var catcher: Bool = false
        var speed = 4
    }
    
    var status: Status
    var upPressed: Bool = false
    var downPressed: Bool = false
    var leftPressed: Bool = false
    var rightPressed: Bool = false
    
    
    public init(id: UUID, socket: WebSocket, status: Status) {
        self.status = status
        self.status.id = id

        super.init(id: id, socket: socket)
    }

    func update(_ input: Input) {
        switch input.key {
        case .up:
            self.upPressed = input.isPressed
        case .down:
            self.downPressed = input.isPressed
        case .left:
            self.leftPressed = input.isPressed
        case .right:
            self.rightPressed = input.isPressed
        }
    }

    func updateStatus() {
        if self.upPressed {
            self.status.position.y = max(0, self.status.position.y - self.status.speed)
        }
        if self.downPressed {
            self.status.position.y = min(480, self.status.position.y + self.status.speed)
        }
        if self.leftPressed {
            self.status.position.x = max(0, self.status.position.x - self.status.speed)
        }
        if self.rightPressed {
            self.status.position.x = min(640, self.status.position.x + self.status.speed)
        }
    }
}
```

We are going to share the status of each player in every x millisecond with the clients, so they can re-render the canvas based on the fresh data. We also need a new Input struct, so clients can send key change events to the server and we can update players based on that.

```swift
import Foundation

struct Input: Codable {

    enum Key: String, Codable {
        case up
        case down
        case left
        case right
    }

    let key: Key
    let isPressed: Bool
}
```

Position values are stored as points with x and y coordinates, we can build a struct for this purpose with an additional function to calculate the distance between two players. If they get too close to each other, we can pass the tag to the catched player. 🎯

```swift
import Foundation

struct Point: Codable {
    var x: Int = 0
    var y: Int = 0
    
    func distance(_ to: Point) -> Float {
        let xDist = Float(self.x - to.x)
        let yDist = Float(self.y - to.y)
        return sqrt(xDist * xDist + yDist * yDist)
    }
}
```

Now the tricky part. The game system should be able to notify all the clients in every x milliseconds to provide a smooth 60fps experience. We can use the Dispatch framework to schedule a timer for this purpose. The other thing is that we want to avoid "tagbacks", so after one player catched another we are going to put a 2 second timeout, this way users will have some time to run away.

```swift
import Vapor
import Dispatch

class GameSystem {
    var clients: WebsocketClients

    var timer: DispatchSourceTimer
    var timeout: DispatchTime?
        
    init(eventLoop: EventLoop) {
        self.clients = WebsocketClients(eventLoop: eventLoop)

        self.timer = DispatchSource.makeTimerSource()
        self.timer.setEventHandler { [unowned self] in
            self.notify()
        }
        self.timer.schedule(deadline: .now() + .milliseconds(20), repeating: .milliseconds(20))
        self.timer.activate()
    }

    func randomRGBAColor() -> String {
        let range = (0..<255)
        let r = range.randomElement()!
        let g = range.randomElement()!
        let b = range.randomElement()!
        return "rgba(\(r), \(g), \(b), 1)"
    }

    func connect(_ ws: WebSocket) {
        ws.onBinary { [unowned self] ws, buffer in
            if let msg = buffer.decodeWebsocketMessage(Connect.self) {
                let catcher = self.clients.storage.values
                    .compactMap { $0 as? PlayerClient }
                    .filter { $0.status.catcher }
                    .isEmpty

                let player = PlayerClient(id: msg.client,
                                          socket: ws,
                                          status: .init(position: .init(x: 0, y: 0),
                                                        color: self.randomRGBAColor(),
                                                        catcher: catcher))
                self.clients.add(player)
            }

            if
                let msg = buffer.decodeWebsocketMessage(Input.self),
                let player = self.clients.find(msg.client) as? PlayerClient
            {
                player.update(msg.data)
            }
        }
    }

    func notify() {
        if let timeout = self.timeout {
            let future = timeout + .seconds(2)
            if future < DispatchTime.now() {
                self.timeout = nil
            }
        }

        let players = self.clients.active.compactMap { $0 as? PlayerClient }
        guard !players.isEmpty else {
            return
        }

        let gameUpdate = players.map { player -> PlayerClient.Status in
            player.updateStatus()
            
            players.forEach { otherPlayer in
                guard
                    self.timeout == nil,
                    otherPlayer.id != player.id,
                    (player.status.catcher || otherPlayer.status.catcher),
                    otherPlayer.status.position.distance(player.status.position) < 18
                else {
                    return
                }
                self.timeout = DispatchTime.now()
                otherPlayer.status.catcher = !otherPlayer.status.catcher
                player.status.catcher = !player.status.catcher
            }
            return player.status
        }
        let data = try! JSONEncoder().encode(gameUpdate)
        players.forEach { player in
            player.socket.send([UInt8](data))
        }
    }
    
    deinit {
        self.timer.setEventHandler {}
        self.timer.cancel()
    }
}
```

Inside the notify method we're using the built-in `.send` method on the WebSocket object to send binary data to the clients. In a chat application we would not require the whole timer logic, but we could simply notify everyone inside the onBinary block after a new incoming chat message.

The server is now ready to use, but we still have to alter the WebSocketStart method on the client side to detect key presses and releases and to render the incoming data on the canvas element.

```js
function WebSocketStart() {

    function getScaled2DContext(canvas) {
        const ctx = canvas.getContext('2d')
        const devicePixelRatio = window.devicePixelRatio || 1
        const backingStorePixelRatio = [
            ctx.webkitBackingStorePixelRatio,
            ctx.mozBackingStorePixelRatio,
            ctx.msBackingStorePixelRatio,
            ctx.oBackingStorePixelRatio,
            ctx.backingStorePixelRatio,
            1
        ].reduce((a, b) => a || b)

        const pixelRatio = devicePixelRatio / backingStorePixelRatio
        const rect = canvas.getBoundingClientRect();
        canvas.width = rect.width * pixelRatio;
        canvas.height = rect.height * pixelRatio;
        ctx.scale(pixelRatio, pixelRatio);
        return ctx;
    }

    function drawOnCanvas(ctx, x, y, color, isCatcher, isLocalPlayer) {
        ctx.beginPath();
        ctx.arc(x, y, 9, 0, 2 * Math.PI, false);
        ctx.fillStyle = color;
        ctx.fill();

        if ( isCatcher ) {
            ctx.beginPath();
            ctx.arc(x, y, 6, 0, 2 * Math.PI, false);
            ctx.fillStyle = 'black';
            ctx.fill();
        }

        if ( isLocalPlayer ) {
            ctx.beginPath();
            ctx.arc(x, y, 3, 0, 2 * Math.PI, false);
            ctx.fillStyle = 'white';
            ctx.fill();
        }
    }


    const canvas = document.getElementById('canvas')
    const ctx = getScaled2DContext(canvas);

    ws = new WebSocket("wss://" + window.location.host + "/channel")
    ws.onopen = () => {
        console.log("Socket is opened.");
        ws.sendJsonBlob({ connect: true })
    }

    ws.onmessage = (event) => {
        blobToJson(event.data).then((obj) => {
            ctx.clearRect(0, 0, canvas.width, canvas.height)
            for (var i in obj) {
                var p = obj[i]
                const isLocalPlayer = p.id.toLowerCase() == uuid
                drawOnCanvas(ctx, p.position.x, p.position.y, p.color, p.catcher, isLocalPlayer)
            }
        })
    };

    ws.onclose = () => {
        console.log("Socket is closed.");
        ctx.clearRect(0, 0, canvas.width, canvas.height)
    };

    document.onkeydown = () => {
        switch (event.keyCode) {
            case 38: ws.sendJsonBlob({ key: 'up', isPressed: true }); break;
            case 40: ws.sendJsonBlob({ key: 'down', isPressed: true }); break;
            case 37: ws.sendJsonBlob({ key: 'left', isPressed: true }); break;
            case 39: ws.sendJsonBlob({ key: 'right', isPressed: true }); break;
        }
    }

    document.onkeyup = () => {
        switch (event.keyCode) {
            case 38: ws.sendJsonBlob({ key: 'up', isPressed: false }); break;
            case 40: ws.sendJsonBlob({ key: 'down', isPressed: false }); break;
            case 37: ws.sendJsonBlob({ key: 'left', isPressed: false }); break;
            case 39: ws.sendJsonBlob({ key: 'right', isPressed: false }); break;
        }
    }
}
```

The `getScaled2DContext` method will scale the canvas based on the pixel ratio, so we can draw smooth circles both on retina and standard displays. The `drawOnCanvas` method draws a player using the context at a given point. You can also draw the player with a tag and the white marker if the unique player id matches the local client identifier.

Before we connect to the socket we create a new reference using the canvas element and create a draw context. When a new message arrives we can decode it and draw the players based on the incoming status data. We clear the canvas before the render and after the connection is closed.

The last thing we have to do is to send the key press and release events to the server. We can add two listeners using the `document` variable, key codes are stored as integers, but we can map them and send right the JSON message as a blob value for the arrow keys.

## Closing thoughts

As you can see it is relatively easy to add websocket support to an existing Vapor 4 application. Most of the time you will have to think about the architecture and the message structure instead of the Swift code. On by the way if you are setting up the backend behind an [nginx proxy](https://www.nginx.com/blog/websocket-nginx/) you might have to add the `Upgrade` and `Connection` headers to the location section.

```
server {
    location @proxy {
        proxy_pass http://127.0.0.1:8080;
        proxy_pass_header Server;
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_connect_timeout 3s;
        proxy_read_timeout 10s;
        http2_push_preload on;
    }
}
```

This tutorial was mostly about building a proof of concept websocket game, this was the first time I've worked with websockets using Vapor 4, but I had a lot of fun while I made this little demo. In a real-time multiplayer game you have to think about a more intelligent lag handler, you can search for the interpolation, extrapolation or lockstep keywords, but IMHO this is a good starting point.
