---
type: post
slug: sign-in-with-apple-using-vapor-4
title: Sign in with Apple using Vapor 4
description: A complete tutorial for beginners about how to implement the Sign in with Apple authentication service for your website.
publication: 2020-04-30 16:20:00
tags: Vapor, Sign in with Apple
authors:
  - tibor-bodecs
---

## Apple developer portal setup

In order to make the Sign in with Apple work for your website you'll need a payed developer account. That'll cost you $99 / year if you are an individual developer. You can compare various [membership options](https://developer.apple.com/support/compare-memberships/) or just simply [enroll using this link](https://developer.apple.com/programs/enroll/), but you'll need an existing [Apple ID](https://appleid.apple.com/#!&page=signin).

I assume that you made it so far and you have a working Apple developer account by now. A common misbelief about Sign in with Apple (SiwA) is that you need an existing iOS application publised to the App Store to make it work, but that's not the case. It works without a companion app, however you'll need an application identifier registered in the dev portal.

### App identifier

Select the Identifiers menu item from the list on the left, press the plus (+) button, select the App IDs option and press the Continue button. Fill out the description field and enter a custom bunde indentifier that you'd like to use (e.g. com.mydomain.ios.app). Scroll down the Capabilities list until you find the Sign in With Apple option, mark the checkbox (the Enable as primary App ID should appear right next to an edit button) and press the Continue button on the top right corner. Register the application identifier using the top right button, after you find everything all right.

You should see the newly created AppID in the list, if not there is a search icon on the right side of the screen. Pick the AppIDs option and the application identifer item should appear. 🔍

### Service identifier

Next we need a service identifier for SiwA. Press the add button again and now select the Services IDs option. Enter a description and fill out the identifier using the same reverse-domain name style. I prefer to use my domain name with a suffix, that can be something like com.example.siwa.service. Press the Continue and the Register buttons, we're almost ready with the configuration part.

Filter the list of identifiers by Service IDs and click on the newly created one. There is a Configure button, that you should press. Now associate the Primary App ID to this service identifier by selecting the application id that we made previously from the option list. Press the plus button next to the Website URLs text and enter the given domain that you'd like to use (e.g. example.com).

You'll also have to add at least one Return URL, which is basically a redirect URL that the service can use after an auth request. You should always use HTTPS, but apart from this constraint the redirect URL can be anything (e.g. https://example.com/siwa-redirect). #notrailingslash

You can add or remove URLs at any time using this screen, thankfully there is a remove option for every domain and redirect URL. Press Next to save the URLs and Done when you are ready with the Sign in with Apple service configuration process.

### Keys

The last thing that we need to create on the dev portal is a private key for client authentication. Select the Keys menu item on the left and press the add new button. Name the key as you want, select the Sign in with Apple option from the list. In the Configure menu select the Primary App ID, it should be connected with the application identifier we made earlier. Click Save to return to the previous screen and press Continue. Review the data and finally press the Register button.

Now this is your only chance to get the registered private key, if you pressed the done button without downloading it, you will lose the key forever, you have to make a new one, but don't worry too much if you messed it up you can click on the key, press the big red Revoke button to delete it and start the process again. This comes handy if the key gets compromised, so don't share it with anybody else otherwise you'll have to make a new one. 🔑

### Team & JWK identifier

I almost forget that you'll need your team identifier and the JWK identifier for the sign in process. The JWK id can be found under the previously generated key details page. If you click on the name of the key you can view the details. The Key ID is on that page alongside with the revoke button and the Sign in with Apple configuration section where you can get the team identifier too, since the service bundle identifier is prefixed with that. Alternatively you can copy the team id from the very top right corner of the dev portal, it's right next to your name.

## Implementing Sign in With Apple

Before we write a single line of Swift code let me explain a simplified version of the entire process.

The entire login flow has 3 main components:

- Initiate a web auth request using the SiwA button (start the OAuth flow)
- Validate the returned user identity token using Apple's JWK service
- Exchange the user identity token for an access token

Some of the tutorials overcomplicate this, but you'll see how easy is to write the entire flow using Vapor 4. We don't even need additional scripts that generate tokens we can do everything in pure Swift, which is good. Lets start a new Vapor project. You'll need the JWT package as well.

```swift
// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "binarybirds",
    platforms: [
       .macOS(.v10_15)
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.4.0"),
        .package(url: "https://github.com/vapor/leaf.git", from: "4.0.0-rc"),
        .package(url: "https://github.com/vapor/jwt.git", from: "4.0.0-rc"),
    ],
    targets: [
        .target(name: "App", dependencies: [
            .product(name: "Vapor", package: "vapor"),
            .product(name: "Leaf", package: "leaf"),
            .product(name: "JWT", package: "jwt"),
        ]),
        .target(name: "Run", dependencies: ["App"]),
    ]
)
```

If you don't know how to build the project you should [read my beginners guide](https://theswiftdev.com/beginners-guide-to-server-side-swift-using-vapor-4/) about Vapor 4.

### The Sign in with Apple button

We're going to use the [Leaf template engine](https://theswiftdev.com/how-to-create-your-first-website-using-vapor-4-and-leaf/) to render our views, it's pretty simple to make it work, I'll show you the configuration file in a second. We're going to use just one simple template this time. We can call it index.leaf and save the file into the Resources/Views directory.

```html
<!DOCTYPE html>
<html>
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>
            .signin-button {
                width: 240px;
                height: 40px;
            }
            .signin-button > div > div > svg {
                width: 100%;
                height: 100%;
                color: red;
            }
            .signin-button:hover {
                cursor: pointer;
            }
            .signin-button > div {
                outline: none;
            }
      </style>
    </head>
    <body>
        <script type="text/javascript" src="https://appleid.cdn-apple.com/appleauth/static/jsapi/appleid/1/en_US/appleid.auth.js"></script>
        <div id="appleid-signin" data-color="black" data-border="false" data-type="sign in" class="signin-button"></div>
        <script type="text/javascript">
            AppleID.auth.init({
                clientId : '#(clientId)',
                scope : '#(scope)',
                redirectURI: '#(redirectUrl)',
                state : '#(state)',
                usePopup : #(popup),
            });
        </script>
    </body>
</html>
```

The [Sign in with Apple JS framework](https://developer.apple.com/documentation/sign_in_with_apple/sign_in_with_apple_js) can be used to render the login button on the website. There is a similar thing for iOS called [AuthenticationServices](https://developer.apple.com/documentation/authenticationservices), but this time we're only going to focus on the web. Unfortunately the sign in button is quite buggy so we have to add some extra CSS hack to fix the underlying issues. Come on Apple, why do we have to hack these things? 😅

Starting the AppleID auth process is really simple you just have to configure a few parameters. The client id is service the bundle identifier that we entered on the developer portal. The scope can be either name or email, but you can use both if you want. The redirect URI is the redirect URL that we registered on the dev portal, and the state should be something unique that you can use to identify the request. Apple will send this state back to you in the response.

> Noone talks about the usePopup parameter, so we'll leave it that way too... 🤔

Alternatively you can use meta tags to configure the authorization object, you can read more about this in the [Configuring your webpage for Sign in with Apple](https://developer.apple.com/documentation/sign_in_with_apple/sign_in_with_apple_js/configuring_your_webpage_for_sign_in_with_apple) documentation.

### Vapor configuration

It's time to configure our Vapor application so we can render this Leaf template file and use the signing key that we acquired from Apple using the dev portal. We are dealing with some secret info here, so you should never store it in the repository, but you can use Vapor's [environment](https://theswiftdev.com/the-anatomy-of-vapor-commands/) for this purpose. I prefer to have an extension for the available environment variables.

```swift
extension Environment {
    // service bundle identifier
    static var siwaId = Environment.get("SIWA_ID")!
    // registered redirect url
    static let siwaRedirectUrl = Environment.get("SIWA_REDIRECT_URL")!
    // team identifier
    static var siwaTeamId = Environment.get("SIWA_TEAM_ID")!
    // key identifier
    static var siwaJWKId = Environment.get("SIWA_JWK_ID")!
    // contents of the downloaded key file
    static var siwaKey = Environment.get("SIWA_KEY")!
}
```

In Vapor 4 you can setup a custom JWT signer that can sign the payload with the proper keys and other values based on the configuration. This JWT signer can be used to verify the token in the response. It works like magic. JWT & JWTKit is an official Vapor package, there is definitely no need to implement your own solution. In this first example we will just prepare the signer for later use and render the index page so we can initalize the OAuth request using the website.

```swift
import Vapor
import Leaf
import JWT

extension JWKIdentifier {
    static let apple = JWKIdentifier(string: Environment.siwaJWKId)
}

extension String {
    var bytes: [UInt8] {
        return .init(self.utf8)
    }
}

public func configure(_ app: Application) throws {
    
    app.views.use(.leaf)
    //app.leaf.cache.isEnabled = false

    app.middleware.use(SessionsMiddleware(session: app.sessions.driver))

    app.jwt.apple.applicationIdentifier = Environment.siwaId
    
    let signer = try JWTSigner.es256(key: .private(pem: Environment.siwaKey.bytes))
    app.jwt.signers.use(signer, kid: .apple, isDefault: false)

    app.get { req -> EventLoopFuture<View> in
        struct ViewContext: Encodable {
            var clientId: String
            var scope: String = "name email"
            var redirectUrl: String
            var state: String
            var popup: Bool = false
        }

        let state = [UInt8].random(count: 16).base64
        req.session.data["state"] = state
        let context = ViewContext(clientId: Environment.siwaId,
                                  redirectUrl: Environment.siwaRedirectUrl,
                                  state: state)
        return req.view.render("index", context)
    }
}
```

The session middleware is used to transfer a random generated code between the index page and the redirect handler. Now if you run the app and click on the Sign in with Apple button you'll see that the flow starts, but it'll fail after you identified yourself. That's ok, step one is completed. ✅

### The redirect handler

Apple will try to send a POST request with an object that contains the Apple ID token to the registered redirect URI after you've identified yourself using their login box. We can model this response object as an `AppleAuthResponse` struct in the following way:

```swift
import Foundation

struct AppleAuthResponse: Decodable {

    enum CodingKeys: String, CodingKey {
        case code
        case state
        case idToken = "id_token"
        case user
    }

    let code: String
    let state: String
    let idToken: String
    let user: String
}
```

The authorization code is the first parameter, the state shuld be equal with your state value that you send as a parameter when you press the login button, if they don't match don't trust the response somebody is trying to hack you. The idToken is the Apple ID token, we have to validate that using the JWKS validation endpoint. The user string is the email address of the user.

```swift
app.post("siwa-redirect") { req in
    let state = req.session.data["state"] ?? ""
    let auth = try req.content.decode(AppleAuthResponse.self)
    guard !state.isEmpty, state == auth.state else {
        return req.eventLoop.future("Invalid state")
    }

    return req.jwt.apple.verify(auth.idToken, applicationIdentifier: Environment.siwaId)
    .flatMap { token in
        //...
    }
}
```

The code above will handle the incoming response. First it'll try to decode the `AppleAuthResponse` object from the body, next it'll call the Apple verification service using your private key and the idToken value from the response. This validation service returns an `AppleIdentityToken` object. That's part of the JWTKit package. We've just completed Step 2. ☺️

### Exchanging the access token

The `AppleIdentityToken` only lives for a short period of time so we have to exchange it for an access token that can be used for much longer. We have to construct a request, we are going to use the following request body to exchange tokens:

```swift
struct AppleTokenRequestBody: Encodable {
    
    enum CodingKeys: String, CodingKey {
        case clientId = "client_id"
        case clientSecret = "client_secret"
        case code
        case grantType = "grant_type"
        case redirectUri = "redirect_uri"
    }
    
    /// The application identifier for your app.
    let clientId: String

    /// A secret generated as a JSON Web Token that uses the secret key generated by the WWDR portal.
    let clientSecret: String

    /// The authorization code received from your application’s user agent. The code is single use only and valid for five minutes.
    let code: String
    
    /// The destination URI the code was originally sent to.
    let redirectUri: String
    
    /// The grant type that determines how the client interacts with the server.
    let grantType: String = "authorization_code"
}
```

We'll also need to generate the client secret, based on the response we are going to make a new `AppleAuthToken` object for this that can be signed using the already configured JWT service.

```swift
struct AppleAuthToken: JWTPayload {
    let iss: String
    let iat = Int(Date().timeIntervalSince1970)
    let exp: Int
    let aud = "https://appleid.apple.com"
    let sub: String

    init(clientId: String, teamId: String, expirationSeconds: Int = 86400 * 180) {
        sub = clientId
        iss = teamId
        exp = self.iat + expirationSeconds
    }

    func verify(using signer: JWTSigner) throws {
        guard iss.count == 10 else {
            throw JWTError.claimVerificationFailure(name: "iss", reason: "TeamId must be your 10-character Team ID from the developer portal")
        }

        let lifetime = exp - iat
        guard 0...15777000 ~= lifetime else {
            throw JWTError.claimVerificationFailure(name: "exp", reason: "Expiration must be between 0 and 15777000")
        }
    }
}
```

Since we have to make a new request we can use the built-in `AysncHTTPClient` service. I've made a little extension around the `HTTPClient` object to simplify the request creation process.

```swift
extension HTTPClient {
    static func appleAuthTokenRequest(_ body: AppleTokenRequestBody) throws -> HTTPClient.Request {
        var request = try HTTPClient.Request(url: "https://appleid.apple.com/auth/token", method: .POST)
        request.headers.add(name: "User-Agent", value: "Mozilla/5.0 (Windows NT 6.2) AppleWebKit/536.6 (KHTML, like Gecko) Chrome/20.0.1090.0 Safari/536.6'")
        request.headers.add(name: "Accept", value: "application/json")
        request.headers.add(name: "Content-Type", value: "application/x-www-form-urlencoded")
        request.body = .string(try URLEncodedFormEncoder().encode(body))
        return request
    }
}
```

The funny thing here is if you don't add the `User-Agent` header the SiwA service will return with an error, the problem was mentioned in [this article](https://developer.okta.com/blog/2019/06/04/what-the-heck-is-sign-in-with-apple) also discussed on the Apple Developer Fourms.

Anyway, let me show you the complete redirect handler. 🤓

```swift
app.post("siwa-redirect") { req -> EventLoopFuture<String> in
    let state = req.session.data["state"] ?? ""
    let auth = try req.content.decode(AppleAuthResponse.self)
    guard !state.isEmpty, state == auth.state else {
        return req.eventLoop.future("Invalid state")
    }

    return req.jwt.apple.verify(auth.idToken, applicationIdentifier: Environment.siwaId)
    .flatMap { token -> EventLoopFuture<HTTPClient.Response> in
        do {
            let secret = AppleAuthToken(clientId: Environment.siwaId, teamId: Environment.siwaTeamId)
            let secretJwtToken = try app.jwt.signers.sign(secret, kid: .apple)

            let body = AppleTokenRequestBody(clientId: Environment.siwaId,
                                             clientSecret: secretJwtToken,
                                             code: auth.code,
                                             redirectUri: Environment.siwaRedirectUrl)

            let request = try HTTPClient.appleAuthTokenRequest(body)
            return app.http.client.shared.execute(request: request)
        }
        catch {
            return req.eventLoop.future(error: error)
        }
    }
    .map { response -> String in
        guard var body = response.body else {
            return "n/a"
        }
        return body.readString(length: body.readableBytes) ?? "n/a"
    }
}
```
As you can see I'm just sending the exchange request and map the final response to a string. From this point it is really easy to implement a decoder, the response is something like this:

```swift
struct AppleAccessToken: Decodable {

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
        case idToken = "id_token"
    }

    let accessToken: String
    let tokenType: String
    let expiresIn: Int
    let refreshToken: String
    let idToken: String
}
```

You can use this response to authenticate your users, but that's up-to-you based on your own business logic & requirements. You can use the same `authTokenRequest` method to refresh the token, you just have to set the grant type to `refresh_token` instead of `authorization_code`

I know that there is still room for improvements, the code is far from perfect, but it's a working proof of concept. The article is getting really long, so maybe this is the right time stop. 😅

If you are looking for a good place to learn more about SiwA, you should check [this link](https://sarunw.com/tags/sign%20in%20with%20apple/).

## Conclusion

You can have a working Sign in with Apple implementation within an hour if you are using Vapor 4. The hardest part here is that you have to figure out every single little detail by yourself, looking at other people's source code. I'm trying to explain things as easy as possible but hey, I'm still putting together the pieces for myself too.

This is an extremely fun journey for me. Moving back to the server side after almost a decade of iOS development is a refreshing experience. I can only hope you'll enjoy my upcoming book called Practical Server Side Swift, as much as I enjoy learning and writing about the Vapor. ❤️
