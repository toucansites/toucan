---
type: post
slug: styling-by-subclassing
title: Styling by subclassing
description: Learn how to design and build reusable user interface elements by using custom view subclasses from the UIKit framework in Swift.
publication: 2019-02-19 16:20:00
tags: UIKit, iOS
authors:
  - tibor-bodecs
---

## The problem: UI, UX, design

> Building user interfaces is the hardest part of the job!

In a nutshell: design is a process of figuring out the best solution that fits a specific problem. Graphic design usually means the physical drawing on a canvas or a paper. UX is literally how the user interacts with the application, in other words: the overall virtual experience of the "customer" journey. UI is the visible interface that he/she will see and interact with by touching the screen. 👆

If I have to put on the designer hat (or even the developer hat) I have to tell you that figuring out and implementing proper user interfaces is the most challenging problem in most of the cases. Frontend systems nowadays (mobile, tablet, even desktop apps) are just fancy overlays on top of some JSON data from a service / API. 🤷‍♂️

Why is it so hard? Well, I believe that if you want to be a good designer, you need a proper engineering mindset as well. You have to be capable of observing the whole system (big picture), construct consistent UI elements (that actually look the same everywhere), plan the desired experience based on the functional specification and many more. It's also quite a basic requirement to be an artist, think outside of the box, and be able to explain (describe) your idea to others. 🤯

Now tell me whose job is the hardest in the tech industry? Yep, as a gratis everyone is a designer nowadays, also some companies don't hire this kind of experts at all, but simply let the work done by the developers. Anyway, let's focus on how to create nice and reusable design implementations by using subclasses in Swift. 👍

## Appearance, themes and styles

