---
type: post
slug: all-about-authentication-in-vapor-4
title: All about authentication in Vapor 4
description: Learn how to implement a user login mechanism with various auth methods using sessions, JWTs, written in Swift only.
publication: 2020-04-07 16:20:00
tags: Vapor, authentication
authors:
  - tibor-bodecs
---

## Authentication, authorization, sessions, tokens what the f*** is this all about???

The official Vapor docs about [authentication](http://docs.vapor.codes/4.0/authentication/) are pretty good, but for a beginner it can be a little hard to understand, since it covers a lot. In this article I'll try to explain everything as simple as possible from a different perspective. First let's define some basic terms.

### Authentication

> Authentication is the act of verifying a user's identity.

In other words, authentication is the process of transforming a unique key (identifier) to actual user data. This can be a cookie with a session identifier stored in a browser, or another one kept by the API client, but based on this id the backend can retrieve the associated user object.

The end user signs in using a login form on a website (or an API endpoint), sends the usual credentials (email, password) to the backend. If those credentials were valid, then the server will return a (randomly generated) identifier to the client. We usually call this identifier, session or token, based on some other principles I'll cover later on. ⬇️

Next time the client wants to make a request it just needs to send the locally stored id, instead of the sensitive email, password combination. The server just needs to validate the id somehow, if it's valid then the user is authenticated, we can use it to fetch more details about the user.

### Authorization

> The act of verifying a previously authenticated user's permissions to perform certain tasks.

How do we know if the authenticated user has access to some endpoint on the server? Is it just a regular visitor, or an admin user? The method of figuring out user roles, permissions, access level is called authorization. It ensures that the authorized user can only access specific resources. 🔒

Consider the following scenario: there are two types of user roles: editors and visitors. An editor can create a new article, but a visitor can only view them (these are the permissions associated to the roles). `EditorUser` is in the group of editors, but `VisitorUser` only has the visitor role. We can figure out the authority (access level) for each user by checking the roles & permissions.

> NOTE: Session ID ~(authentication)~> User ~(authorization)~> Roles & Permissions

Vapor only gives you some help to authenticate the user using various methods. Authorization is usually part of your app's business logic, this means that you have to figure out the details for your own needs, but this is just fine, don't worry too much about it just yet. 😬

### Sessions

> If there is a record on the server side with an identifier, then it is a session.

For the sake of simplicity, let's say that a session is something that you can look up on the server inside some kind of storage. This session is linked to exactly one user account so when you receive a session identifier you can look up the corresponding user through the relation.

The session identifier is exchanged to the client after a successful email + password based login request. The client stores session id somewhere for further usage. The storage can be anything, but browsers mainly use cookies or the local storage. Applications can store session identifiers in the keychain, but I've seen some really bad practices using a plain-text file. 🙉

### Tokens

Tokens (JWTs) on the other hand have no server side records. A token can be given to the client by the authentication API after a successful login request. The key difference between a token and a session is that a token is cryptographically signed. Thanks to asymmetric keys, the signature can be verified by the application server without knowing the private key that was used to sign the token. A token usually self-contains some other info about the user, expiration date, etc. This additional "metadata" can also be verified by the server, this gives us an extra layer of security.

Nowadays [JSON Web Token](https://jwt.io/) is the golden standard if it comes to tokens. JWT is getting more and more popular, implementations are available for almost every programming language with a wide variety of signing algorithms. There is a really amazing [guide to JSON Web Tokens](https://blog.angular-university.io/angular-jwt/), you should definitely read it if you want to know more about this technology. 📖

Enough theory, time to write some code using Swift on the server.

## Implementing auth methods in Vapor

As I mentioned this in the beginning of the article authentication is simply turning a request into actual user data. Vapor has built-in protocols to help us during the process. There is quite an abstraction layer here, which means that you don't have to dig yourself into HTTP headers or incoming body parameters, but you can work with higher level functions to verify identify.

Let me show you all the auth protocols from Vapor 4 and how you can use them in practice. Remember: authentication in Vapor is about turning requests into models using the input.

### Authentication using a Model

Each and every authentication protocol requires a model that is going to be retrieved during the authentication process. In this example I'll work with a `UserModel` entity, here's mine:

```swift
import Vapor
import Fluent

final class UserModel: Model {
        
    static let schema = "users"

    struct FieldKeys {
        static var email: FieldKey { "email" }
        static var password: FieldKey { "password" }
    }
    
    // MARK: - fields
    
    @ID() var id: UUID?
    @Field(key: FieldKeys.email) var email: String
    @Field(key: FieldKeys.password) var password: String
    
    init() { }
    
    init(id: UserModel.IDValue? = nil,
         email: String,
         password: String)
    {
        self.id = id
        self.email = email
        self.password = password
    }
}
```

If you don't understand the code above, please read my [comprehensive tutorial about Fluent](https://theswiftdev.com/a-tutorial-for-beginners-about-the-fluent-postgresql-driver-in-vapor-4/), for now I'll skip the migration part, so you have to write that on your own to make things work. ⚠️

Now that we have a model, it's time to convert an incoming request to an authenticated model using an authenticator object. Let's begin with the most simple one:

### RequestAuthenticator

This comes handy if you have a custom authentication logic and you need the entire request object. Implementing the protocol is relatively straightforward. Imagine that some dumb-ass manager wants to authenticate users using the [fragment identifier](https://en.wikipedia.org/wiki/Fragment_identifier) from the URL.

Not the smartest way of creating a safe authentication layer, but let's make him happy with a nice solution. Again, if you can guess the user identifier and you pass it as a fragment, you're signed in. (e.g. `http://localhost:8080/sign-in#`). If a user exists in the database with the provided UUID then we'll authenticate it (yes without providing a password 🤦‍♂️), otherwise we'll respond with an error code.

```swift
import Vapor
import Fluent

extension UserModel: Authenticatable {}

struct UserModelFragmentAuthenticator: RequestAuthenticator {
    typealias User = UserModel

    func authenticate(request: Request) -> EventLoopFuture<Void> {
        User.find(UUID(uuidString: request.url.fragment ?? ""), on: request.db)
        .map {
            if let user = $0 {
                request.auth.login(user)
            }
        }
    }
}
```

Firstly, we create a `typealias` for the associated User type as our `UserModel`. It is a generic protocol, that's why you need the `typealias`.

> Inside the authenticator implementation you should look up the given user based on the incoming data, and if everything is valid you can simply call the `req.auth.login([user])` method, this will authenticate the user. You should return a `Void` future from these authenticator protocol methods, but please don't throw user related errors or use failed futures in this case. You should only supposed to forward database related errors or similar. If the authenticator can't log in the user, just don't call the login method, it's that simple.

The second and final step is to write our authentication logic, in the auth method. You'll get the request as an input, and you have to return a future with the authenticated user or `nil` if the authentication was unsuccesful. Pretty easy, fragment is available through the request, and you can look up the entity using Fluent. That's it, we're ready. 😅

> WARN: The fragment URL part is never going to be available on the server side at all. 💡

How do we use this authenticator? Well the Authenticator protocol itself extends the [Middleware](https://theswiftdev.com/how-to-use-middlewares-in-vapor-4/) protocol, so we can register it right away as a group member. You can use a middleware to alter incoming requests before the next request handler will be called. This definition fits perfectly for the authenticators so it makes sense that they are defined as middlewares.

We'll need one more (guard) middleware that's coming from the `Authenticatable` protocol to respond with an error to unauthenticated requests.

```swift
func routes(_ app: Application) throws {
    
    app.grouped(UserModelFragmentAuthenticator(),
                UserModel.guardMiddleware())
    .get("sign-in") { req in
        "I'm authenticated"
    }
}
```

Now if you navigate to the `http://localhost:8080/sign-in#` URL, with a valid UUID of an existing user from the db, the page should display "I'm authenticated", otherwise you'll get an HTTP error. The magic happens in the background. I'll explain the flow one more time.

The "sign-in" route has two middlewares. The first one is the authenticator which will try to turn the request into a model using the implemented authentication method. If the authentication was succesful it'll store the user object inside a generic `request.auth` property.

The second middleware literally guards the route from unauthenticated requests. It checks the request.auth variable, if it contains an authenticated user object or not. If it finds a previously authenticated user it'll continue with the next handler, otherwise it'll throw an error. Vapor can automatically turn thrown errors into HTTP status codes, that's why you'll get a 401.

> WARN: The names of the HTTP standard response codes are a little big misleading. You should respond with 401 (unauthorized) for unsuccesful authentication requests, and 403 (forbidden) responses for unauthorized requests. Strange, huh? 😳

You don't necessary need this second middleware, but I'd recommend using it. You can manually check the existence of an authenticated object using try `req.auth.require(UserModel.self)` inside the request handler. A guard middleware is available on every `Authenticatable` object, essentially it is doing the same thing as I mentioned above, but in a more generic, reusable way.

Finally the request handler will only be called if the user is already authenticated, otherwise it'll never be executed. This is how you can protect routes from unauthenticated requests.

### BasicAuthenticator

A `BasicAuthenticator` is just an extension over the `RequestAuthenticator` protocol. During a [basic authentication](https://en.wikipedia.org/wiki/Basic_access_authentication) the credentials are arriving base64 encoded inside the Authorization HTTP header. The format is `Authorization: Basic email:password` where the email:password or username:password credentials are only base64 encoed. Vapor helps you with the decoding process, that's what the protocol adds over the top of the request authentication layer, so you can write a basic authenticator like this:

```swift
struct UserModelBasicAuthenticator: BasicAuthenticator {

    typealias User = UserModel
    
    func authenticate(basic: BasicAuthorization, for request: Request) -> EventLoopFuture<Void> {
        User.query(on: request.db)
            .filter(\.$email == basic.username)
            .first()
            .map {
                do {
                    if let user = $0, try Bcrypt.verify(basic.password, created: user.password) {
                        request.auth.login(user)
                    }
                }
                catch {
                    // do nothing...
                }
        }
    }
}
```

Usage is pretty much the same, you just swap the authenticator or you can combine this one with the previous one to support multiple authentication methods for a single route. 😉

#### Basic auth using the ModelAuthenticatable protocol

You don't always need to implement your own custom BasicAuthenticator. You can conform to the ModelAuthenticatable protocol. This way you can just write a password verifier and the underlying generic protocol implementation will take care of the rest.

```swift
extension UserModel: ModelAuthenticatable {
    static let usernameKey = \UserModel.$email
    static let passwordHashKey = \UserModel.$password

    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.password)
    }
}

// usage
UserModel.authenticator()
```

This is pretty much the same as writing the `UserModelBasicAuthenticator`, the only difference is that this time I don't have to implement the entire authentication logic, but I can simply provide the keypath for the username and password hash, and I just write the verification method. 👍

### BearerAuthenticator

The bearer authentication is just a schema where you can send tokens inside the Authorization HTTP header field after the Bearer keyword. Nowadays this is the recommended way of sending [JWTs to the backend](https://en.wikipedia.org/wiki/JSON_Web_Token). In this case Vapor helps you by fetching the value of the token.

```swift
struct UserModelBearerAuthenticator: BearerAuthenticator {
    
    typealias User = UserModel
    
    func authenticate(bearer: BearerAuthorization, for request: Request) -> EventLoopFuture<Void> {
        // perform auth using the bearer.token value here...
    }
}
```

#### Custom Bearer auth using the ModelAuthenticatable protocol

I lied a little bit in the beginning, regarding sessions and tokens. We developers can call something that's stored in a backend database as a token. Also we're using the Authorization HTTP header field to authenticate users. The joke must be true, if it comes to naming things we are the worst. 😅

Back to the topic, storing a token in the database is more like an extended session, but fine, let's just go with the token name this time. This `ModelUserToken` allows you to create a custom token in the database and use it to authenticate users through an `Authorization Bearer` header.

Let's make a new Fluent model with an associated user to see how this works in practice.

```swift
final class UserTokenModel: Model {
   
   static let schema = "tokens"
   
   struct FieldKeys {
       static var value: FieldKey { "value" }
       static var userId: FieldKey { "user_id" }
   }
   
   // MARK: - fields
   
   @ID() var id: UUID?
   @Field(key: FieldKeys.value) var value: String
   @Parent(key: FieldKeys.userId) var user: UserModel

   init() { }
   
   init(id: UserTokenModel.IDValue? = nil,
        value: String,
        userId: UserModel.IDValue)
   {
       self.id = id
       self.value = value
       self.$user.id = userId
   }
}
```

Now all what's left to do is to extend the protocol by providing the required keyPaths. This protocol allows you to perform extra checks on a given token, such as expiration date. The good news is that the protocol gives you a `BearerAuthenticator` middleware as a "gratis".

```swift
extension UserTokenModel: ModelAuthenticatable {
   static let valueKey = \UserTokenModel.$value
   static let userKey = \UserTokenModel.$user
   
   var isValid: Bool {
       true // you can check expiration or anything else...
   }
}

// a middleware that confroms to the BearerAuthenticator protocol
UserTokenModel.authenticator()
```

How do you give a token to the end user? Well, you can open up an endpoint with a basic auth protection, generate a token, save it to the database and finally return it back as a response. All of this is nicely written in the [official authentication docs](http://docs.vapor.codes/4.0/authentication/) on the Vapor website. If you read that I belive that you'll understand the whole purpose of these protocols. 💧

### CredentialsAuthenticator

This authenticator can decode a specific `Content` from the HTTP body, so you can use the type-safe content fields right ahead. For example this comes handy when you have a login form on your website and you would like to submit the credentails through it. Regular HTML forms can send values encoded as `multipart/form-data` using the body, Vapor can decode every field on the other side. Another example is when you are sending the email, password credentials as a JSON object through a post body. `curl -X POST "URL" -d '{"email": "", "password": ""}'`

```swift
struct UserModelCredentialsAuthenticator: CredentialsAuthenticator {
    
    struct Input: Content {
        let email: String
        let password: String
    }

    typealias Credentials = Input

    func authenticate(credentials: Credentials, for req: Request) -> EventLoopFuture<Void> {
        UserModel.query(on: req.db)
            .filter(\.$email == credentials.email)
            .first()
            .map {
                do {
                    if let user = $0, try Bcrypt.verify(credentials.password, created: user.password) {
                        req.auth.login(user)
                    }
                }
                catch {
                    // do nothing...
                }
            }
    }
}
```

So as you can see most of these authenticator protocols are just helpers to transform HTTP data into Swift code. Nothing to worry about, you just have to know the right one for you needs.

So shouldn't we put the pieces together already? Yes, but if you want to know more about auth you should check the source of the [AuthenticationTests.swift](https://github.com/vapor/vapor/blob/master/Tests/VaporTests/AuthenticationTests.swift) file in the Vapor package. Now let me show you how to implement a session auth for your website.

## Session based authentication

By default sessions will be kept around until you restart the server (or it crashes). We can change this by [persisting sessions](https://github.com/vapor/fluent/blob/master/Sources/Fluent/Fluent%2BSessions.swift) to an external storage, such as a Fluent database or a redis storage. In this example I'm going to show you how to setup sessions inside a postgresql database.

```swift
import Vapor
import Fluent
import FluentPostgresDriver

extension Application {
    static let databaseUrl = URL(string: Environment.get("DB_URL")!)!
}

public func configure(_ app: Application) throws {

    try app.databases.use(.postgres(url: Application.databaseUrl), as: .psql)
    
    // setup persistent sessions
    app.sessions.use(.fluent)
    app.migrations.add(SessionRecord.migration)
}
```

Setting up persistent sessions using Fluent as a storage driver is just two lines of code. ❤️

```swift
extension UserModel: SessionAuthenticatable {
    typealias SessionID = UUID

    var sessionID: SessionID { self.id! }
}

struct UserModelSessionAuthenticator: SessionAuthenticator {

    typealias User = UserModel
    
    func authenticate(sessionID: User.SessionID, for req: Request) -> EventLoopFuture<Void> {
        User.find(sessionID, on: req.db).map { user  in
            if let user = user {
                req.auth.login(user)
            }
        }
    }
}
```

As a next step you have to extend the UserModel with the unique session details, so the system can look up users based on the session id. Lastly you have to connect the routes.

```swift
import Vapor
import Fluent

func routes(_ app: Application) throws {

    let session = app.routes.grouped([
        SessionsMiddleware(session: app.sessions.driver),
        UserModelSessionAuthenticator(),
        UserModelCredentialsAuthenticator(),
    ])

    session.get { req -> Response in
        guard let user = req.auth.get(UserModel.self) else {
            return req.redirect(to: "/sign-in")
        }

        let body = """
        <b>\(user.email)</b> is logged in <a href="/logout">Logout</a>
        """

        return .init(status: .ok,
              version: req.version,
              headers: HTTPHeaders.init([("Content-Type", "text/html; charset=UTF-8")]),
              body: .init(string: body))
    }
    
    session.get("sign-in") { req -> Response in
        let body = """
        <form action="/sign-in" method="post">
            <label for="email">Email:</label>
            <input type="email" id="email" name="email" value="">
            
            <label for="password">Password:</label>
            <input type="password" id="password" name="password" value="">
            
            <input type="submit" value="Submit">
        </form>
        """

        return .init(status: .ok,
              version: req.version,
              headers: HTTPHeaders.init([("Content-Type", "text/html; charset=UTF-8")]),
              body: .init(string: body))
    }

    session.post("sign-in") { req -> Response in
        guard let user = req.auth.get(UserModel.self) else {
            throw Abort(.unauthorized)
        }
        req.session.authenticate(user)
        return req.redirect(to: "/")
    }
    
    session.get("logout") { req -> Response in
        req.auth.logout(UserModel.self)
        req.session.unauthenticate(UserModel.self)
        return req.redirect(to: "/")
    }

}
```

First we setup the session routes by adding the sessions middleware using the database storage driver. Next we create an endpoint where we can display the profile if the user is authenticated, otherwise we redirect to the sign-in screen. The get sign in screen renders a basic HTML form (you can also use the Leaf templating engine for a better looking view) and the post sign-in route handles the authentication process. The `req.session.authenticate` method will store the current user info in the session storage. The logout route will remove the current user from the auth store, plus we'd also like to remove the associated user link from the session storage. That's it. 😎

## JWT based authentication

Vapor 4 comes with great JWT support as an external Swift package:

```swift
// swift-tools-version:5.2
import PackageDescription

let package = Package(
    //...
    dependencies: [
        //...
        .package(url: "https://github.com/vapor/jwt.git", from: "4.0.0-rc.1"),
    ],
    targets: [
        .target(name: "App", dependencies: [
            .product(name: "JWT", package: "jwt"),
            //...
        ]),
        //...
    ]
)
```

In order to use sign and verify JWTs you'll need a key-pair. The lib can generate one for you on the fly, but that's not going to work so well, because each time you restart the application a new public and private key will be used in the core of the JWT signer. It's better to have one sitting somewhere on the disk, you can generate one ([RS256](https://community.auth0.com/t/jwt-signing-algorithms-rs256-vs-hs256/7720)) by running:

```sh
ssh-keygen -t rsa -b 4096 -m PEM -f jwtRS256.key
openssl rsa -in jwtRS256.key -pubout -outform PEM -out jwtRS256.key.pub
```

I usually put thes generated files into my working directory. Since the algorithm (RS256) I'm using to sign the token is asymmetric I'll create 2 signers with different identifiers. A private signer is used to sign JWTs, a public one is used to verify the signature of the incoming JWTs.

```swift
import Vapor
import JWT

extension String {
    var bytes: [UInt8] { .init(self.utf8) }
}

extension JWKIdentifier {
    static let `public` = JWKIdentifier(string: "public")
    static let `private` = JWKIdentifier(string: "private")
}

public func configure(_ app: Application) throws {
    
    //...

    let privateKey = try String(contentsOfFile: app.directory.workingDirectory + "jwtRS256.key")
    let privateSigner = try JWTSigner.rs256(key: .private(pem: privateKey.bytes))
    
    let publicKey = try String(contentsOfFile: app.directory.workingDirectory + "jwtRS256.key.pub")
    let publicSigner = try JWTSigner.rs256(key: .public(pem: publicKey.bytes))
     
    app.jwt.signers.use(privateSigner, kid: .private)
    app.jwt.signers.use(publicSigner, kid: .public, isDefault: true)
}
```

Verifying and signing a token is just a one-liner. You can use some of the authenticators from above to pass around a token to the request handler, somewhat the same way as we did it in the sessions example. However you'll need to define a custom `JWTPayload` object that contains all the fields used in the token. This payload protocol should implement a verify method that can help you with the verification process. Here's a really simple example how to sign and return a JWTPayload:

```swift
import Vapor
import JWT

struct Example: JWTPayload {
    var test: String

    func verify(using signer: JWTSigner) throws {}
}

func routes(_ app: Application) throws {
    let jwt = app.grouped("jwt")

    jwt.get { req in
        // sign the payload using the private key
        try req.jwt.sign(Example(test: "Hello world!"), kid: .private)

        // verify a token using the public key
        //try request.jwt.verify(token, as: Example.self)
    }
}
```

A payload contains small pieces of information ([claims](https://www.iana.org/assignments/jwt/jwt.xhtml)). Each of them can be verified through the previously mentioned verify method. The good thing is that the JWT package comes with lots of handy claim types (including validators), feel free to pick the ones you need from the package (`JWTKit/Sources/Claims` directory). Since there are no official docs yet, you should check the source in this case, but don't be afraid claims are very easy to understand. 🤐

```swift
struct TestPayload: JWTPayload, Equatable {
    var sub: SubjectClaim // a subject claim
    var name: String
    var admin: Bool
    var exp: ExpirationClaim // an expiration claim

    func verify(using signer: JWTSigner) throws {
        try self.exp.verifyNotExpired()
    }
}
let payload = TestPayload(sub: "vapor",
                          name: "Foo",
                          admin: false,
                          exp: .init(value: .init(timeIntervalSince1970: 2_000_000_000)))

let signed = try app.jwt.signers.get(kid: .private)!.sign(payload)

// Verification tests:
//print(try! app.jwt.signers.get()!.verify(signed.bytes, as: TestPayload.self) == payload)
//print(try! app.jwt.signers.get(kid: .private)!.verify(signed.bytes, as: TestPayload.self) == payload)
```

Tokens can be verified using both the public & the private keys. The public key can be shared with anyone, but you should NEVER give away the private key. There is an best practice to share keys with other parties called: [JWKS](https://auth0.com/docs/tokens/concepts/jwks). Vapor comes with JWKS support, so you can load keys from a remote URLs using this method. This time I won't get into the details, but I promise that I'm going to make a post about how to use JWKS endpoints later on (Sign in with Apple tutorial). 🔑

Based on this article now you should be able to write your own authentication layer that can utilize a JWT token as a key. A possible authenticator implementation could look like this:

```swift
extension UserModel: Authenticatable {}

struct JWTUserModelBearerAuthenticator: BearerAuthenticator {
    typealias User = UserModel
    
    func authenticate(bearer: BearerAuthorization, for request: Request) -> EventLoopFuture<User?> {
        do {
            let jwt = try request.jwt.verify(bearer.token, as: JWTAuth.self)
            return User.find(UUID(uuidString: jwt.userId), on: request.db)
        }
        catch {
            return request.eventLoop.makeSucceededFuture(nil)
        }
    }
}
```

The other thing that you'll need is an endpoint that can exchange a JWT for the login credentials. You can use some other authenticators to support multiple authentication methods, such as basic or credentials. Don't forget to guard the protected routes using the correct middleware. 🤔

## Conclusion

Authentication is a really heavy topic, but fortunately Vapor helps a lot with the underlying tools. As you can see I tried to cover a lot in this artilce, but still I could write more about JWKS, OAuth, etc.

I really hope that you'll find this article useful to understand the basic concepts. The methods described here are not bulletproof, the purpose here is not to demonstrate a secure layer, but to educate people about how the authentication layer works in Vapor 4. Keep this in mind. 🙏
