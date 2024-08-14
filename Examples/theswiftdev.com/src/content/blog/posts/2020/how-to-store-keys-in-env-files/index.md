---
type: post
title: How to store keys in env files?
description: In this tutorial I'll show you how to save and load secret keys as base64 encoded strings using dotenv files in Vapor 4.
publication: 2020-06-30 16:20:00
tags: 
    - vapor
    - server
    - tooling
authors:
    - tibor-bodecs
---

## Using the Environment in Vapor 4

Just like many popular server side frameworks, your Vapor based backend application can load a file called `.env`. It is possible to store key-value based (secret) configuration values inside this file. When you run the app, one of the following file will be loaded, based on the current environment:

- Production (`.env`)
- Development (`.env.development`)
- Testing (`.env.testing`)

When you execute your tests the `.env.testing` file will be used. If you start the app using the `serve` Vapor [command](https://theswiftdev.com/the-anatomy-of-vapor-commands/) you can also change the environment using the `--env` or `-e` flag. The available options are production and development, and the corresponding `.env` file will be loaded. It is possible to create a custom environment, you can read more about this in the [official Vapor docs](https://docs.vapor.codes/4.0/environment/). The .env file usually contains one key and value per line, now the problem starts when you want to store a multiline secret key in the file. So what can we do about this? 🤔

## Base64 encoded secret keys

Yes, we can encode the secret key using a base64 encoding. No, I don't want to copy my secrets into an [online base64 encoder](https://www.base64encode.org/), because there is a pretty simple shell command that I can use.

```sh
echo "<my-secret-key>" | base64
```

If you don't like unix commands, we can always put together a little Swift script and use an extension on the String type to encode keys. Just save the snippet from below into a base64.swift file, put your key into the key section, give the file some executable permission & run it using the `chmod o+x && ./base64.swift` one-liner command and voilá...

```swift
#! /usr/bin/swift

import Foundation

extension String {

    func base64Encoded() -> String? {
        return data(using: .utf8)?.base64EncodedString()
    }
}

let key = """
    <my-secret-key-comes-here>
"""

print(key.base64Encoded()!)
```

You can copy & paste the encoded value of the secret key into your own `.env.*` file, replace the asterix symbol with your current environment of course, before you do it. 🙈

```sh
//e.g. .env.development
SECRET_KEY="<base64-encoded-secret-key>"
```
Now we just have to decode this key somehow, before we can start using it...

## Decoding the secret key

You can implement a base64 decoder as a String extension with just a few lines of Swift code.

```swift
import Foundation

extension String {

    func base64Decoded() -> String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
```

Now in my projects I like to extend the `Environment` object and place all my custom variables there as static constants, this way I can access them in a really convenient way, plus if something goes wrong (usually when I don't re-create the `.env` file after a `git reset` or I don't have all the variables present in the dotenv file) the app will crash because of the forced unwraps, and I'll know for sure that something is wrong with my environment. It's a crash for my own safety. 💥

```swift
import Vapor

extension Environment {
    static let secretKey = Self.get("SECRET_KEY")!.base64Decoded()!
}

// usage:
Environment.secretKey
```
I think this approach is very useful. Of course you should place the `.env.*` pattern into your `.gitignore` file, otherwise if you place some secrets into the dotenv file and you push that into the remote... well, everyone else will know your keys, passwords, etc. You don't want that, right? ⚠️

Feel free to use this method when you have to implement a [Sign in With Apple](https://theswiftdev.com/sign-in-with-apple-using-vapor-4/) workflow, or a Apple Push Notification service (APNs). In those cases you'll definitely have to pass one ore more secret keys to your Vapor based backend application. That's it for now, thanks for reading.
