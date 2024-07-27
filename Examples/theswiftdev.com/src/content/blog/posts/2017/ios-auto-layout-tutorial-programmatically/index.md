---
type: post
slug: ios-auto-layout-tutorial-programmatically
title: iOS Auto Layout tutorial programmatically
description: In this great iOS Auto Layout tutorial I'll teach you how to support rotation, use constraints, work with layers, animate corner radius.
publication: 2017-10-31 16:20:00
tags: iOS, UIKit, Swift
authors:
  - tibor-bodecs
---

## Rotation support

If your application is going to support multiple device orientations, you should implement the following methods inside your view controller.

```swift
class ViewController: UIViewController {

    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
}
```

Obviously you can change the return values to support not just portrait, but landscape mode as well. This is quite easy, however if your controller is embedded inside a navigation or a tab bar controller the rotation stops working. In this case, you have to subclass the UINavigationController, and you have to return the correct values from the top view controller.

```swift
class NavigationController: UINavigationController {

    override var shouldAutorotate: Bool {
        if let shouldRotate = topViewController?.shouldAutorotate {
            return shouldRotate
        }
        return super.shouldAutorotate
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if let orientation = topViewController?.supportedInterfaceOrientations {
            return orientation
        }
        return super.supportedInterfaceOrientations
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        if let orientation = topViewController?.preferredInterfaceOrientationForPresentation {
            return orientation
        }
        return super.preferredInterfaceOrientationForPresentation
    }
}
```

The same logic applies if you have a UITabBarController, but instead of the top view controller, you have to use the selectedIndex, and return the properties based on the selected view controller.

```swift
class TabBarController: UITabBarController {

    override var shouldAutorotate: Bool {
        if let viewController = viewControllers?[selectedIndex] {
            return viewController.shouldAutorotate
        }
        return super.shouldAutorotate
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if let viewController = viewControllers?[selectedIndex] {
            return viewController.supportedInterfaceOrientations
        }
        return super.supportedInterfaceOrientations
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        if  let viewController = viewControllers?[selectedIndex] {
            return viewController.preferredInterfaceOrientationForPresentation
        }
        return super.preferredInterfaceOrientationForPresentation
    }
}
```

This way your embedded controller can control the supported orientations. Oh, by the way you can use this method to change the status bar style.

## Constraints

