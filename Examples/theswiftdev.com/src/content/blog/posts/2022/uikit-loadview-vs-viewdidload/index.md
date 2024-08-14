---
type: post
title: UIKit - loadView vs viewDidLoad
description: When to use these methods? Common questions and answers about the iOS view hierarchy including memory management.
publication: 2022-02-09 16:20:00
tags: 
    - uikit
authors:
    - tibor-bodecs
---

## Weak, unowned or strong subviews?

I've got quite a lot of emails and tweets about this topic, so I decided to write about it, because it is really hard to find a proper answer for this question on the internet. There are some [great posts](https://cocoacasts.com/should-outlets-be-weak-or-strong) and [programming guides](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/LoadingResources/CocoaNibs/CocoaNibs.html#//apple_ref/doc/uid/10000051i-CH4-SW6), some [some articles](https://medium.com/macoclock/swift-iboutlet-weak-strong-optional-wrapped-confused-12d371930be2) are a bit older, still many people are asking [the weak vs strong IBOutlet](https://forums.raywenderlich.com/t/weak-vs-strong-iboutlets/114950/6) question even on the [official forums](https://developer.apple.com/forums/thread/96763), but noone really explains the reasons, even on the forums they only recommend this [WWDC](https://developer.apple.com/videos/play/wwdc2015/407/) session video. So what's going on here? 🤔

