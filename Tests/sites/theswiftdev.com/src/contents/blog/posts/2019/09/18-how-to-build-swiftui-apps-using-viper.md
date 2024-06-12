---
slug: how-to-build-swiftui-apps-using-viper
title: How to build SwiftUI apps using VIPER?
description: In this tutorial I'll show you how to combine SwiftUI with the VIPER architecture in a real world iOS application example.
publication: 2019-09-18 16:20:00
tags: VIPER, SwiftUI
---

## SwiftUI - the new kid on the block

There are literally hundreds of SwiftUI tutorials around the web, but I was only able to find just one or two that focuses on [real world](https://mecid.github.io/2019/06/05/swiftui-making-real-world-app/) use cases instead of the smaller details like how to configure / make X in SwiftUI. Nice tutorials [@mecid](https://x.com/mecid) keep it up!

I also had my own "struggle" with SwiftUI, because [my collection view framework](https://theswiftdev.com/2019/05/23/building-input-forms-for-ios-apps/) is structured exactly the same way as you write SwiftUI code. After WWDC I was like, hell no! I'm doing the same method for months now, so why should I care? I started to believe that some Apple engineers are reading my blog. 😂

Anyway I knew at day zero that a crazy amount of new SwiftUI tutorials will arrive and everyone will be hyped about the new declarative UI framework, but honestly I already had my universal toolkit for this purpose. That's why I don't wanted to write about it. Honestly I still love Combine much more than SwiftUI. I'm also quite disappointed since CollectionView is completely missing from the framework.

Finally, just because what the heck lets try new things and I was curious about how SwiftUI can fit into my app building methodology I started to create a new VIPER template based on those kind of views. I also wanted to make a useful, scalable, modular real world application example using the new framework, which is up-to-date. A lot has changed in SwiftUI during the Xcode 11 beta period, so that's why I'm only publishing this tutorial now. Enough chatter, shouldn't we code already? 😛

## Learn a modern VIPER architecture

I've spent my last two years using the VIPER architecture. Some people say "it's way too complex" or "it's not a good fit for small teams". I can only tell them one word:

> Bullshit!

I believe that I've created a modern & relatively simple pattern that can be used for literally anything. Learning VIPER will definitely improve your code quality thanks to the clean architecture and the SOLID principles. You'll have a better understanding of how smaller pieces can work together and communicate with each other.

Isolated smaller components can speed up development, because you just have to work on a little piece at once, plus you can create tests for that particular thing, which is a huge win for testability & code coverage (you don't have to run your app all the time if you want to test something, you can work on the module you just need).

I'm usually working with a really simple code generator to fire up new modules, this way I can save a lot of time. If you have to work alone on a project the module generator and the predefined structure can even save you some more time. Also you really can't mess up things or end up with massive files if you are following the basic VIPER rules. I'll teach you my method in about 10 minutes. ⏰

## What the heck is VIPER anyway?

If you never heard about VIPER before, the first thing you should know is that a VIPER module contains the following components:

- View = UIViewController subclass or SwiftUI View
- Interactor = Provides the required data in the proper format
- Presenter = UI independent business logic (what to do exactly)
- Entity = Data objects (sometimes it's missing from the module)
- Router = Builds up the view controller hierarchy (show, present, dismiss, etc)

I always have a module file next to these ones where I define a module builder which builds up the whole thing from the components above and in that file I also define the module specific protocols. I usually name these protocols as interfaces they make it possible that any of the components can be replaced using [dependency injection](https://theswiftdev.com/2018/07/17/swift-dependency-injection-design-pattern/). This way we can test anything by using mocked objects in our unit tests.

> NOTE: Some say that a VIPER module with a Builder is called VIPER/B. I think the module file is an ideal place to store your module builder object, the module interfaces and the module delegate if you need one.

## Protocol oriented VIPER architecture

So the key is the 6 main protocol that connects View-Interactor-Presenter-Router. These protocols ensure that none of the VIPER components can see more than it's required. If you go back to [my first tutorial](https://theswiftdev.com/2018/03/12/the-ultimate-viper-architecture-tutorial/) you'll see that I made a mistake there. The thing is that you can call a method on the router through the presenter from the view, which is bad. This new approach fixes that issue. 🐛

```
View-to-Presenter
Presenter-to-View

Router-to-Presenter
Presenter-to-Router

Interactor-to-Presenter
Presenter-to-Interactor


Module
# ---
builds up pointers and returns a UIViewController


View implements View-to-Presenter
# ---
strong presenter as Presenter-to-View-interface


Presenter implements Presenter-to-Router, Presenter-to-Interactor, Presenter-to-View
# ---
strong router as Router-to-Presenter-interface
strong interactor as Interactor-to-Presenter-interface
weak view as View-to-Presenter-interface


Interactor implements Interactor-to-Presenter
# ---
weak presenter as Presenter-to-Interactor-interface


Router implemenents Presenter-to-Router
# ---
weak presenter as Presenter-to-Router-interface
```

As you can see the view (which can be a `UIViewController` subclass) holds the presenter strongly and the presenter will retain the interactor and router classes. Everything else is a weak pointer, because we don't like retain cycles. It might seems a little bit complicated at first sight, but after writing your first few modules you'll see how nice is to separate logical components from each other. 🐍

Please note that not everything is a VIPER module. Don't try to write your API communication layer or a CoreLocation service as a module, because those kind of stuff are standalone let's say: services. I'll write about them in the next one, but for now let's just focus on the anatomy of a VIPER module.

## Generic VIPER implementation in Swift 5

Are you ready to write some Swift code? All right, let's create some generic VIPER interfaces that can be extended later on, don't be afraid won't be that hard. 😉

```swift
// MARK: - interfaces

public protocol RouterPresenterInterface: class {

}

public protocol InteractorPresenterInterface: class {

}

public protocol PresenterRouterInterface: class {

}

public protocol PresenterInteractorInterface: class {

}

public protocol PresenterViewInterface: class {

}

public protocol ViewPresenterInterface: class {

}

// MARK: - viper

public protocol RouterInterface: RouterPresenterInterface {
    associatedtype PresenterRouter

    var presenter: PresenterRouter! { get set }
}

public protocol InteractorInterface: InteractorPresenterInterface {
    associatedtype PresenterInteractor

    var presenter: PresenterInteractor! { get set }
}

public protocol PresenterInterface: PresenterRouterInterface & PresenterInteractorInterface & PresenterViewInterface {
    associatedtype RouterPresenter
    associatedtype InteractorPresenter
    associatedtype ViewPresenter

    var router: RouterPresenter! { get set }
    var interactor: InteractorPresenter! { get set }
    var view: ViewPresenter! { get set }
}

public protocol ViewInterface: ViewPresenterInterface {
    associatedtype PresenterView

    var presenter: PresenterView! { get set }
}

public protocol EntityInterface {

}

// MARK: - module

public protocol ModuleInterface {

    associatedtype View where View: ViewInterface
    associatedtype Presenter where Presenter: PresenterInterface
    associatedtype Router where Router: RouterInterface
    associatedtype Interactor where Interactor: InteractorInterface

    func assemble(view: View, presenter: Presenter, router: Router, interactor: Interactor)
}

public extension ModuleInterface {

    func assemble(view: View, presenter: Presenter, router: Router, interactor: Interactor) {
        view.presenter = (presenter as! Self.View.PresenterView)

        presenter.view = (view as! Self.Presenter.ViewPresenter)
        presenter.interactor = (interactor as! Self.Presenter.InteractorPresenter)
        presenter.router = (router as! Self.Presenter.RouterPresenter)

        interactor.presenter = (presenter as! Self.Interactor.PresenterInteractor)

        router.presenter = (presenter as! Self.Router.PresenterRouter)
    }
}
```

Associated types are just placeholders for specific types, by using a generic interface design I can assemble my modules with a generic module interface extension and if some protocol is missing the app will crash just as I try to initialize the bad module.

I love this approach, because it saves me from a lot of boilerplate module builder code. Also this way everything will have a base protocol, so I can extend anything in a really neat protocol oriented way. Anyway if you don't understand generics that's not a big deal, in the actual module implementation you will barely meet them.

So how does an actual module looks like?

```swift
// TodoModule.swift

// MARK: - router

protocol TodoRouterPresenterInterface: RouterPresenterInterface {

}

// MARK: - presenter

protocol TodoPresenterRouterInterface: PresenterRouterInterface {

}

protocol TodoPresenterInteractorInterface: PresenterInteractorInterface {

}

protocol TodoPresenterViewInterface: PresenterViewInterface {

}

// MARK: - interactor

protocol TodoInteractorPresenterInterface: InteractorPresenterInterface {

}

// MARK: - view

protocol TodoViewPresenterInterface: ViewPresenterInterface {

}


// MARK: - module builder

final class TodoModule: ModuleInterface {

    typealias View = TodoView
    typealias Presenter = TodoPresenter
    typealias Router = TodoRouter
    typealias Interactor = TodoInteractor

    func build() -> UIViewController {
        let view = View()
        let interactor = Interactor()
        let presenter = Presenter()
        let router = Router()

        self.assemble(view: view, presenter: presenter, router: router, interactor: interactor)

        router.viewController = view

        return view
    }
}


// TodoPresenter.swift

final class TodoPresenter: PresenterInterface {
    var router: TodoRouterPresenterInterface!
    var interactor: TodoInteractorPresenterInterface!
    weak var view: TodoViewPresenterInterface!
}

extension TodoPresenter: TodoPresenterRouterInterface {

}

extension TodoPresenter: TodoPresenterInteractorInterface {

}

extension TodoPresenter: TodoPresenterViewInterface {

}

// TodoInteractor.swift

final class TodoInteractor: InteractorInterface {
    weak var presenter: TodoPresenterInteractorInterface!
}

extension TodoInteractor: TodoInteractorPresenterInterface {

}

// TodoRouter.swift

final class TodoRouter: RouterInterface {
    weak var presenter: TodoPresenterRouterInterface!
    weak var viewController: UIViewController?
}

extension TodoRouter: TodoRouterPresenterInterface {

}

// TodoView.swift

final class TodoView: UIViewController, ViewInterface {
    var presenter: TodoPresenterViewInterface!
}

extension TodoView: TodoViewPresenterInterface {

}
```

A VIPER module is made from five files, which is a huge improvement compared to my old method (I used 9 files for a single module, which is still better than a 2000 lines of code massive view controller, but yeah it was quite many files... 😂 ).

You can use my [VIPER protocol library](https://github.com/corekit/viper) if you want or simply copy & paste these interfaces to your project. I also have a [module generator](https://github.com/corekit/vipera) written entirely in Swift that can generate a module based on this template (or you can make your own).

## How to build VIPER interfaces?

Let me explain a sample flow real quick, consider the following example:

```swift
protocol TodoRouterPresenterInterface: RouterPresenterInterface {
    func dismiss()
}

// MARK: - presenter

protocol TodoPresenterRouterInterface: PresenterRouterInterface {

}

protocol TodoPresenterInteractorInterface: PresenterInteractorInterface {
    func didLoadWelcomeText(_ text: String)
}

protocol TodoPresenterViewInterface: PresenterViewInterface {
    func ready()
    func close()
}

// MARK: - interactor

protocol TodoInteractorPresenterInterface: InteractorPresenterInterface {
    func startLoadingWelcomeText()
}

// MARK: - view

protocol TodoViewPresenterInterface: ViewPresenterInterface {
    func setLoadingIndicator(visible: Bool)
    func setWelcomeText(_ text: String)
}
```

The view calls `ready()` on the presenter at some point in time `viewDidLoad()`, so the presenter can kick off. First it tells the view to show the loading indicator by calling setLoadingIndicator(visible: true), next asks the interactor to load the welcome text asynchronously `startLoadingWelcomeText()`. After the data arrives back to the interactor it can notify the presenter by using the `didLoadWelcomeText("")` method. The presenter can now tell the view to hide the loading indicator using the same method `setLoadingIndicator(visible: false)` this time with a false parameter and to display the welcome text by using `setWelcomeText("")`.

Another use case is that someone taps a button on the view in order to close the controller. The view calls `close()` on the presenter, and the presenter can simply call dismiss() on the router. The presenter can also do some other stuff (like cleaning up some resources) before it asks the router to dismiss the view controller.

I hope that you get the example, feel fee to implement everything by your own, it's quite a nice task to practice. Of course you can utilize blocks, promises or the brand new Combine framework to make your live more easy. You can for example auto-notify the presenter if some async data loading have finished. 😉

So now that you have a basic understanding about a modern VIPER architecture lets talk about how to replace the traditional ViewController subclass with SwiftUI.

## How to design a VIPER based SwiftUI application?

SwiftUI is quite a unique beast. View are structs so our generic VIPER protocol needs some alterations in order to make everything work.

The first thing you have to do is to get rid of the ViewPresenterInterface protocol. Next you can remove the view property from the PresenterInterface since we're going to use an observable view-model pattern to auto-update the view with data. The last modification is that you have to remove the view parameter from the default implementation of the assemble function inside the ModuleInterface extension.

So I mentioned a view-model, let's make one. For the sake of simplicity I'm going to use an error Bool to indicate if something went wrong, but you could use another view, or a standalone VIPER module that presents an alert message.

```swift
import Combine
import SwiftUI

final class TodoViewModel: ObservableObject {

    let objectWillChange = ObservableObjectPublisher()

    @Published var error: Bool = false {
        willSet {
            self.objectWillChange.send()
        }
    }

    @Published var todos: [TodoEntity] = [] {
       willSet {
            self.objectWillChange.send()
        }
    }
}
```

This class conforms to the `ObservableObject` which makes SwiftUI possible to check for updates & re-render the view hierarchy if something changed. You just need a property with the ObservableObjectPublisher type and literally `send()` a message if something will change this trigger the auto-update in your views. 🔥

The `TodoEntity` is just a basic struct that conforms to a bunch of protocols like the new Identifiable from SwiftUI, because we'd like to display entities in a list.


```swift
import Foundation
import SwiftUI

struct TodoEntity: EntityInterface, Codable, Identifiable {
    let id: Int
    let title: String
    let completed: Bool
}
```

A basic SwiftUI view will still implement the `ViewInterface` and it'll have a reference to the presenter. Our view-model property is also going to be used here marked with an `@ObservedObject` property wrapper. This is how it looks like in code so far:

```swift
import SwiftUI

struct TodoView: ViewInterface, View {

    var presenter: TodoPresenterViewInterface!

    @ObservedObject var viewModel: TodoViewModel

    var body: some View {
        Text("SwiftUI ❤️ VIPER")
    }
}
```

The presenter will also have a `weak var viewModel: TodoViewModel!` reference to be able to update the the view-model. Seems like we have a two-way communication flow between the view and the presenter by using a view-model. Looks good to me. 👍

We can also utilize the brand new `@EnvironmentObject` if we want to pass around some data in the view hierarchy. You just have to implement the same observation protocol in your environment object that we did for the view-model. For example:

```swift
import Foundation
import Combine

final class TodoEnvironment: ObservableObject {

    let objectWillChange = ObservableObjectPublisher()

    @Published var title: String = "Todo list" {
       willSet {
            self.objectWillChange.send()
        }
    }
}
```

Finally let me show you how to implement the module builder, because that's quite tricky. You have to use the new generic `UIHostingController`, which is thankfully an `UIViewController` subclass so you can return it after you finish module building.

```swift
final class TodoModule: ModuleInterface {
    typealias View = TodoView
    typealias Presenter = TodoPresenter
    typealias Router = TodoRouter
    typealias Interactor = TodoInteractor

    func build() -> UIViewController {
        let presenter = Presenter()
        let interactor = Interactor()
        let router = Router()

        let viewModel = TodoViewModel()
        let view = View(presenter: presenter, viewModel: viewModel)
            .environmentObject(TodoEnvironment())
        presenter.viewModel = viewModel

        self.assemble(presenter: presenter, router: router, interactor: interactor)

        let viewController = UIHostingController(rootView: view)
        router.viewController = viewController
        return viewController
    }
}
```

Putting together the pieces from now is just a piece of cake. If you want, you can challenge yourself to build something without downloading the [final project](https://github.com/theswiftdev/tutorials/tree/master/VIPER/VIPERAndSwiftUI). 🍰

Well, if you're not into challenges that's fine too, feel free to grab the example code from The.Swift.Dev tutorials on [GitHub](https://github.com/theswiftdev/tutorials/). It contains a nice interactor with some cool networking stuff [using URLSession and the Combine framework](https://theswiftdev.com/2019/08/15/urlsession-and-the-combine-framework/). The final SwiftUI code is just a rough implementation, because as I told you in the beginning there are really good tutorials about SwiftUI with examples.

