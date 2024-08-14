---
type: post
title: Lenses and prisms in Swift
description: Beginner's guide about optics in Swift. Learn how to use lenses and prisms to manipulate objects using a functional approach.
publication: 2022-08-12 16:20:00
tags: 
    - design-pattern
authors:
    - tibor-bodecs
---

## Understanding optics

Optics is a pattern borrowed from [Haskell](https://en.wikipedia.org/wiki/Haskell), that enables you to zoom down into objects. In other words, you can set or get a property of an object in a functional way. By functional I mean you can set a property without causing mutation, so instead of altering the original object, a new one will be created with the updated property. Trust me it's not that complicated as it might sounds. 😅

We're going to need just a bit of Swift code to understand everything.

```swift
struct Address {
    let street: String
    let city: String
}

struct Company {
    let name: String
    let address: Address
}

struct Person {
    let name: String
    let company: Company
}
```

As you can see it is possible to build up a hierarchy using these structs. A person can have a company and the company has an address, for example:

```swift
let oneInfiniteLoop = Address(street: "One Infinite Loop", city: "Cupertino")
let appleInc = Company(name: "Apple Inc.", address: oneInfiniteLoop)
let steveJobs = Person(name: "Steve Jobs", company: appleInc)
```


Now let's imagine that the street name of the address changes, how do we alter this one field and propagate the property change for the entire structure? 🤔

```swift
struct Address {
    var street: String
    let city: String
}

struct Company {
    let name: String
    var address: Address
}

struct Person {
    let name: String
    var company: Company
}

var oneInfiniteLoop = Address(street: "One Infinite Loop", city: "Cupertino")
var appleInc = Company(name: "Apple Inc.", address: oneInfiniteLoop)
var steveJobs = Person(name: "Steve Jobs", company: appleInc)

oneInfiniteLoop.street = "Apple Park Way"
appleInc.address = oneInfiniteLoop
steveJobs.company = appleInc

print(steveJobs) // address is updated
```

In order to update the street property we had to do quite a lot of work, first we had to change some of the properties to variables, and we also had to manually update all the references, since structs are not reference types, but value types, hence copies are being used all around.

This looks really bad, we've also caused quite a lot of mutation and now others can also change these variable properties, which we don't necessary want. Is there a better way? Well...

```swift
let newSteveJobs = Person(
    name: steveJobs.name,
    company: Company(
        name: appleInc.name,
        address: Address(
            street: "Apple Park Way",
            city: oneInfiniteLoop.city
        )
    )
)
```

Ok, this is ridiculous, can we actually do something better? 🙄

## Lenses

We can use a [lens](https://chris.eidhof.nl/post/lenses-in-swift/) to zoom on a property and use that lens to construct complex types. A lens is a value representing maps between a complex type and one of its property.

Let's keep it simple and define a Lens struct that can transform a whole object to a partial value using a getter, and set the partial value on the entire object using a setter, then return a new "whole object". This is how the lens definition looks like in Swift.

```swift
struct Lens<Whole, Part> {
    let get: (Whole) -> Part
    let set: (Part, Whole) -> Whole
}
```

Now we can create a [lens that zooms](https://te.xel.io/posts/2016-04-30-lambda-fu-powerup-lenses-prisms-and-optics-with-swift.html) on the street property of an address and construct a new address using an existing one.

```swift
let oneInfiniteLoop = Address(street: "One Infinite Loop", city: "Cupertino")
let appleInc = Company(name: "Apple Inc.", address: oneInfiniteLoop)
let steveJobs = Person(name: "Steve Jobs", company: appleInc)

let addressStreetLens = Lens<Address, String>(get: { $0.street },
                                              set: { Address(street: $0, city: $1.city) })


let newSteveJobs = Person(name: steveJobs.name,
                          company: Company(name: appleInc.name,
                                           address: addressStreetLens.set("Apple Park Way", oneInfiniteLoop)))
```

Let's try to build lenses for the other properties as well.

```swift
let oneInfiniteLoop = Address(street: "One Infinite Loop", city: "Cupertino")
let appleInc = Company(name: "Apple Inc.", address: oneInfiniteLoop)
let steveJobs = Person(name: "Steve Jobs", company: appleInc)

let addressStreetLens = Lens<Address, String>(get: { $0.street },
                                              set: { Address(street: $0, city: $1.city) })

let companyAddressLens = Lens<Company, Address>(get: { $0.address },
                                                set: { Company(name: $1.name, address: $0) })

let personCompanyLens = Lens<Person, Company>(get: { $0.company },
                                              set: { Person(name: $1.name, company: $0) })

let newAddress = addressStreetLens.set("Apple Park Way", oneInfiniteLoop)
let newCompany = companyAddressLens.set(newAddress, appleInc)
let newPerson = personCompanyLens.set(newCompany, steveJobs)

print(newPerson)
```

This might looks a bit strange at first sight, but we're just scratching the surface here. It is possible to compose lenses and create a transition from an object to another property inside the hierarchy.

```swift
struct Lens<Whole, Part> {
    let get: (Whole) -> Part
    let set: (Part, Whole) -> Whole
}

extension Lens {
    func transition<NewPart>(_ to: Lens<Part, NewPart>) -> Lens<Whole, NewPart> {
        .init(get: { to.get(get($0)) },
              set: { set(to.set($0, get($1)), $1) })
    }

}

// ...

let personStreetLens = personCompanyLens.transition(companyAddressLens)
                                        .transition(addressStreetLens)


let newPerson = personStreetLens.set("Apple Park Way", steveJobs)

print(newPerson)
```

So in our case we can come up with a transition method and create a lens between the person and the street property, this will allow us to directly modify the street using this newly created lens.

Oh, by the way, we can also extend the original structs to provide these lenses by default. 👍

```swift
extension Address {
    struct Lenses {
        static var street: Lens<Address, String> {
            .init(get: { $0.street },
                  set: { Address(street: $0, city: $1.city) })
        }
    }
}

extension Company {

    struct Lenses {
        static var address: Lens<Company, Address> {
            .init(get: { $0.address },
                  set: { Company(name: $1.name, address: $0) })
        }
    }
}

extension Person {

    struct Lenses {
        static var company: Lens<Person, Company> {
            .init(get: { $0.company },
                  set: { Person(name: $1.name, company: $0) })
        }
        
        static var companyAddressStreet: Lens<Person, String> {
            Person.Lenses.company
                .transition(Company.Lenses.address)
                .transition(Address.Lenses.street)
        }
    }

}

let oneInfiniteLoop = Address(street: "One Infinite Loop", city: "Cupertino")
let appleInc = Company(name: "Apple Inc.", address: oneInfiniteLoop)
let steveJobs = Person(name: "Steve Jobs", company: appleInc)

let newPerson = Person.Lenses.companyAddressStreet.set("Apple Park Way", steveJobs)

print(newPerson)
```

On the call site we were able to use one single line to update the street property of an immutable structure, of course we're creating a new copy of the entire object, but that's good since we wanted to avoid mutations. Of course we have to create quite a lot of lenses to make this magic happen under the hood, but sometimes it is worth the effort. ☺️

## Prisms

Now that we know how to set properties of a struct hierarchy using a lens, let me show you one more data type that we can use to alter enum values. Prisms are just like lenses, but they work with [sum types](https://mislavjavor.github.io/2017-04-19/Swift-enums-are-sum-types.-That-makes-them-very-interesting/). Long story short, enums are sum types, structs are product types, and the main difference is how many unique values can you represent with them.

```swift
// 512 possible values (= 2 * 256)
struct ProductExample {
    let a: Bool // 2 possible values
    let b: Int8 // 256 possible values
}


// 258 possible values (= 2 + 256)
enum SumExample {
    case a(Bool) // 2 possible values
    case b(Int8) // 256 possible values
}
```

Another difference is that a prism getter can return a nil value and the setter can "fail", this means if it is not possible to set the value of the property it'll return the original data value instead.

```swift
struct Prism<Whole, Part> {
    let tryGet: (Whole) -> Part?
    let inject: (Part) -> Whole
}
```

This is how we can implement a prism, we call the getter tryGet, since it returns an optional value, the setter is called inject because we try to inject a new partial value and return the whole if possible. Let me show you an example so it'll make more sense.

```swift
enum State {
    case loading
    case ready(String)
}

extension State {

    enum Prisms {
        static var loading: Prism<State, Void> {
            .init(tryGet: {
                guard case .loading = $0 else {
                    return nil
                }
                return ()
            },
            inject: { .loading })
        }
        
        static var ready: Prism<State, String> {
            .init(tryGet: {
                guard case let .ready(message) = $0 else {
                    return nil
                }
                return message
            },
            inject: { .ready($0) })
        }
    }
}
```

we've created a simple State enum, plus we've extended it and added a new Prism namespace as an enum with two static properties. ExactlyOne static prism for every case that we have in the original State enum. We can use these prisms to check if a given state has the right value or construct a new state using the inject method.

```swift
// create enums cases the regular way
let loadingState = State.loading
let readyState = State.ready("I'm ready.")

// this creates a new loading state using the prism
let newLoadingState = State.Prisms.loading.inject(())
// this creates a new ready state with a given value
let newReadyState = State.Prisms.ready.inject("Hurray!")


// trying to access the ready message through the prism
let nilMessage = State.Prisms.ready.tryGet(loadingState)
print(nilMessage)

// returns the message if the state has a ready value
let message = State.Prisms.ready.tryGet(readyState)
print(message)
```

The syntax seems like a bit strange at the first sight, but trust me Prisms can be very useful. You can also apply transformations on prisms, but that's a more advanced topic for another day.

Anyway, this time I'd like to stop here, since optics are quite a huge topic and I simply can't cover everything in one article. Hopefully this little article will help you to understand lenses and prisms just a bit better using the Swift programming language. 🙂