Let me start with a confession: I barely use the [UIAppearance](https://nshipster.com/uiappearance/) API. This is a personal preference, but I like to set design properties like font, textColor, backgroundColor directly on the view instances. Although in some cases I found the appearance proxy very nice, but still a little buggy. Maybe this will change with iOS 13 and the arrival of the long awaited [dark mode](https://medium.com/@mczachurski/ios-dark-theme-9a12724c112d).

> Dear Apple please make an auto switch based on day / night cycles (you know like the sunset, sunrise option in the home app). 🌙

- Style is a collection of attributes that specify the appearance for a single view.
- Theme is a set of similar looking view styles, applied to the whole application.

Nowadays I usually create some predefined set of styling elements, most likely fonts, colors, but sometimes icons, etc. I like to go with the following structure:

Fonts

- title
- heading
- subheading
- body
- small

Colors

- title
- heading
- background

Icons

- back
- share

You can have even more elements, but for the sake of simplicity let's just implement these ones with a really simple Swift solution using nested structs:

```swift
struct App {

    struct Fonts {
        static let title = UIFont.systemFont(ofSize: 32)
        static let heading = UIFont.systemFont(ofSize: 24)
        static let subheading = UIFont.systemFont(ofSize: 20)
        static let body = UIFont.systemFont(ofSize: 16)
        static let small = UIFont.systemFont(ofSize: 14)
    }

    struct Colors {
        static let title = UIColor.blue
        static let heading = UIColor.black
        static let background = UIColor.white
    }

    struct Icons {
        static let back = UIImage(named: "BackIcon")!
        static let share = UIImage(named: "ShareIcon")!
    }

}

//usage example:
App.Fonts.title
App.Colors.background
App.Icons.back
```

This way I get a pretty simple syntax, which is nice, although this won't let me do dynamic styling, so I can not switch between light / dark [theme](https://medium.com/@martinho_t/how-i-use-uiappearance-to-manage-my-app-theme-part-1-2-1c4313e90b3a), but I really don't mind that, because in most of the cases it's not a requirement. 😅

## Structs vs enums:

I could use enums instead of structs with static properties, but in this case I like the simplicity of this approach. I don't want to mess around with raw values or extensions that accepts enums. It's just a personal preference.

What if you have to support [multiple themes](http://basememara.com/protocol-oriented-themes-for-ios-apps/)?

That's not a big issue, you can define a protocol for your needs, and implement the required theme protocol as you want. The real problem is when you have to switch between your themes, because you have to refresh / reload your entire UI. ♻️

There are some best practices, for example you can use the NSNotificationCenter class in order to notify every view / controller in your app to refresh if a theme change occurs. Another solution is to simply [reinitialize](https://theswiftdev.com/2017/10/10/swift-4-init-patterns/) the whole UI of the application, so this means you basically start from scratch with a brand new rootViewController. 😱

Anyway, check the links below if you need something like this, but if you just want to support dark mode in your app, I'd suggest to wait until the first iOS 13 beta comes out. Maybe Apple will give some shiny new API to make things easy.

## Custom views as style elements

I promised [styling](https://felginep.github.io/2019-02-19/uiview-styling-with-functions) by subclassing, so let's dive into the topic. Now that we have a good solution to define fonts, colors and other basic building blocks, it's time to apply those styles to actual UI elements. Of course you can use the [UIAppearance](https://www.raywenderlich.com/652-uiappearance-tutorial-getting-started) API, but for example you can't simply set custom [fonts](https://pspdfkit.com/blog/2018/improving-dynamic-type-support/) through the appearance proxy. 😢

Another thing is that I love consistency in design. So if a title is a blue, 32pt bold system font somewhere in my application I also expect that element to follow the same guideline everywhere else. I solve this problem by creating subclasses for every single view element that has a custom style applied to it. So for example:

- TitleLabel (blue color, 32pt system font)
- HeadingLabel (blue color, 24pt system font)
- StandardButton (blue background)
- DestructiveButton (red background)

Another good thing if you have subclasses and you're working with autolayout constraints from code, that you can put all your constraint creation logic directly into the subclass itself. Let me show you an example:

```swift
import UIKit

class TitleLabel: UILabel {

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.initialize()
    }

    init() {
        super.init(frame: .zero)

        self.initialize()
    }

    func initialize() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.textColor = App.Colors.title
        self.font = App.Fonts.title
    }

    func constraints(in view: UIView) -> [NSLayoutConstraint] {
        return [
            self.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            self.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            self.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ]
    }
}
```

As you can see I only have to set the font & textColor attributes once, so after the [view initialization](https://theswiftdev.com/2017/10/11/uikit-init-patterns/) is done, I can be sure that every single instance of TitleLabel will look exactly the same. The usage is pretty simple too, you just have to set the class name in interface builder, or you can simply create the view like this:

```swift
// loadView method in a view controller...
let titleLabel = TitleLabel()
self.view.addSubview(titleLabel)
NSLayoutConstraint.activate(titleLabel.constraints(in: self.view))
```

The thing I like the most about this approach is that my constraints are going to be just in the right place, so they won't bloat my view controller's loadView method. You can also create multiple constraint variations based on your current situation with extra parameters, so it's quite scalable for every situation. 👍

## View initialization is hard

The downside of this solution is that view initialization is kind of messed up, because of the interface builder support. You have to subclass every single view type (button, label, etc) and literally copy & paste your initialization methods again and again. I already have some articles about this, check the links below. 👇

In order to solve this problem I usually end up by creating a parent class for my own styled views. Here is an example for an abstract base class for my labels:

```swift
class Label: UILabel {

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.initialize()
    }

    init() {
        super.init(frame: .zero)

        self.initialize()
    }

    func initialize() {
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}
```

So from now on I just have to override the initialize method.

```swift
class TitleLabel: Label {

    override func initialize() {
        super.initialize()

        self.font = App.Fonts.title
        self.textColor = App.Colors.title
    }
}
```

See, it's so much better, because I don't have to deal with the required view initialization methods anymore, also auto-resizing will be off by default. ❤️

My final takeaway from this lesson is that you should not be afraid of classes and object oriented programming if it comes to the UIKit framework. Protocol oriented programming (also functional programming) is great if you use it in the right place, but since UIKit is quite an OOP framework I believe it's still better to follow these paradigms instead of choosing some hacky way. 🤪
