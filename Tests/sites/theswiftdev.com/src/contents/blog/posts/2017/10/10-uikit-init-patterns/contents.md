---
slug: uikit-init-patterns
title: UIKit init patterns
description: Learn about the initialization process of the two well known classes in UIKit. Say hello to UIViewcontroller, and UIView init patterns.
publication: 2017-10-10 16:20:00
tags: Swift, iOS, design patterns
---

## UIViewController init

Actually `UIViewController` intialization is pretty straightforward. You only have to override a few methods if you want to be in full control. It depends on the circumstances which init will be called, if you are using a storyboard, [init(coder)](http://napora.org/nscoder-and-swift-initialization/) is the one that you are looking for. If you are trying to initiate your controller from an [external nib file](https://localhost/2018/10/16/custom-uiview-subclass-from-a-xib-file/), `init(nib,bundle)` is going to be called. You also have a third option, you can initialize a controller programmatically from code. Long story short, in order to make a sane init process, you have to deal with all this stuff.

Let me introduce two patterns for UIViewControllers, the first one is just a common init function that gets called in every case that could initialize a controller.

```swift
import UIKit

class ViewController: UIViewController {

    override init(
        nibName nibNameOrNil: String?, 
        bundle nibBundleOrNil: Bundle?
    ) {
        super.init(
            nibName: nibNameOrNil, 
            bundle: nibBundleOrNil
        )

        self.initialize()
    }

    required init?(
        coder aDecoder: NSCoder
    ) {
        super.init(coder: aDecoder)

        self.initialize()
    }

    init() {
        super.init(nibName: nil, bundle: nil)

        self.initialize()
    }

    func initialize() {
        //do your stuff here
    }
}
```

You can also hide the `init(nib:bundle)` and `init(coder)` methods from the future subclasses. You don't have to override `init(nib:bundle)` and you can mark the `init(coder)` as a convenience initializer. It seems like a little bit hacky solution and I don't like it too much, but it does the job.

```swift
import UIKit

class ViewController: UIViewController {

    init() {
        super.init(nibName: nil, bundle: nil)

        self.initialize()
    }

    required convenience init?(coder aDecoder: NSCoder) {
        self.init(coder: aDecoder)

        self.initialize()
    }

    func initialize() {
        //do your stuff here
    }
}

class MyFutureViewController: ViewController {

    override init() {
        super.init()
    }
}
let vc = MyFutureViewController()
```


## UIView init

I usually create a common initializer for UIViews to make the init process more pleasant. I also set the translate autoresizing mask property to false in that initializer method, because it's 2017 and noone uses springs & struts anymore, right?

```swift
import UIKit

class View: UIView {

    init() {
        super.init(frame: .zero)

        self.initialize()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.initialize()
    }

    func initialize() {
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}
```

It's also nice to have some autolayout helpers, and if you want to [initialize a view](https://www.raywenderlich.com/76433/how-to-make-a-custom-control-swift) from a nib file, it's really good to have some convenience method around.

```swift
import UIKit

extension UIView {

    public convenience init(autolayout: Bool) {
        self.init(frame: .zero)

        self.translatesAutoresizingMaskIntoConstraints = !autolayout
    }

    public static func create(autolayout: Bool = true) -> Self {
        let _self = self.init()
        let view  = _self as UIView
        view.translatesAutoresizingMaskIntoConstraints = !autolayout
        return _self
    }

    public static func createFromNib(
        owner: Any? = nil, 
        options: [AnyHashable: Any]? = nil
    ) -> UIView {
        return Bundle.main.loadNibNamed(
            String(describing: self), 
            owner: owner, 
            options: options
        )?.last as! UIView
    }
}
let view = UIView(autolayout: true)
```

Using these snippets, it's really easy to maintain a sane init process for all the UIKit classes, because most of them ared derived from these two "primary" classes.