In order to [understand constraints](https://developer.apple.com/library/content/documentation/UserExperience/Conceptual/AutolayoutPG/) and the current state of the [Auto Layout engine](https://www.raywenderlich.com/160527/auto-layout-tutorial-ios-11-getting-started), we should go back to in time and start the story from the beginning.

### Springs and struts

Remember the first iPhone? One screen to rule them all! `320x480`, no constraints, no adaptivity, just frames and bounds. Positioning views on a fixed size canvas is absolutely a no-brainer, here is an example.

```swift
class ViewController: UIViewController {

    weak var square: UIView!

    var squareFrame: CGRect {
        let midX = view.bounds.midX
        let midY = view.bounds.midY
        let size: CGFloat = 64
        return CGRect(
            x: midX-size/2, 
            y: midY-size/2, 
            width: size, 
            height: size
        )
    }

    override func loadView() {
        super.loadView()

        let square = UIView()
        view.addSubview(square)
        square = square
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        square.backgroundColor = .yellow
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        square.frame = squareFrame
    }
}
```

With the `viewDidLayoutSubviews` method it's super convenient to support rotation, I just have to re-calculate the frame of the view every time if the bounding rectangle changes. You might think hey, this is easy, but what happens if you have to support lots of device sizes?

> Do the math!

For one single object it's so easy to make the calculations, but usually you have more than one view on screen. Those views can have relations to each other, and a simple math trick can lead you to a complete chaos of frame calculations, do you even like mathematics? There must be a better way!

## Auto Layout

With iOS6 Apple brought us the holy grail of layout technologies. It was the perfect successor of the previous system. Everyone adopted it fast, that's why Apple engineers completely removed frame based layout APIs in the next release... `#justkidding`

Apart from the joke, it was the beginning of a new era, more and more devices were born, and with Auto Layout constraints it was super easy to maintain views. Now we should refactor the previous example with layout constraints.

```swift
class ViewController: UIViewController {

    weak var square: UIView!

    override func loadView() {
        super.loadView()

        let square = UIView()
        view.addSubview(square)
        square.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints([
            NSLayoutConstraint(
                item: square, 
                attribute: .width, 
                relatedBy: .equal, 
                toItem: nil, 
                attribute: .width, 
                multiplier: 1.0, 
                constant: 64
            ),
            NSLayoutConstraint(
                item: square, 
                attribute: .height, 
                relatedBy: .equal, 
                toItem: nil, 
                attribute: .height, 
                multiplier: 1.0, 
                constant: 64
            ),
            NSLayoutConstraint(
                item: square,
                 attribute: .centerX, 
                 relatedBy: .equal, 
                 toItem: view, 
                 attribute: .centerX, 
                 multiplier: 1.0, 
                 constant: 0
            ),
            NSLayoutConstraint(
                item: square, 
                attribute: .centerY, 
                relatedBy: .equal, 
                toItem: view, 
                attribute: .centerY,
                multiplier: 1.0, 
                constant: 0
            ),
        ])
        self.square = square
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        square.backgroundColor = .yellow
    }
}
```

As you can see we don't need to manually calculate the frame of the view, however creating constraints programmatically is not so convenient. That's why Apple made the constraint [Visual Format Language](https://developer.apple.com/library/content/documentation/UserExperience/Conceptual/AutolayoutPG/VisualFormatLanguage.html).

> VFL = WTF?

Actually this VFL is so bad that I don't even want to demo it, but anyway...

```swift
class ViewController: UIViewController {

    weak var square: UIView!

    override func loadView() {
        super.loadView()

        let square = UIView()
        view.addSubview(square)
        square.translatesAutoresizingMaskIntoConstraints = false

        let views: [String:Any] = [
            "view": view, 
            "subview": square
        ]
        let vertical = NSLayoutConstraint.constraints(
            withVisualFormat: "V:[view]-(<=1)-[subview(==64)]", 
            options: .alignAllCenterX, 
            metrics: nil, 
            views: views
        )

        let horizontal = NSLayoutConstraint.constraints(
            withVisualFormat: "H:[view]-(<=1)-[subview(==64)]",
            options: .alignAllCenterY, 
            metrics: nil, 
            views: views
        )
        view.addConstraints(vertical)
        view.addConstraints(horizontal)
        self.square = square
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        square.backgroundColor = .yellow
    }
}
```

God forbid the engineer who invented this black magic. 😅

So as you can see we definitely have a problem with constraints. Creating all your constraints sucks, at least it's going to cost many many lines of code. Of course you can use the magical interface builder, but where's the fun if you just drag lines?

Creating constraints programmatically is no better than calculating frames, it will lead you to the same level of complexity or even worse, this is why so many 3rd party frameworks came alive and eventually Apple issued the problem as well.

> NOTE: I have an amazing article about [mastering Auto Layout anchors](https://theswiftdev.com/2018/06/14/mastering-ios-auto-layout-anchors-programmatically-from-swift/), I highly recommend reading it if you want to get familiar with anchors. 📖

### Anchors

[Anchors](https://useyourloaf.com/blog/pain-free-constraints-with-layout-anchors) were born because Auto Layout had some construction flaws.

> The NSLayoutAnchor class is a factory class for creating NSLayoutConstraint objects using a fluent API. Use these constraints to programmatically define your layout using Auto Layout.

```swift
class ViewController: UIViewController {

    weak var square: UIView!

    override func loadView() {
        super.loadView()

        let square = UIView()
        view.addSubview(square)
        square.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            square.widthAnchor.constraint(equalToConstant: 64),
            square.heightAnchor.constraint(equalToConstant: 64),
            square.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            square.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        self.square = square
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        square.backgroundColor = .yellow
    }
}
```

See, totally rocks! Anchors are the best way of using for Auto Layout constraints.

## Adaptive layout

If you look at the current state of built-in apps provided by Apple, you can see that only some of them are responsive / adaptive. In general, apps that using collection views are more easy to adapt for bigger screens, or different device orientations.

Always use collection views, except if it's just one view on the center of the screen, you should [build up your user interfaces using collection views](https://theswiftdev.com/2018/04/17/ultimate-uicollectionview-guide-with-ios-examples-written-in-swift/). It will give you reusability, lower memory overhead, scrolling and many more benefits. You don't even have to calculate the stupid index paths if you are using my [CollectionView micro framework](https://github.com/corekit/collectionview).

## Auto Layout with layers

[Auto Layout](https://digitalleaves.com/ultimate-guide-autolayout/) is great, but sometimes you have to work with layers directly. Now in this situation, you still have to do some calculations. You can easily override the bounds property and update frames in the didSet block if you are dealing with a view subclass.

```swift
override var bounds: CGRect {
    didSet {
        gradientLayer.frame = bounds
    }
}
```
Another option is to override the `viewDidLayoutSubviews` method inside the view controller, and set the frame of the layer based on the new bounds.

```swift
override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    gradientView.gradientLayer.frame = gradientView.bounds
}
```

You can also use plain old Key-Value Observing to observe an objet's bounds property and update the frame of the layer according to that.

```swift
// somewhere in the init method
addObserver(
    self, 
    forKeyPath: "bounds", 
    options: .new, 
    context: nil
)

override func observeValue(
    forKeyPath keyPath: String?, 
    of object: Any?, 
    change: [NSKeyValueChangeKey : Any]?, 
    context: UnsafeMutableRawPointer?
) {
    guard keyPath == "bounds" else {
        return super.observeValue(
            forKeyPath: keyPath, 
            of: object, 
            change: change, 
            context: context
        )
    }
    gradientLayer.frame = bounds
}

deinit {
    removeObserver(self, forKeyPath: "bounds")
}
```

## Animating corner radius

First of all if you want to animate a view while using constraint based layouts, you have to do something like this.

```swift
widthConstraint.constant = 64
UIView.animate(withDuration: 0.5, animations: {
    view.layoutIfNeeded()
}, completion: nil)
```

Now if you want to animate the corner radius of a view, you can always use the traditional way, and set the cornerRadius property of the layer on a bounds change.

But, we've got this fancy new UIViewPropertyAnimator API since iOS 10.

```swift
self.imageView.layer.cornerRadius = 16
UIViewPropertyAnimator(duration: 2.5, curve: .easeInOut) {
    self.imageView.layer.cornerRadius = 32
}.startAnimation()
```

It's pretty simple, you can even apply a cornerMask to round just some of the corners. The layer based layout examples are inside the provided source code for the article alongside with a complete sample for each Auto Layout technique. You can download or clone it from the [The.Swift.Dev tutorials repository](https://github.com/theswiftdev/tutorials).
