---
type: post
title: Everything about public and private Swift attributes
description: Have you ever heard about Swift language attributes? In this article I'm trying to gather all the @ annotations and their meanings.
publication: 2017-10-10 16:20:00
tags: 
    - swift
authors:
  - tibor-bodecs
---

## Public attributes

Public Swift language attributes are marked with the @ symbol, they are (more or less) well documented and ready for use. Here is the complete list of all the public Swift language attributes. Most of them will seem very familiar... 😉

### @IBOutlet

If you mark a property with the @IBOutlet attribute, the Interface Builder (IB) will recognize that variable and you'll be able to connect your source with your visuals through the provided "outlet" mechanism.

```swift
@IBOutlet weak var textLabel: UILabel!
```

### @IBAction

Similarly, `@IBAction` is an attribute that makes possible connecting actions sent from Interface Builder. So the marked method will directly receive the event fired up by the user interface. 🔥

```swift
@IBaction func buttonTouchedAction(_ sender: UIButton) {}
```

### @IBInspectable, @GKInspectable

Marking an NSCodable property with the `@IBInspectable` attribute will make it easily editable from the Interface Builder’s inspector panel. Using `@GKInspectable` has the same behavior as `@IBInspectable`, but the property will be exposed for the SpriteKit editor UI instead of IB. 🎮

```swift
@IBInspectable var borderColor: UIColor = .black
@GKInspectable var mass: Float = 1.21
```

### @IBDesignable

When applied to a UIView or NSView subclass, the @IBDesignable attribute lets Interface Builder know that it should display the exact view hierarchy. So basically anything that you draw inside your view will be rendered into the IB canvas.

```swift
@IBDesignable class MyCustomView: UIView { /*...*/ }
```

### @UIApplicationMain, @NSApplicationMain

With this attribute you can mark a class as the application's delegate. Usually this is already there in every AppDelegate.swift file that you'll ever create, however you can provide a main.swift file and call the [UI|NS]ApplicationMain method by hand. #pleasedontdoit 😅

### @available

With the @available attribute you can mark types available, deprecated, unavailable, etc. for specific platforms. I'm not going into the details there are some great posts about how to use the attribute with availability checkings in Swift.

```swift
@available(swift 4.1)
@available(iOS 11, *)
func avaialbleMethod() { /*...*/ }
```

### @NSCopying

You can mark a property with this attribute to make a copy of it instead of the value of the property iself. Obviously this can be really helpful when you copy reference types.

```swift
class Example: NSOBject {
    @NSCopying var objectToCopy: NSObject
}
```

### @NSManaged

If you are using Core Data entities (usually NSManagedObject subclasses), you can mark stored variables or instance methods as @NSManaged to indicate that the Core Data framework will dynamically provide the implementation at runtime.

```swift
class Person: NSManagedObject {
    @NSManaged var name: NSString
}
```

### @objcMembers

It's basically a convenience attribute for marking multiple attributes available for Objective-C. It's legacy stuff for Objective-C dinosaurs, with performance caveats. 🦕

```swift
@objcMembers class Person {
    var firstName: String?
    var lastName: String?
}
```

### @escaping

You can mark closure parameters as @escaping, if you want to indicate that the value can be stored for later execution, so in other words the value is allowed to outlive the lifetime of the call. 💀

```swift
var completionHandlers: [() -> Void] = []

func add(_ completionHandler: @escaping () -> Void) {
    completionHandlers.append(completionHandler)
}
```

### @discardableResult

By default the compiler raises a warning when a function returns with something, but that returned value is never used. You can suppress the warning by marking the return value discardable with this Swift language attribute. ⚠️

```swift
@discardableResult func logAdd(_ a: Int, _ b: Int) -> Int {
    let c = a + b
    print(c)
    return c
}
logAdd(1, 2)
```

### @autoclosure

This attribute can magically turn a function with a closure parameter that has no arguments, but a return type, into a function with a parameter type of that original closure return type, so you can call it much more easy. 🤓

```swift
func log(_ closure: @autoclosure () -> String) {
    print(closure())
}

log("b") // it's like func log(_ value: String) { print(value) }
```

### @testable

If you mark an imported module with the @testable attribute all the internal access-level entities will be visible (available) for testing purposes. 👍

```
@testable import CoreKit
```

### @objc

This attribute tells the compiler that a declaration is available to use in Objective-C code. Optionally you can provide a single identifier that'll be the name of the Objective-C representation of the original entity. 🦖

```swift
@objc(LegacyClass)
class ExampleClass: NSObject {

    @objc private var store: Bool = false

    @objc var enabled: Bool {
        @objc(isEnabled) get {
            return self.store
        }
        @objc(setEnabled:) set {
            self.store = newValue
        }
    }

    @objc(setLegacyEnabled:)
    func set(enabled: Bool) {
        self.enabled = enabled
    }
}
```

### @nonobjc

Use this attribute to supress an implicit objc attribute. The @nonobjc attribute tells the compiler to make the declaration unavailable in Objective-C code, even though it’s possible to represent it in Objective-C. 😎

```swift
@nonobjc static let test = "test"
```

### @convention

