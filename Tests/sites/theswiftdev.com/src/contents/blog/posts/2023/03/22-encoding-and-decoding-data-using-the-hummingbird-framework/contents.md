---
slug: encoding-and-decoding-data-using-the-hummingbird-framework
title: Encoding and decoding data using the Hummingbird framework
description: URL encoded requests over multipart form data? Maybe JSON and raw HTTP post body types? Let me explain all of this.
publication: 2023-03-22 16:20:00
coverImage: ./2023/03/22-encoding-and-decoding-data-using-the-hummingbird-framework/cover.jpg
tags: Swift, Hummingbird
---

HTTP is all about sending and receiving data over the network. Originally it was only utilized to transfer HTML documents, but nowadays we use HTTP to transfer CSS, JavaScript, JSON and many other data types. According to the standards, the [Content-Type](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Type) and [Content-Length](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Length) headers can be used to have a better understanding about the data inside the body of the HTTP request.

Modern web servers can automatically send back these headers based on the object you return in a request handler function. This is the case with Hummingbird, it has built-in [encoding and decoding](httpshttps://hummingbird-project.github.io/hummingbird-docs/documentation/hummingbird/encoding-and-decoding) support, which makes the data transformation process really simple.

For example if we setup the following route handler and call the hello endpoint using cURL with the -i flag, the output will contain a bit more information about the response. ℹ️

```swift
router.get("hello") { _ in "hello" }

//
// curl -i http://localhost:8080/hello
//
// HTTP/1.1 200 OK
// content-type: text/plain; charset=utf-8
// Date: Mon, 20 Mar 2023 14:45:41 GMT
// connection: keep-alive
// content-length: 5
// server: Hummingbird
//
// hello
//
```

There are some basic headers in the response, the content-type header contains the type of the body, which is currently a plain text with an UTF-8 encoded string, since we've returned a String type using our Swift code. The content-length is 5, because the character count of hello is 5.

There are some other headers, but ignore those, the interesting part for us is the content-type header, and how it is injected into the response. Every Hummingbird application has an encoder and a decoder property. The default values for these are NullEncoder and NullDecoder. The encoders can magically add the proper content type header to the response and encode some object into a HTTP response data. Not everything is response encodable and decodable by default, but you can encode String objects in Hummingbird by default. 👍

## Encoding and decoding JSON objects

Many of the server-side Swift systems are used to create JSON-based RESTful API backends for mobile frontends. Hummingbird can help you with this, since it has built-in encoding and decoding support for JSON objects through the Codable protocol.

First you have to import the HummingbirdFoundation library, since it is a standalone helper tool built around the Foundation framework, and that package contains the Codable type extensions. Next you have to setup the encoder and decoder using a JSONEncoder and JSONDecoder instance. After this, you can easily transform incoming HTTP body objects into Swift data structures and return with them as well. Let me show you a quick example. ⤵️

```swift
import Hummingbird
import HummingbirdFoundation

struct Foo: Codable {
    let bar: String
    let baz: Int
}

extension Foo: HBResponseCodable {}


extension HBApplication {

    func configure(_ args: AppArguments) throws {

        decoder = JSONDecoder()
        encoder = JSONEncoder()

        router.post("foo") { req async throws -> Foo in
            guard let foo = try? req.decode(as: Foo.self) else {
                throw HBHTTPError(.badRequest, message: "Invalid request body.")
            }
            return foo
        }
    }

    //
    // curl -i -X POST http://localhost:8080/foo \
    //     -H "Content-Type: application/json" \
    //     -H "Accept: application/json" \
    //     --data-raw '{"bar": "bar", "baz": 42}'
    //
    // HTTP/1.1 200 OK
    // content-type: application/json; charset=utf-8
    // Date: Mon, 20 Mar 2023 15:15:06 GMT
    // connection: keep-alive
    // content-length: 22
    // server: Hummingbird
    //
    // {"bar":"bar","baz":42}
    //
}
```

As you can see the type of the returned content is now properly set to application/json and the length is also provided by default. We were also able to decode the Foo object from the request body and automatically encode the object after we returned with it.

[Codable routing](https://www.kitura.dev/docs/routing/codable-routing) works like magic and nowadays it's a pretty standard approach if it comes to server-side Swift frameworks. Fun fact: this approach was originally 'invented' for Swift by the developers of the [Kitura framework](https://www.kitura.dev/). Thank you. 🙏

The HBResponseCodable and the HBResponseEncodable protocols are the basic building blocks and the [HBRequestDecoder](https://hummingbird-project.github.io/hummingbird-docs/documentation/hummingbird/hbrequestdecoder/) and the [HBResponseEncoder](https://hummingbird-project.github.io/hummingbird-docs/documentation/hummingbird/hbresponseencoder/) are responsible for this magic. They make it possible to decode a Decodable object from a [HBRequest](https://hummingbird-project.github.io/hummingbird-docs/documentation/hummingbird/hbrequest) and encode things into a [HBResponse](https://hummingbird-project.github.io/hummingbird-docs/documentation/hummingbird/hbresponse) object and also provide additional headers. If you would like to know more, I highly recommend to take a look at the [JSONCoding.swift](https://github.com/hummingbird-project/hummingbird/blob/main/Sources/HummingbirdFoundation/Codable/JSON/JSONCoding.swift) file inside the framework. 😉

## Encoding and decoding HTML forms

I don't want to get too much into the details of building forms using HTML code, by the way there is a better way using [SwiftHtml](https://github.com/BinaryBirds/swift-html), but I'd like to focus more on the underlying data transfer mechanism and the [enctype attribute](https://www.w3schools.com/tags/att_form_enctype.asp). There are 3 possible, but only two useful values of the encoding type:

- application/x-www-form-urlencoded
- multipart/form-data

URL encoding and decoding is supported out of the box when using HummingbirdFoundation, this is a simple wrapper around the [URL encoding](https://www.w3schools.com/tags/ref_urlencode.ASP) mechanism to easily support data transformation.

```swift
decoder = URLEncodedFormDecoder()
encoder = URLEncodedFormEncoder()

//
// curl -i -X POST http://localhost:8080/foo \
//     -H "Content-Type: application/x-www-form-urlencoded" \
//     -H "Accept: application/x-www-form-urlencoded" \
//     --data-raw 'bar=bar&baz=42'
//
// HTTP/1.1 200 OK
// content-type: application/x-www-form-urlencoded
// Date: Mon, 20 Mar 2023 15:54:54 GMT
// connection: keep-alive
// content-length: 14
// server: Hummingbird
//
// bar=bar&baz=42
//
```

So that's one way to process a URL encoded form, the other version is based on the multipart approach, which has no built-in support in Hummingbird, but you can use the [multipart-kit](https://github.com/vapor/multipart-kit) library from the Vapor framework to process such forms. You can find a working example [here](https://github.com/hummingbird-project/hummingbird-examples/tree/main/multipart-form). I also have an article about [how to upload files using multipart form data](https://theswiftdev.com/easy-multipart-file-upload-for-swift/) requests. So there are plenty of resources out there, that's why I won't include an example in this article. 😅

## Header based encoding and decoding

First we have to implement a custom request decoder and a response encoder. In the decoder, we're going to check the Content-Type header for a given request and decode the HTTP body based on that. The encoder will do the exact same thing, but the response body output is going to depend on the Accept header field. Here's how you can implement it:

```swift
struct AppDecoder: HBRequestDecoder {

    func decode<T>(
        _ type: T.Type,
        from req: HBRequest
    ) throws -> T where T: Decodable {
        switch req.headers["content-type"].first {
        case "application/json", "application/json; charset=utf-8":
            return try JSONDecoder().decode(type, from: req)
        case "application/x-www-form-urlencoded":
            return try URLEncodedFormDecoder().decode(type, from: req)
        default:
            throw HBHTTPError(.badRequest)
        }
    }
}

struct AppEncoder: HBResponseEncoder {

    func encode<T>(
        _ value: T,
        from req: HBRequest
    ) throws -> HBResponse where T: Encodable {
        switch req.headers["accept"].first {
        case "application/json":
            return try JSONEncoder().encode(value, from: req)
        case "application/x-www-form-urlencoded":
            return try URLEncodedFormEncoder().encode(value, from: req)
        default:
            throw HBHTTPError(.badRequest)
        }
    }
}
```

Now if you change the configuration and use the AppEncoder & AppDecoder you should be able to respond based on the Accept header and process the input based on the Content-Type header.

```swift
import Hummingbird
import HummingbirdFoundation

struct Foo: Codable {
    let bar: String
    let baz: Int
}

extension Foo: HBResponseEncodable {}
extension Foo: HBResponseCodable {}

extension HBApplication {

    func configure(_ args: AppArguments) throws {

        decoder = AppDecoder()
        encoder = AppEncoder()

        router.post("foo") { req async throws -> Foo in
            guard let foo = try? req.decode(as: Foo.self) else {
                throw HBHTTPError(.badRequest, message: "Invalid request body.")
            }
            return foo
        }
    }
}
```

Feel free to play around with some cURL snippets... 👾

```sh
# should return JSON encoded data
curl -i -X POST http://localhost:8080/foo \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -H "Accept: application/json" \
    --data-raw 'bar=bar&baz=42'

# should return URL encoded data
curl -i -X POST http://localhost:8080/foo \
    -H "Content-Type: application/json" \
    -H "Accept: application/x-www-form-urlencoded" \
    --data-raw '{"bar": "bar", "baz": 42}'

# should return with a 400 status code
curl -i -X POST http://localhost:8080/foo \
    -H "Content-Type: application/json" \
    -H "Accept: multipart/form-data" \
    --data-raw '{"bar": "bar", "baz": 42}'
```

So, based on this article you should be able to implement support to even more content types by simply extending the app encoder and decoder. Of course you might have to import some additional package dependencies, but that's fine.

## Raw requests and responses

One more little thing, before I end this article: you can access the raw request body data and send back a raw response using the HBResponse object like this:

```swift
router.post("foo") { req async throws -> HBResponse in
    // get raw request body
    if let buffer = req.body.buffer {
        let rawInputData = buffer.getData(
            at: 0,
            length: buffer.readableBytes
        )
        print(rawInputData)
    }

    // streaming input body chunk-by-chunk
    if let sequence = req.body.stream?.sequence {
        for try await chunk in sequence {
            print(chunk)
        }
    }

    guard let data = "hello".data(using: .utf8) else {
        throw HBHTTPError(.internalServerError)
    }

    return .init(
        status: .ok,
        headers: .init(),
        body: .byteBuffer(.init(data: data))
    )
}
```

For smaller requests, you can use the req.body.buffer property and turn it into a Data type if needed. Hummingbird has great support for the new Swift Concurreny API, so you can use the sequence on the body stream if you need chunked reads. Now only one question left:

## What types should I support?

The answer is simple: it depends. Like really. Nowadays I started to ditch multipart encoding and I prefer to communicate with my API using REST (JSON) and upload files as raw HTTP body. I never really had to support URL encoding, because if you submit HTML forms, you'll eventually face the need of file upload and that won't work with URL encoded forms, but only with multipart.

In conclusion I'd say that the good news is that we have plenty of opportunities and if you want to provide support for most of these types you don't have to reinvent the wheel at all. The multipart-kit library is built into Vapor 4, but that's one of the reasons I started to like Hummingbird a bit more, because I can only include what I really need. Anyway, competition is a good thing to have in this case, because hopefully both frameworks will evolve for good... 🙃
