---
slug: the-ultimate-viper-architecture-tutorial
title: The ultimate VIPER architecture tutorial
description: Learn how to write scalable iOS code using the VIPER architecture with some MVVM and MVC tricks and coordinators in mind.
publication: 2018-03-12 16:20:00
tags: VIPER, Swift
---

## Swift design patterns and iOS architectures

A [software design pattern](https://en.wikipedia.org/wiki/Software_design_pattern) is basically a generic template of how to solve a particular - but usually local - situation. [Achitectural patterns](https://herbertograca.com/2017/07/28/architectural-styles-vs-architectural-patterns-vs-design-patterns/) have bigger impact on the whole codebase, they are high level generic templates. Please remember one thing:

> there is no such thing as a bad architecture

The weapon of choice only depends on the situation, but you know everything is relative. Let's walk through all the iOS design patterns and architectures real quick and start learning [VIPER](https://cheesecakelabs.com/blog/ios-project-architecture-using-viper/). 🐍

## Swift design patterns

Let's start with the basics, right? If we don't get into UIKit, we can find that there are many design patterns invented, maybe you know some of them already. But hey, since we don't have that much time and I'd like to talk about [VIPER](https://cheesecakelabs.com/blog/best-practices-viper-architecture/), let's check out the basic principle of building UIKit apps using the MVC pattern.

### MVC

The Model-View-Controller (Massive-View-Controller) [pattern](https://developer.apple.com/library/content/documentation/General/Conceptual/DevPedia-CocoaCore/MVC.html) is a basic concept. You have usually a huge UIViewController subclass that controls all the views and collects every model that needed to be displayed for the end user. For example you call an API endpoint using URLSession or Alamofire from the controller, do the response data validation and formatting then you implement your table or collection view delegates on the view controller, so basically all the application logic goes inside that single overstuffed miserable view controller class. Does this ring a bell for you? 🙄

### MVVM

After realizing the problem, the first thing that you can do is outsourcing the data transforming or binding part to a separate class. This is how the smart people at [Microsoft](https://msdn.microsoft.com/en-us/library/hh848246.aspx) invented the Model-View-ViewModel architecture pattern. Now you're one step closer, your data models and the views can have their "get together" on a whole new level inside shiny new files far-far away from controller land. However this pattern will not clean up all the leftovers inside the view controller. Remember that you still have to feed the view controller with data, handle all the different states.

### MVP

What if we move out all the data loading and presentation stuff from the view controller and put it into a new class magically called the Presenter? Sounds good, the view controller can own the new presenter instance and we can live happily ever after. Come on people we should really rename this to the Most Valuable Pattern ever! 😉

### The Coordinator pattern

[Say hello](https://www.raywenderlich.com/177538/coordinator-tutorial-ios-getting-started) to [The coordinator](http://khanlou.com/2015/01/the-coordinator/) by [Soroush Khanlou](https://vimeo.com/144116310). Or should I simply call this as the Inverse Model View Presenter pattern? Look, here is the deal, coordinators are on a whole new level inside of this evolution progress, but they also have too much to do. It's against the Single Responsibility principle, because now you have to manage the presentation context, the data storage, the routing and all the different states inside coordinators or sub-coordinators... but, finally your view controller is free from all the leftover baggage and it can focus directly on it's job, which is? 🙃

> To be fucking dumb.

Presenting views using UIKit related stuff, and forwarding events.

> I don't hate the design patters from above, I'm just simply trying to point out (in a funny / sarcastic way) why [VIPER was born](https://swifting.io/blog/2016/03/07/8-viper-to-be-or-not-to-be/) on the first place. 😅

Are you still with me? 😬

## The VIPER architecture

First of all DO NOT believe that [VIPER is bad](https://medium.com/@ankoma22/the-good-the-bad-and-the-ugly-of-viper-architecture-for-ios-apps-7272001b5347), just because someone misused it. I think it's a freaking amazing architecture! You just have to learn it properly, which is hard, because of the lack of good tutorials. Everyone is comparing architectures, but that's not what people should do. As far as I can see, an MVP is good for a small app with a few screens, you should never use VIPER for those apps. The real problem starts if you app grows and more and more components get into the game.

If you are planning to write a small app, just start with MVC. Later on you can fix the massive view controller problem with MVVM, but if you want to take it one level further you can always use MVP or the coordinator pattern to keep maintainability. Which is completely fine, until you realize one day that your code is stuffed with utility classes, managers, handlers and all the nonsense objects. Sounds familiar? 😅

As I mentioned this before there is no such thing as a bad architecture. There are only bad choices, which lead us to hardly maintainable codebases. So let me guide you through the most useful design pattern that you'll ever want to know in order to write truly scalable iOS applications: VIPER with module builders = VIPER(B)

### Understanding VIPER

The VIPER architecture is based on the single responsibility principle ([S.O.L.I.D.](https://en.wikipedia.org/wiki/SOLID_(object-oriented_design))) which leads us to the theory of a [clean architecture](https://8thlight.com/blog/uncle-bob/2012/08/13/the-clean-architecture.html). The core components or let's say layers of a VIPERB module are the following ones:

### View

It's the interface layer, which means [UIKit files](https://github.com/lukaszmargielewski/ViperTabbar), mostly UIViewController subclasses and all the other stuff. Views don't do anything that's related to business logic, they are just a presentation and event forwarding layer which is used by the presenter. Because the view is just a pure view controller, you can use MVVM principles or data managers to make your project even more concise.

### Interactor

The interactor is responsible for retrieving data from the model layer, and its implementation is completely independent of the user interface. It's important to remember that data managers (network, database, sensor) are not part of VIPER, so they are treated as separate components (services), coming outside from the VIPER module land and they can be [injected as dependencies](https://theswiftdev.com/2018/07/17/swift-dependency-injection-design-pattern/) for interactors.

The Interactor can prepare or transform data, that's coming from the service layer. For example it can do some sorting or filtering before asking the proper network service implementation to request or save the data. But remember that the Interactor doesn't know the view, so it has no idea how the data should be prepared for the view, that's the role of the Presenter. 🙄

### Presenter

UIKit independent class that prepares the data in the format required by the view and take decisions based on UI events from the view, that's why sometimes it's referred as an event handler. It's the core class of a VIPER module, because it also communicates with the Interactor and calls the router for wire-framing (aka. to present a new module or dismiss the current one).

It's the only class that communicates with almost all the other components. That's the ONLY job of the presenter, so it should not know anything about UIKit or low level data models. Basically it's the heart of the application, or some would say it's the place where all the business logic gets implemented. 💜

### Entity

Plain model classes used mostly by the interactor. Usually I'm defining them outside the VIPER module structure (in the service layer), because these entities are shared across the system. We could separate them by module, but usually I don't like that approach because e.g. all the CoreData models can be generated into one place. Same thing applies if you are using [Swagger](https://swagger.io/) or a similar tool.

### Router

The navigation logic of the application using UIKit classes. For example if you are using the same iPhone views in a iPad application, the only thing that might change is how the router builds up the structure. This allows you to keep everything else, but the Router untouched. It also listens for navigation flow changes from the presenter, so it'll display the proper screen if needed. Also if you need to open an external URL call UIApplication.shared.openURL(URL) inside the Router because that's also a routing action, the same logic applies for social media sharing using UIActivityViewController.

Also if you have to pass data between VIPER modules it feels like a right place to do this in the router. I usually communicate between two module using a [delegate pattern](https://theswiftdev.com/2018/06/27/swift-delegate-design-pattern/), so I picked up this habit of calling delegate functions in the router. 📲

### Builder

Some people are using the router to build the whole module, but I don't like that approach. That's why I'm always using a separate module builder class. It's only responsibility is to build the complete module by using dependency injection for all the external services. It can also build mock or other versions of the same module. That's quite helpful if it comes to unit testing. Totally makes sense. 👍

NOT everything is a VIPER module

For example if you want to create a generic subclass from a UIViewWhatever please don't try to stuff that into the components above. You should create a place outside your VIPER modules folder and put it there. There will be some use cases with specific classes that are better not to be VIPERized! 😉

## Services and application specific code

I usually have 3 separate layers in my applications. Modules, services, and app. All the VIPER modules are sitting inside the Modules folder. Everything that's network or data related goes to the Services folder (API service, core data service, location service, etc.) and later on gets used in the module builder depending the current environment (for example mock implementation for testing). All the remaining stuff like view subclassess, and other UI related objects, [app specific styling](https://theswiftdev.com/2019/02/19/styling-by-subclassing/) or design wise things are placed inside the App directory.

## How to write VIPER code?

I can't emphasize enough how important is to learn this architecture before you start using it. I believe that things can go real bad if someone misunderstands VIPER and start putting view logic in a presenter for example. If you had a previous bad experience with VIPER, think about this quote: don't blame the tool, blame the carpenter (just as [Ilya Puchka](https://x.com/ilyapuchka) wisely said on a twitter conversation). 🔨

> Every single component will just get into the right place if you follow the rules of VIPER.

### Module generation

Never start to create a VIPER module by hand, you should always use a code generator, because (unfortunately) you'll need lots of boilerplate code for each module. That seems quite unfortunate at first sight, but this is what gives the true power of this architecture. All members of your developer team will know where to look for if a specific issue occurs. If it's a view issue, you have to fix the view, if it comes to a navigation problem then it's a router problem.

There are many existing code generator solutions (one of the famous is [Generamba](https://github.com/strongself/Generamba)), but I made my own little Swift tool for [generating VIPER modules](https://github.com/binarybirds/swift-template). 

## Naming conventions

Protocols are defined for almost every VIPER component. Every protocol will be prefixed with the module name, and it won't have any other suffix except from the layer name (like MyModuleRouter, MyModulePresenter).

Default implementation is used for the basic scenario, every protocol implementation follows the ModuleName+Default+Layer naming convention. So for example MyModuleDefaultRouter or MyModuleDefaultPresenter.

### Inter-module communication using delegates

The flow is something like this:

#### Router / Presenter

The presenter can send events for the router using the router protocol definition.

#### Presenter / Interactor

The interactor can notify the presenter through the presenter's interface, and the presenter can call the interactor using the defined methods inside the interactor protocol.

#### Presenter / View

The view usually has setter methods to update it's contents defined on the view protocol. It can also notify the presenter of incoming or load events through the presenter protocol.

### Data transfer between modules

Imagine a list, you select an item and go to a new controller scene. You have to pass at least a unique identifier between VIPER modules to make this possible.

It's usually done somewhat like this:

- The view calls the didSelect method on the presenter with the id
- The presenter forwards the id to the router using the routeFor(id) method
- The router calls the builder to build a new module using the id
- The builder builds the new module using the id
- The router presents the new module using it's view (controller)
- The new module passes the id for everyone who needs it (router, presenter)
- The new module's presenter gets the id
- The new module's interactor loads the data and gives it for the presenter
- The new module's presenter gives the data for the view and presents it
- Detail screen appears with proper data.

If you are presenting a controller modally you can also pass the original router as a delegate, so you'll be able to close it properly if it's needed. 😎

### Memory management

Long story short:

- The builder holds no-one.
- The router keeps a weak reference of the view and the presenter.
- The presenter holds the router and the interactor strongly
- The interactor keeps a weak reference of the presenter
- The view keeps a strong reference of the presenter
- UIKit holds the views.

You should check this in the provided example, no leaks - I hope so - everything gets released nice and smoothly after you go back or dismiss a module. 🤞

## Final conclusion: should I learn VIPER?

Although VIPER is highly criticized because of it's complexity, all I can say it's worth the effort to learn its principles properly. You'll see that there are way more benefits of using VIPER instead of ignoring it.

### Advantages

- **Simplicity** - for large teams on complex projects
- **Scalability** - simultaneous work seamlessly
- **Reusability** - decoupled app components based on roles
- **Consistency** - module skeletons, separation of concerns
- **Clarity** - Single responsibilities (SOLID)
- **Testability** - separated small classes, TDD, better code coverage
- **Interfaces** - module independence, well defined scopes
- **Bug fixing** - easier to track issues, locate bugs and problems
- **Source control** - smaller files, less conflicts, cleaner code
- **Easy** - codebase looks similar, faster to read others work

### Drawbacks

- **Verbosity** - many files per module
- **Complexity** - many protocols and delegates
- **On-boarding** - lack of proper VIPER knowledge
- **Engagement** - VIPER is bad, because it's complex, meh!

I made a follow-up article about VIPER best practices that I've learn along the journey, you can find the sample repository on [GitHub](https://github.com/theswiftdev/tutorials/). I hope that these tutorials will help you to learn this architecture better, if you have any questions, feel free to contact me. 👨‍💻
