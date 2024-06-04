---
slug: beginners-guide-to-swift-macros
title: Beginner's guide to Swift macros
description: Learn how to create and publish your very first macro using SPM and the brand new Macro APIs introduced in Swift 5.9.
coverImage: ./beginners-guide-to-swift-macros/cover.jpg
publication: 2023-06-07 14:57:12
tags:
  - swift
  - macros
authors:
  - tibor-bodecs
---

## Getting started

First of all, you'll need to install Swift 5.9 to take advantage of the new macro system. You can download Xcode 15 (currently in beta) from Apple's [developer protal](https://developer.apple.com/develop/) or you can get the latest snapshot version of the Swift toolchain from [swift.org](https://www.swift.org/download/#snapshots).

In order to create and use a macro you have to create a new Swift package, using the [package manager](https://www.swift.org/package-manager/). I'm going to do this without Xcode, I'll place a `Package.swift` file into a new `macro-examples` folder.

To speed up the project creation process, just run the following command using the Terminal application. 🤓

```sh
mkdir -p macro-examples && cd $_
mkdir -p Sources
mkdir -p Sources/Examples
mkdir -p Sources/MyMacros
mkdir -p Sources/MyMacrosPlugin
mkdir -p Sources/MyMacrosPlugin/Macros
mkdir -p Tests
mkdir -p Tests/MyMacrosTests
touch Package.swift
touch Sources/Examples/main.swift
touch Sources/MyMacros/MyMacros.swift
touch Sources/MyMacrosPlugin/MyMacrosPlugin.swift
touch Sources/MyMacrosPlugin/Macros/InitMacro.swift
touch Tests/MyMacrosTests/MyMacrosTests.swift
```

Update the contents of the `Package.swift` file. We're going to add the brand new `CompilerPluginSupport` framework, and the open source [swift-syntax](https://github.com/apple/swift-syntax) library as a dependency, this way we can setup a new macro target.

The `Examples` target is literally just a sample target to try out the macros, the `MyMacros` target will contain our macro definitions. The actual macro implementations will live in a separate macro target called `MyMacroPlugins`. Of course we're going to validate the macros, unit tests are going to be placed inside the `MyMacrosTests` target. ✅

```swift
// swift-tools-version: 5.9
import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "macro-examples",
    platforms: [
        .macOS(.v12),
    ],
    products: [
        .executable(
            name: "Examples",
            targets: ["Examples"]
        ),
        .library(
            name: "MyMacros",
            targets: ["MyMacros"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-syntax",
            branch: "main"
        ),
    ],
    targets: [
        .macro(
            name: "MyMacrosPlugin",
            dependencies: [
                .product(
                  name: "SwiftSyntax",
                  package: "swift-syntax"
                ),
                .product(
                  name: "SwiftSyntaxMacros",
                  package: "swift-syntax"
                ),
                .product(
                  name: "SwiftOperators",
                  package: "swift-syntax"
                ),
                .product(
                  name: "SwiftParser",
                  package: "swift-syntax"
                ),
                .product(
                  name: "SwiftParserDiagnostics",
                  package: "swift-syntax"
                ),
                .product(
                  name: "SwiftCompilerPlugin",
                  package: "swift-syntax"
                ),
            ]
        ),
        .target(
            name: "MyMacros",
            dependencies: [
                "MyMacrosPlugin"
            ]
        ),
        .executableTarget(
            name: "Examples",
            dependencies: [
                "MyMacros"
            ]
        ),
        .testTarget(
            name: "MyMacrosTests",
            dependencies: [
                "MyMacrosPlugin"
            ]
        )
    ]
)
```

We're going to create an simple `@Init` macro, which can generate a public initializer for various objects based on the member properties. Feel free to place this code into the `main.swift` file under the `Examples` target.

```swift
import MyMacros
import Foundation

@Init
public struct Something: Codable {
    let foo: String
    let bar: Int
    let hello: Bool?
}

```

There is a protocol for this purpose called `MemberMacro`, which we have to implement in order to be able to access and extend the Swift syntax tree. Place the following contents into the `InitMacro.swift` file.

```swift
import SwiftSyntax
import SwiftSyntaxMacros

public struct InitMacro: MemberMacro {

    public static func expansion<D, C>(
        of node: AttributeSyntax,
        providingMembersOf decl: D,
        in context: C
    ) throws -> [SwiftSyntax.DeclSyntax]
    where D: DeclGroupSyntax, C: MacroExpansionContext {

        let members = decl.memberBlock.members
        var props: [(name: String, type: String)] = []
        for member in members {
            guard
                let v = member.decl.as(VariableDeclSyntax.self),
                let b = v.bindings.first,
                let i = b.pattern.as(IdentifierPatternSyntax.self),
                let t = b.typeAnnotation?.type
            else {
                continue
            }
            let n = i.identifier.text
            let tv = t.description
            props.append((name: n, type: tv))
        }

        let parameters = props
            .map { "\($0.name): \($0.type)"}
            .joined(separator: ",\n")

        let assignments = props
            .map { "self.\($0.name) = \($0.name)"}
            .joined(separator: "\n")

        return [
            """
            public init(
                \(raw: parameters)
            ) {
                \(raw: assignments)
            }
            """
        ]
    }
}
```

As you can see we ask the declaration for the member properties and iterate through each member. If a member has a `VariableDeclSyntax` it means it is a variable. We try to fetch the identifier using the `IdentifierPatternSyntax` and the type through the typeAnnotation property of the `bindings`. Don't worry if you are not familiar with the swift-syntax library, you can easily print out (e.g. `po decl`) the object graph including the type names if you put a breakpoint into the macro function implementation and run the unit tests using Xcode. `po` actually works in Xcode 15. 😍

All right, we have the macro, but we still have to list it inside the plugin target using a special `CompilerPlugin` protocol.

```swift
#if canImport(SwiftCompilerPlugin)
import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct MyMacrosPlugin: CompilerPlugin {

    let providingMacros: [Macro.Type] = [
        InitMacro.self,
    ]
}
#endif
```

Now the macro plugin target is ready, we just have to define the macro implementation inside the `MyMacros` target using `#externalMacro`, and reference the target module & macro type. Our macro will be an `@attached(member)` macro which is going to implement the `init` method.

```swift
import Foundation

@attached(member, names: named(init))
public macro Init() = #externalMacro(
    module: "MyMacrosPlugin",
    type: "InitMacro"
)
```

You can learn more about the available macro atttributes from the [WWDC23 session videos](https://developer.apple.com/search/?q=swift%20macro&type=Videos) or you can read the [vision](https://gist.github.com/DougGregor/4f3ba5f4eadac474ae62eae836328b71) for Swift macros document and [correspoinding proposals](https://www.swift.org/swift-evolution/#?search=macro) on the Swift Evolution Dashboard.

The only thing remains is the unit test for the Swift macro. It's relatively easy to write tests for macro declarations, we can simply compare the source with the generated code block.

```swift
import XCTest
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import MyMacrosPlugin

final class MyMacrosTests: XCTestCase {

    let testMacros: [String: Macro.Type] = [
        "Init": InitMacro.self,
    ]

    func testApiObjects() throws {

        let sf: SourceFileSyntax = """
        @Init
        public struct Something: Codable {
            let foo: String
            let bar: Int
            let hello: Bool?
        }
        """

        let expectation = """

        public struct Something: Codable {
            let foo: String
            let bar: Int
            let hello: Bool?
            public init(
                foo: String,
            bar: Int,
            hello: Bool?
            ) {
                self.foo = foo
            self.bar = bar
            self.hello = hello
            }
        }
        """

        let context = BasicMacroExpansionContext(
            sourceFiles: [
                sf: .init(
                    moduleName: "TestModule",
                    fullFilePath: "test.swift"
                )
            ]
        )

        let transformed = sf.expand(macros: testMacros, in: context)
        XCTAssertEqual(transformed.formatted().description, expectation)
    }
}

```

The output can be `formatted` based on your configuration, but since this is a beginner's guide tutorial we're not going into the details right now. Macros are a powerful new feature in Swift 5.9. We're going to play & experiment with them a lot more, that's for sure. I hope you get the basic idea how to setup a macro project based on this quick tutorial. 🙏
