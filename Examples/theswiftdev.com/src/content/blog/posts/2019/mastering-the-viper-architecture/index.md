---
type: post
title: Mastering the VIPER architecture
description: Learn how to master the VIPER architectural design pattern, with some protocol oriented programming techniques using Swift.
publication: 2019-03-19 16:20:00
tags: 
   - viper
authors:
    - tibor-bodecs
---

After writing [my best practices article about VIPER](https://theswiftdev.com/2019/03/11/viper-best-practices-for-ios-developers/), I've made a few changes to the codebase. I was playing with these ideas in my mind already, but never had enough time to implement them properly. Let's me show you the changes...

## VIPER protocols

My generic issue was that I wanted to have a [common interface](https://github.com/CoreKit/VIPER) for every single module component. That's why I created simple protocols for the following:

- View
- Interactor
- Presenter
- Entity
- Router
- Module

This way for example my router objects are implementing the Router protocol, so if I make an extension on it, every single one will have that particular functionality. It's a pretty small, but very pleasant addition that makes my modules way more powerful than they were before. Honestly speaking I should have had this from the very beginning, but anyway from now on it's gona be like this. 😬

This move implied to organize my VIPER protocols into a custom framework, so I made one, with these components. You can find it on [GitHub](https://github.com/CoreKit/VIPER), it's a really basic one, feel free to use it, you just have to import VIPER in your project.

## Module protocols

Since I was using VIPER it had this great urge to implement a custom module for presenting system default alert messages on iOS. You know [UIAlertController](https://developer.apple.com/documentation/uikit/uialertcontroller) is the one I'm talking about. Actually [Robi](https://github.com/Ragnalorn) (my [true metal](https://www.youtube.com/watch?v=voxtdphvP5k) friend) suggested a surprisingly nice general solution for the problem. His idea sounded like this:

> Why don't we create a protocol for the router, so we could implement this on every other router, also we could simply call show(alert:) on them?

I loved this approach, so we've built it. Turned out, it's freakin awesome. So we introduced a new protocol for the module router, implemented a default protocol extension and voilà routers are now capable of presenting error messages.

Note that you can use the same pattern for lots of other (similar) things as well. The basic implementation looks like this one below, I hope you get the idea. 💡

```swift
import VIPER

class AlertModule: Module {
    /* ... */
}

protocol AlertModuleRouter: class {

    func show(alert: AlertEntity)
}

extension AlertModuleRouter where Self: Router {

    func show(alert: AlertEntity) {
        /* ... */
    }
}

// MARK: - other module

protocol MyModuleRouter: Router, AlertModuleRouter {

    // show(alert:) is now available from this router too
}
```

Of course this technique can work for other VIPER components as well, it's quite easy to implment and the protocol oriented approach gives us a huge win. 🏆

## Presenter to presenter interactions

I also changed my mind about the place of the delegate implementations participating in the module communication flow. In my last article I told you that I'm storing the delegate on the router, but later on I realized that delegation is mostly related to business logic, so I simply moved them to the presenter layer. Sorry about this. 🤷‍♂️

```swift
import VIPER

protocol AModulePresenterDelegate {
    func didDoSomething()
}

class AModule: Module {

    func build(with delegate: AModulePresenterDelegate? = nil) -> UIViewController {
        // insert classic viper stuff here

        presenter.delegate = delegate

        /* ... */

        return view
    }
}

class AModulePresenter: Presenter {

    func someAction() {
        self.delegate?.didDoSomething()
        self.router?.dismiss()
    }
}

// MARK: - other module

class BModulePresenter: Presenter, AModulePresenterDelegate {

    func didDoSomething() {
        print("Hello from module A!")
    }
}
```

This way you can skip the entire router layer, plus all the business related logic will be implemented in the presenter layer, which should be the only way to go. 🤪

## Entities are here to stay

Apart from the service layer sometimes it's quite useful to have an entity wrapper with some additional metadata for the model objects. That's why I also made an Entity protocol, and started to use it in my modules. For example a web view module that can open a link can have a WebViewEntity with a title and a content URL property. 😅

```swift
import VIPER

struct AlertEntity: Entity {
    let title: String
    let message: String
}
```

The sample alert module from above can use an AlertEntity with some properties that can define the title, message or the buttons. This way you don't really have to think about where to put those objects, because those are the real VIPER entities.

## IO protocols

This is a WIP (work-in-progress) idea that I'd like to try out, but the basic concept is somewhat like that I want to separate input and output protocols for VIPER module layers. Also this IO differentiation can be reflected on the service layers too (maybe the whole object "mess" from the service layer is going to be used as IO entities in the future), by mess I mean that there can be way too many objects in the Service/Objects directory, so this means that those could be also grouped by modules (aka. entities).

Anyway, I'm thinking of something like RequestEntity, ResponseEntity for service communication, and for the VIPER layer communication I could imagine two separate protocols, e.g. PresenterInput, PresenterOutput. We'll see, but at first sight, it's seems like quite an over-engineered thing (hahaha, says the VIPER advocate 😂).

## VIPER vs [put your architecture name here]

No! Please don't think that x is better than y. Architectures and design patterns are simple tools that can be utilized to make your life more easy. If you don't like x, you should try y, but you should not blame x, just because that's your personal opinion.

My current favorite architecture is VIPER, so what? Maybe in a year or two I'll go crazy in love with reactive programming. Does it really matters? I don't think so. I've learned and tried so many things during the past, that I can't even remember. 🧠

I'm also constantly trying to figure out new things, as you can see this whole [series of articles about VIPER](https://theswiftdev.com/2018/03/12/the-ultimate-viper-architecture-tutorial/) is the result of my learning progress & experiences. If you really want to master something, you should practice, research and try a lot, and most importantly be proud of your successes and stay humble at the same time. 🙏

That's it about the VIPER architecture for a while. I hope you enjoyed reading the whole series. If you have any questions, feel free to ask me through Twitter. 💭