I did a little research on the topic and the very first thing that we should state is this: Apple [removed the viewDidUnload](https://blog.katastros.com/a?ID=00200-af0e7928-e076-471c-9828-40789445d58d) method in iOS6 and from that version the iOS [view controller](https://developer.apple.com/documentation/uikit/uiviewcontroller) lifecycle changed a bit. If you don't know much about the [lifecycle](https://stackoverflow.com/questions/5562938/looking-to-understand-the-ios-uiviewcontroller-lifecycle) methods ([demystified](http://szulctomasz.com/programming-blog/2015/08/uiviewcontrollers-view-loading-process-demystified/)), you should read [this article](https://ali-akhtar.medium.com/ui-part-1-uiviewcontroller-lifecycle-f323d68cd9f9). This was quite a big change and Apple also touched their internal view management. Before iOS6 it was a common practice to define weak subviews. Because they had a strong reference to it and they were not releasing it unless you removed it from the view hierarchy.

This was about 10 years ago. Now why are we still afraid of strong subviews? The number one reason was the [addSubview](https://developer.apple.com/documentation/uikit/uiview/1622616-addsubview) method. The documentation states that it'll create a strong reference, which automatically triggered my brain and I defined my views as weak pointers, since they're going have a strong reference to their parents. Seems reasonable, right? 🧠

### Weak subviews

Well, the problem is that if you want to define a weak variable we have to use an optional, but I don't like the idea of using an optional variable since the view is going to be always there, it's part of the view hierarchy at some point in, it's not going anywhere. It's only going to be "destroyed" when my view controller is deallocated. Should I declare it as an implicitly unwrapped optional?!? Maybe.

```swift
import UIKit

class ViewController: UIViewController {

    weak var foo: UILabel! // this can be problematic
    weak var bar: UILabel? // this is safe, but meh...
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // this will crash your app.
        foo.removeFromSuperview()
        foo.text = "crash"
    }
}
```

Actually you can go wrong with unwrapped weak pointers, because if you remove your view from the view hiearchy at some point in time before the view controller deallocation then your weak pointer will be nil. In this case there won't be any more strong references and your view will be deallocated right away, so if it's an implicitly unwrapped optional, then we have a trouble. Your app will crash if you try to access the property, because it's going to have a nil value.

So yes you can use implicitly unwrapped optional variables to store subviews, but only if you are sure that you are not going to remove it from the hiearchy. This also means that you don't trust Apple's view management system, which is fine, there can be bugs, but honestly this is quite a crucial feature and it has been around for a decade by now. 🙃

The other alternative is to use a regular weak optional variable, but in that case you'll always have to check if it's nil or not, which is going to be a pain in the ass, but at least you're going to be safe for sure. Personal opinion: it won't worth the effort at all and I never stored views like this.

### Strong subviews

My recommendation is to trust Apple and define your subviews as strong properties. Okay, this can also be problematic if you have other strong references to the same stuff, but in general if the view controller has the only reference to that given subview you should be totally fine.

Since it's a strong property you also have to initialize the view, but that's not a big deal. You can always initialize a view with a .zero frame and that's it. Alternatively you can create a [subclass](https://theswiftdev.com/styling-by-subclassing/) with a regular `init()` method, that's even better, becuase you are going to [use auto layout](https://theswiftdev.com/mastering-ios-auto-layout-anchors-programmatically-from-swift/) for sure and this way can set the `translatesAutoresizingMaskIntoConstraints` property in one go.

```swift
import UIKit

class Label: UILabel {
    
    init() {
        super.init(frame: .zero)

        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("deinit Label")
    }
}

class ViewController: UIViewController {

    // strong view pointers for the win! 😅
    var foo: Label = .init()
    var bar: UILabel = .init(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    deinit {
        print("deinit ViewController")
    }
    
}
```

By implementing a custom deinit method or even better, by [creating a symbolic breakpoint](https://sarunw.com/posts/easy-way-to-detect-retain-cycle-in-view-controller/) you can easily detect retain cycles and fix memory issues. I made some tests and I can confirm you don't have to be afraid of strong views, both the viewcontroller and the view is going to be deallocated if it's needed. 👻

### Unowned subviews

Unowned and weak are [more or less equivalent](https://stackoverflow.com/questions/26707223/swift-how-to-define-a-uiview-delegate-with-unownedunsafe-reference), I'd say that you won't need to define views as unowned references, because they can be problematic if it comes to initialization. It's usually better to have a weak reference and check for nil values, but of course there can be some cases where you might need an unowned subview reference.

## Using loadView and viewDidLoad

The [loadView](https://developer.apple.com/documentation/uikit/uiviewcontroller/1621454-loadview) method can be used to create your own views manually. You should never call this method directly, but it's save to override it. The other thing that you should not is that if you are using this method to override the root view, then you shouldn't call super.loadView().

```swift
import UIKit

class ViewController: UIViewController {
    
    override func loadView() {
        view = UIView(frame: .zero)

        // super.loadView() // no need for this
            
    }
}
```

In every other case when you just want to add views to the view hierarchy, it's completely fine to call the super method. I'm usually implementing this method to setup views and constraints.

```swift
import UIKit 

class ViewController: UIViewController {

    var foo: Label = .init()
    
    override func loadView() {
        super.loadView()
        
        view.addSubview(foo)
        
        NSLayoutConstraint.activate([
            view.centerXAnchor.constraint(equalTo: foo.centerXAnchor),
            view.leadingAnchor.constraint(equalTo: foo.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: foo.trailingAnchor),
            foo.heightAnchor.constraint(equalToConstant: 44),
        ])
    }
}
```

This way I can be sure that every single view is ready by the time the [viewDidLoad](https://developer.apple.com/documentation/uikit/uiviewcontroller/1621495-viewdidload) method is called. It is possible to configure views inside the loadView method too, but I prefer to keep the hierarchy setup there and I place everything else inside the viewDidLoad function. I mean controller related stuff only, like setting up navigation bar buttons and things like this.

As I mentioned this in my [previous article](https://theswiftdev.com/10-little-uikit-tips-you-should-know/), I prefer to use subclasses to configure my views, I also move layout constraints there (as a function that returns them based on some parameters) to keep the view controller clean. Inside the viewDidLoad method I can perform additional user interface related actions, but that's it I don't use it for adding or styling views anymore.

## Conclusion

Based on my current knowledge, here is what I recommend for modern UIKit developers:

- Define your subviews as `strong` properties
- Always check for leaks, implement `deinit`, use breakpoints or instruments
- Use `weak` / `unowned` references if you have to break retain cycles
- Add views to the hierarchy in the `loadView` method
- Use subclasses for styling views, make them reusable
- Define layout constraint getters on the view subclass, activate them inside `loadView`
- Perform remaining UI related operations in the `viewDidLoad` function

That's it. I'm not saying this is the perfect approach, but for me it's definitely the way to go forward with UIKit. I know for sure that many people are still working with the framework and it is here to stay for a long time. I hope these tips will help you to understand UIKit just a little bit better. ☺️
