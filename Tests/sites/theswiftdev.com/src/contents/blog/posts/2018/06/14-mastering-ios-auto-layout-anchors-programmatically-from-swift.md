---
slug: mastering-ios-auto-layout-anchors-programmatically-from-swift
title: Mastering iOS auto layout anchors programmatically from Swift
description: Looking for best practices of using layout anchors? Let's learn how to use the iOS autolayout system in the proper way using Swift.
publication: 2018-06-14 16:20:00
tags: UIKit, iOS
---

## Creating views and constraints programmatically

First of all I'd like to recap the `UIViewController` life cycle methods, you are might familiar with some of them. They are being called in the following order:

- loadView
- viewDidLoad
- viewWillAppear
- viewWillLayoutSubviews
- viewDidLayoutSubviews
- viewDidAppear

In the pre-auto layout era, you had to do your layout calculations inside the `viewDidLayoutSubviews` method, but since this is a [pro auto layout tutorial](https://theswiftdev.com/2017/10/31/ios-auto-layout-tutorial-programmatically/) we are only going to focus on the `loadView` & `viewDidLoad` methods. 🤓

These are the basic rules of creating view hierarchies using auto layout:

- Never calculate frames manually by yourself!
- Initialize your views with `.zero` rect frame
- Set `translatesAutoresizingMaskIntoConstraints` to false
- Add your view to the view hierarchy using `addSubview`
- Create and activate your layout constraints `NSLayoutConstraint.activate`
- Use `loadView` instead of `viewDidLoad` for creating views with constraints
- Take care of memory management by using weak properties
- Set every other property like background color, etc. in `viewDidLoad`

Enough theory, here is a short example:

```swift
class ViewController: UIViewController {

    weak var testView: UIView!

    override func loadView() {
        super.loadView()

        let testView = UIView(frame: .zero)
        testView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(testView)
        NSLayoutConstraint.activate([
            testView.widthAnchor.constraint(equalToConstant: 64),
            testView.widthAnchor.constraint(equalTo: testView.heightAnchor),
            testView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            testView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
        ])
        self.testView = testView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.testView.backgroundColor = .red
    }
}
```

Pretty simple, huh? Just a few lines of code and you have a fixed size center aligned view with a dedicated class property reference. If you create the exact same through interface builder, the system will "make" you the `loadView` method for free, but you'll have to setup an `IBOutlet` reference to the view.

> The eternal dilemma: code vs Interface Builder.

It really doesn't matters, feel free to chose your path. Sometimes I love playing around with IB, but in most of the cases I prefer the programmatic way of doing things. 😛

## Common UIKit auto layout constraint use cases

So I promised that I'll show you how to make constraints programmatically, right? Let's do that now. First of all, I use nothing but layout anchors. You could waste your time with the [visual format language](https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/AutolayoutPG/VisualFormatLanguage.html), but that's definitely a dead end. So mark my words: use only anchors or stack views, but nothing else! 😇

Here are the most common patterns that I use to create nice layouts. 😉

### Set fixed with or height

First one is the most simple one: set a view's height or a width to a fixed point.

```swift
testView.widthAnchor.constraint(equalToConstant: 320),
testView.heightAnchor.constraint(equalToConstant: 240),
```

### Set aspect ratio

Settings a view's aspect ratio is just constrainting the width to the height or vica versa, you can simply define the rate by the multiplier.

```swift
testView.widthAnchor.constraint(equalToConstant: 64),
testView.widthAnchor.constraint(equalTo: testView.heightAnchor, multiplier: 16/9),
```

### Center horizontally & vertically

Centering views inside another one is a trivial task, there are specific anchors for that.

```swift
testView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
testView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
```

### Stretch or fill inside view with padding

The only tricky part here is that trailing and bottom constraints behave a little bit different, than top & leading if it comes to the constants. Usually you have to work with negative values, but after a few tries you'll understand the logic here. 😅

```swift
testView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 32),
testView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 32),
testView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -32),
testView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -32),
```

### Proportional width or height

If you don't want to work with constant values, you can use the multiplier.

```swift
testView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1/3),
testView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 2/3),
```

### Using safe area layout guides

With the latest iPhone you'll need some guides in order to keep you safe from the notch. This is the reason why views have the safeAreaLayoutGuide property. You can get all the usual anchors after calling out to the safe area guide. 💪

```swift
testView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
testView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
testView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
testView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
```

## Animating layout constraints

Animation with constraints is easy, you shouldn't believe what others might say. I made some rules and an example that'll help you understanding the basic principles of animating constant values of a constraint, plus toggling various constraints. 👍

Rules:

- Use standard UIView animation with layoutIfNeeded
- Always deactivate constraints first
- Hold to your deactivated constraints strongly
- Have fun! 😛

Constraint animation example:

```swift
class ViewController: UIViewController {

    weak var testView: UIView!
    weak var topConstraint: NSLayoutConstraint!
    var bottomConstraint: NSLayoutConstraint!
    var heightConstraint: NSLayoutConstraint!

    override func loadView() {
        super.loadView()

        let testView = UIView(frame: .zero)
        testView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(testView)

        let topConstraint = testView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor)
        let bottomConstraint = testView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)

        NSLayoutConstraint.activate([
            topConstraint,
            testView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            testView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            bottomConstraint,
        ])

        let heightConstraint = testView.heightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.5)

        self.testView = testView
        self.topConstraint = topConstraint
        self.bottomConstraint = bottomConstraint
        self.heightConstraint = heightConstraint
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.testView.backgroundColor = .red

        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapped))
        self.view.addGestureRecognizer(tap)
    }

    @objc func tapped() {
        if self.topConstraint.constant != 0 {
            self.topConstraint.constant = 0
        }
        else {
            self.topConstraint.constant = 64
        }

        if self.bottomConstraint.isActive {
            NSLayoutConstraint.deactivate([self.bottomConstraint])
            NSLayoutConstraint.activate([self.heightConstraint])

        }
        else {
            NSLayoutConstraint.deactivate([self.heightConstraint])
            NSLayoutConstraint.activate([self.bottomConstraint])
        }

        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
}
```

It's not that bad, next: [adaptivity](https://developer.apple.com/design/human-interface-guidelines/ios/visual-design/adaptivity-and-layout/) and supporting multiple device screen sizes. 🤔

How to create adaptive layouts for iOS?
Even Apple is struggling with adaptive layouts in the built-in iOS applications. If you look at apps that are made with collection views - like photos - layouts are pretty okay on every device. However there are a few other ones, that - in my opinion - are horrible experiences on a bigger screen. 🤐

### Rotation support

Your first step to adaptive layout is supporting multiple device orientations. You can check my previous article about [iOS auto layout](https://theswiftdev.com/2017/10/31/ios-auto-layout-tutorial-programmatically/) there are lots of great stuff inside that article about rotation support, working with layers inside auto layout land, etc. 🌈

### Trait collections

Second step is to adapt trait collections. [UITraitCollection](https://developer.apple.com/documentation/uikit/uitraitcollection) is there for you to group all the environmental specific traits such as size classes, display scale, user interface idiom and many more. Most of the times you will have to check the vertical & horizontal size classes. There is a reference of device size classes and all the possible variations made by Apple, see the external sources section below. 😉

This little Swift code example below is demonstrating how to check size classes for setting different layouts for compact and regular screens.

```swift
class ViewController: UIViewController {

    weak var testView: UIView!

    var regularConstraints: [NSLayoutConstraint] = []
    var compactConstraints: [NSLayoutConstraint] = []

    override func loadView() {
        super.loadView()

        let testView = UIView(frame: .zero)
        testView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(testView)

        self.regularConstraints = [
            testView.widthAnchor.constraint(equalToConstant: 64),
            testView.widthAnchor.constraint(equalTo: testView.heightAnchor),
            testView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            testView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
        ]

        self.compactConstraints = [
            testView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            testView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            testView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            testView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
        ]

        self.activateCurrentConstraints()

        self.testView = testView
    }

    private func activateCurrentConstraints() {
        NSLayoutConstraint.deactivate(self.compactConstraints + self.regularConstraints)

        if self.traitCollection.verticalSizeClass == .regular {
            NSLayoutConstraint.activate(self.regularConstraints)
        }
        else {
            NSLayoutConstraint.activate(self.compactConstraints)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.testView.backgroundColor = .red
    }

    // MARK: - rotation support

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .allButUpsideDown
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }

    // MARK: - trait collections

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.activateCurrentConstraints()
    }
}
```

### Device detection

You can also check the user interface idiom through the `UIDevice` class (aka. is this freakin' device an iPhone or an iPad?) to set for example font sizes based on it. 📱

```swift
UIDevice.current.userInterfaceIdiom == .pad
```

### Screen size

Another option to figure out your environment is checking the [size of the screen](https://www.paintcodeapp.com/news/ultimate-guide-to-iphone-resolutions). You can check the native pixel count or a relative [size](https://www.kylejlarson.com/blog/ipad-screen-size-guide-web-design-tips/) based in points.

```swift
//iPhone X
UIScreen.main.nativeBounds   // 1125x2436
UIScreen.main.bounds         // 375x812
```

Usually I'm trying to keep myself to these rules. I don't really remember a scenario where I needed more than all the things I've listed above, but if you have a specific case or questions, please don't hesitate to contact me. 😉