This attribute indicate function calling conventions. It can have one parameter which indicates Swift function reference (swift), Objective-C compatible block reference (block) or C function reference (c).

```swift
// private let sysBind: @convention(c) (CInt, UnsafePointer<sockaddr>?, socklen_t) -> CInt = bind

// typealias LeagcyBlock = @convention(block) () -> Void
// let objcBlock: AnyObject = ... // get real ObjC object from somewhere
// let block: (() -> Void) = unsafeBitCast(objcBlock, to: LeagcyBlock.self)
// block()

func a(a: Int) -> Int {
    return a
}
let exampleSwift: @convention(swift) (Int) -> Int = a
exampleSwift(10)
```

## Private attributes

Private Swift language attributes should only be used by the creators of the language, or hardcore developers. They usually provide extra (compiler) functionality that is still work in progress, so please be very careful... 😳

Please do not use private attributes in production code, unless you really know what you are doing!!! 😅

### @\_exported

If you want to import an external module for your whole module you can use the `@_exported` keyword before your import. From now the imported module will be available everywhere. Remember PCH files? 🙃

```swift
@_exported import UIKit
```

### @inline


With the @inline attribute you explicitly tell the compiler the function inlining behavior. For example if a function is small enough or it's only getting called a few times the compiler is maybe going to inline it, unless you disallow it explicitly.

```swift
@inline(never) func a() -> Int {
    return 1
}

@inline(__always) func b() -> Int {
    return 2
}

@_inlineable public func c() {
    print("c")
}
c()
```

@inlinable is the future (@\_inlineable) by Marcin Krzyzanowskim 👏

### @effects

The @effects attribute describes how a function affects "the state of the world". More practically how the optimizer can modify the program based on information that is provided by the attribute.
You can find the corresponding docs here.

```swift
@effects(readonly) func foo() { /*...*/ }
```

### @\_transparent

Basically you can force inlining with the @\_transparent attribute, but please read the unofficial documentation for more info.

```swift
@_transparent
func example() {
    print("example")
}
```

### @\_specialize

With the @\_specialize Swift attribute you can give hints for the compiler by listing concrete types for the generic signature. More detailed docs are here.

```swift
struct S<T> {
  var x: T
  @_specialize(where T == Int, U == Float)
  mutating func exchangeSecond<U>(_ u: U, _ t: T) -> (U, T) {
    x = t
    return (u, x)
  }
}

// Substitutes: <T, U> with <Int, Float> producing:
// S<Int>::exchangeSecond<Float>(u: Float, t: Int) -> (Float, Int)
```

### @\_semantics

The Swift optimizer can detect code in the standard library if it is marked with special attributes @\_semantics, that identifies the functions.
You can read about semantics here and here, or inside this concurrency proposal.

```swift
@_semantics("array.count")
func getCount() -> Int {
    return _buffer.count
}
```

### @silgenname

This attribute specifies the name that a declaration will have at link time.
You can read about it inside the Standard Librery Programmers Manual.

```swift
@_silgen_name("_destroyTLS")
internal func _destroyTLS(_ ptr: UnsafeMutableRawPointer?) {
  // ... implementation ...
}
```

### @\_cdecl

Swift compiler comes with a built-in libFuzzer integration, which you can use with the help of the @\_cdecl annotation. You can learn more about libFuzzer here.

```swift
@_cdecl("LLVMFuzzerTestOneInput") 
public func fuzzMe(Data: UnsafePointer<CChar>, Size: CInt) -> CInt{
    // Test our code using provided Data.
  }
}
```

## Unavailable, undocumented, unknown

As you can see this is already quite a list, but there is even more. Inside the official Swift repository you can find the attr tests. If you need more info about the remaining Swift annotations you can go directly there and check the source code comments. If you could help me writing about the leftovers, please drop me a few lines, I'd really appreciate any help. 😉👍

- @requiresstoredproperty_inits
- @warnunqualifiedaccess
- @fixedlayout
- @\_versioned
- @showin_interface
- @\_alignment
- @objcnonlazy_realization
- @\_frozen
- @\_optimize(none|speed|size)
- @\_weakLinked
- @consuming
- @\_restatedObjCConformance
- @\_staticInitializeObjCMetadata
- @setterAccess
- @rawdoccomment
- @objc_bridged
- @noescape -> removed, see @escaping
- @noreturn -> removed, see Never type
- @downgradeexhaustivity_check -> no effect on switch case anymore?
- @\_implements(...) - @implements(Equatable, ==(:_:))
- @swiftnativeobjcruntime_base(class)

The @\_implements attribute, which treats a `decl` as the implementation for some named protocol requirement (but otherwise not-visible by that name).

This attribute indicates a class that should be treated semantically as a native Swift root class, but which inherits a specific Objective-C class at runtime. For most classes this is the runtime's "SwiftObject" root class. The compiler does not need to know about the class; it's the build system's responsibility to link against the ObjC code that implements the root class, and the ObjC implementation's responsibility to ensure instances begin with a Swift-refcounting-compatible object header and override all the necessary `NSObject` refcounting methods.

This allows us to subclass an Objective-C class and use the fast Swift memory allocator.
If you want to add some notes about these attributes, please contact me.
