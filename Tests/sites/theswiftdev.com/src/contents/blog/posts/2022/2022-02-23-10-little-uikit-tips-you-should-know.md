---
slug: 10-little-uikit-tips-you-should-know
title: 10 little UIKit tips you should know
description: In this article I've gathered my top 10 favorite modern UIKit tips that I'd definitely want to know before I start my next project.
publication: 2022-02-03 16:20:00
tags: UIKit, iOS
---

## Custom UIColor with dark mode support

Dark mode and light mode shouldn't follow the exact same design patterns, sometimes you'd like to use a border when your app is in light mode, but in dark mode you might want to hide the extra line.

One possible solution is to define a custom [UIColor](https://developer.apple.com/documentation/uikit/uicolor) based the given UITraitCollection. You can check the userInterfaceStyle property of a trait to check for dark appearance style.

```swift
extension UIColor {
    static var borderColor: UIColor {
        .init { (trait: UITraitCollection) -> UIColor in
            if trait.userInterfaceStyle == .dark {
                return UIColor.clear
            }
            return UIColor.systemGray4
        }
    }
}
```

Based on this condition you can easily return different colors both for light and dark mode. You can create your own set of static color variables by extending the UIColor object. It's a must have little trick if you are planning to support dark mode and you'd like to create custom colors. 🌈

## Observing trait collection changes

This next one is also related to dark mode support, sometimes you'd like to detect appearance changes of the user interface and this is where the traitCollectionDidChange function can be helpful. It's available on views, controllers and cells too, so it's quite an universal solution.

```swift
class MyCustomView: UIView {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else {
            return
        }
        layer.borderColor = UIColor.borderColor.cgColor
    }
}
```

For example, inside this function you can check if the trait collection has a different appearance style and you can update your CoreGraphics layers according to that. The CoreGraphics framework is a low level tool and if you work with layers and colors you have to manually update them if it comes to dark mode support, but the traitCollectionDidChange method can help you a lot. 💡

## UIButton with context menus

[Creating buttons got a lot easier with iOS 15](https://useyourloaf.com/blog/button-configuration-in-ios-15/), but did you know that you can also use a button to display a context menu? It's very easy to present a UIMenu you just have to set the menu and the showsMenuAsPrimaryAction property of the button to true.

```swift
import UIKit

class TestViewController: UIViewController {
    
    weak var button: UIButton!

    override func loadView() {
        super.loadView()
     
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        self.button = button

        NSLayoutConstraint.activate([
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            button.heightAnchor.constraint(equalToConstant: 44),
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        button.setTitle("Open menu", for: .normal)
        button.setTitleColor(.systemGreen, for: .normal)
        button.menu = getContextMenu()
        button.showsMenuAsPrimaryAction = true
    }

    func getContextMenu() -> UIMenu {
        .init(title: "Menu",
              children: [
                UIAction(title: "Edit", image: UIImage(systemName: "square.and.pencil")) { _ in
                    print("edit button clicked")
                },
                UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                    print("delete action")
                },
              ])
    }
    
}
```

This way the UIButton will act as a menu button, you can assign various actions to your menu item. I believe this API is especially handy in some cases, nowadays I prefer to use context menus instead of swipe-to-x-y actions, because it's a bit more convenient for the user if we visually show them (usually with 3 dots) that there are additional actions available on a given UI element. 🧐

## Don't be afraid of subclassing views

UIKit is an OOP framework and I highly recommend to subclass custom views instead of multi-line view configuration code snippets inside your view controller. The previous code snippet is a great example for the opposite, so let's fix that real quick.

```swift
import UIKit

class MenuButton: UIButton {

    @available(*, unavailable)
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.initialize()
    }

    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.initialize()
    }
   
    public init() {
        super.init(frame: .zero)
        
        self.initialize()
    }
    
    open func initialize() {
        self.translatesAutoresizingMaskIntoConstraints = false

        setTitle("Open menu", for: .normal)
        setTitleColor(.systemGreen, for: .normal)
        menu = getContextMenu()
        showsMenuAsPrimaryAction = true
    }
    
    func getContextMenu() -> UIMenu {
        .init(title: "Menu",
              children: [
                UIAction(title: "Edit", image: UIImage(systemName: "square.and.pencil")) { _ in
                    print("edit button clicked")
                },
                UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                    print("delete action")
                },
              ])
    }

    func layoutConstraints(in view: UIView) -> [NSLayoutConstraint] {
        [
            centerYAnchor.constraint(equalTo: view.centerYAnchor),
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
            heightAnchor.constraint(equalToConstant: 44),
        ]
    }
}


class TestViewController: ViewController {
    
    weak var button: MenuButton!

    override func loadView() {
        super.loadView()
     
        let button = MenuButton()
        view.addSubview(button)
        self.button = button
        NSLayoutConstraint.activate(button.layoutConstraints(in: view))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}
```

As you can see the code inside the view controller is heavily reduced and most of the button configuration related logic is now encapsulated inside the MenuButton subclass. This approach is great because you can focus less on view configuration and more on your business logic inside the view controller. It'll also help you to think in reusable components.

One additional note here is that I tend to create my interfaces from code that's why I mark the unnecessary init methods with the @available(*, unavailable) flag so other people in my team can't call them accidentally, but this is just a personal preference. 😅

## Always large navigation title

I don't know about you, but for me all the apps have glitches if it comes to the large title feature in the navigation bar. For personal projects I've got sick and tired of this and I simply force the large title display mode. It's relatively simple, here's how to do it.

```swift
import UIKit

class TestNavigationController: UINavigationController {

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        
        initialize()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        initialize()
    }
    
    open func initialize() {
        navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        // custom tint color
        navigationBar.tintColor = .systemGreen
        // custom background color
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.backgroundColor = .systemBackground
        navigationBar.standardAppearance = navBarAppearance
        navigationBar.scrollEdgeAppearance = navBarAppearance
    }
}

class TestViewController: UIViewController {
    
    override func loadView() {
        super.loadView()
        
        // prevent collapsing the navbar if we add scrollviews
        view.addSubview(UIView(frame: .zero))
        
        // add other custom views...
    }
}

let controller = TestNavigationController(rootViewController: TestViewController())
```

You just have to set two properties (you can subclass UINavigationController or set these inside your view controller, but I prefer subclassing) plus you have to add an empty view to your view hierarchy to prevent collapsing if you are planning to use a UIScrollView, UITableView or UICollectionView inside the view controller.

Since this tip is also based on my personal preference, I've also included a few more customization options in the snippet. If you take a look at the initialize method you can see how to change the tint color and the background color of the navigation bar. 👍

## Custom separators for navigation and tab bars

Since many apps prefer to have a customized navigation bar and tab bar appearance it's quite a common practice when you have to also add a separator line to distinguish user interface elements a bit more. This is how you can solve it by using a single bar separator class.

```swift
import UIKit 

class BarSeparator: UIView {
    
    let height: CGFloat = 0.3

    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: height))
        
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .systemGray4
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func layoutConstraints(for navigationBar: UINavigationBar) -> [NSLayoutConstraint] {
        [
            widthAnchor.constraint(equalTo: navigationBar.widthAnchor),
            heightAnchor.constraint(equalToConstant: CGFloat(height)),
            centerXAnchor.constraint(equalTo: navigationBar.centerXAnchor),
            topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
        ]
    }
    
    func layoutConstraints(for tabBar: UITabBar) -> [NSLayoutConstraint] {
        [
            widthAnchor.constraint(equalTo: tabBar.widthAnchor),
            heightAnchor.constraint(equalToConstant: CGFloat(height)),
            centerXAnchor.constraint(equalTo: tabBar.centerXAnchor),
            topAnchor.constraint(equalTo: tabBar.topAnchor),
        ]
    }
}

class MyNavigationController: UINavigationController {
    
   override func viewDidLoad() {
        super.viewDidLoad()
        
        let separator = BarSeparator()
        navigationBar.addSubview(separator)
        NSLayoutConstraint.activate(separator.layoutConstraints(for: navigationBar))
    }
}

class MyTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let separator = BarSeparator()
        tabBar.addSubview(separator)
        NSLayoutConstraint.activate(separator.layoutConstraints(for: tabBar))
    }   
}
```

This way you can reuse the BarSeparator component to add a line to the bottom of a navigation bar and to the top of a tab bar. This snippet follows the exact same principles that I showed you before, so you should be familiar with the subclassing concepts by now. 🤓

## Custom tab bar items

I struggled quite a lot with tab bar item icon alignment, but this the way I can easily show / hide the title and align the icons to the center of the bar if there are no labels.

```swift
import UIKit

class MyTabBarItem: UITabBarItem {
    
    override var title: String? {
        get { hideTitle ? nil : super.title }
        set { super.title = newValue }
    }
        
    private var hideTitle: Bool {
        true
    }

    private func offset(_ image: UIImage?) -> UIImage? {
        if hideTitle {
            return image?.withBaselineOffset(fromBottom: 12)
        }
        return image
    }
    
    // MARK: - init
    
    public convenience init(title: String?, image: UIImage?, selectedImage: UIImage?) {
        self.init()

        self.title = title
        self.image = offset(image)
        self.selectedImage = offset(selectedImage)
    }

    override init() {
        super.init()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// inside some view controller init
tabBarItem = MyTabBarItem(title: "Home", image: UIImage(systemName: "house"), selectedImage: nil)
```

I'd also like to mention that [SF Symbols](https://developer.apple.com/sf-symbols/) are amazing. If you are not using these kind of icons just yet I highly recommend to take a look. Apple made a really nice job with this collection, there are so many lovely icons that you can use to visually enrich your app, so don't miss out. 😊

## loadView vs viewDidLoad

Long story short, you should always instantiate and place constraints to your views inside the [loadView](https://developer.apple.com/documentation/uikit/uiviewcontroller/1621454-loadview) method and configure your views inside the [viewDidLoad](https://developer.apple.com/documentation/uikit/uiviewcontroller/1621495-viewdidload) function.

I always use implicitly unwrapped weak optional variables for custom views, since the [addSubview](https://developer.apple.com/documentation/uikit/uiview/1622616-addsubview) function will create a strong reference to the view when it is added to the view hierarchy. We don't want to have retain cycles, right? That'd be real bad for our application. 🙃

```swift
import UIKit

class MyCollectionViewController: ViewController {
    
    weak var collection: UICollectionView!

    override func loadView() {
        super.loadView()
        
        view.addSubview(UIView(frame: .zero))
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collection.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collection)
        self.collection = collection
        NSLayoutConstraint.activate([
            // ...
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collection.backgroundColor = .systemBackground
        collection.alwaysBounceVertical = true
        collection.dragInteractionEnabled = true
        collection.dragDelegate = self
        collection.dropDelegate = self

        if let flowLayout = collection.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.sectionHeadersPinToVisibleBounds = true
        }
        
        collection.register(MyCell.self,
                            forCellWithReuseIdentifier: MyCell.identifier)
    }
```

Anyway, I'd go with a custom subclass for the collection view here as well and maybe define a configure method then call that one instead of placing everything directly to the controller. The decision is always up-to-you, I'm just trying to show you the some possible solutions. 😉

## Stack views & auto-layout anchors

Take advantage of stack views and auto layout anchors as much as possible. If you are going to create user interfaces programmatically in Swift with the help of UIKit, then it's going to be an essential skill to master these techniques otherwise you're going to struggle a lot.

I already have a tutorial about [using auto layout programmatically](https://theswiftdev.com/ios-auto-layout-tutorial-programmatically/) and another one about [mastering auto-layout anchors](https://theswiftdev.com/mastering-ios-auto-layout-anchors-programmatically-from-swift/), they were published a few years ago, but the concepts are still valid and the code still works. I also have one more article that you should read if you want to learn [about building forms using stack views](https://theswiftdev.com/custom-views-input-forms-and-mistakes/). Learning these kind of things helped me a lot to create complex screens hassle-free. I'm also using one more ["best practice" to create collection views](https://theswiftdev.com/ultimate-uicollectionview-guide-with-ios-examples-written-in-swift/).

When SwiftUI came out I had the feeling that eventually I'd do the same with UIKit, but of course Apple had the necessary tooling to support the framework with view builders and property wrappers. Now that we have SwiftUI I'm still not using it because I feel like it lacks quite a lot of features even in 2022. I know it's great and I've created several prototypes for screens using it, but if it comes to a complex application my gut tells me that I should still go with UIKit. 🤐

## Create a reusable components library

My final advice in this tutorial is that you should build a custom Swift package and move all your components there. Maybe for the first time it's going to consume quite a lot of time but if you are working on multiple projects it will speed up development process for your second, third, etc. app.

You can move all your custom base classes into a separate library and create specific ones for your application. You just have to mark them open, you can use the availability API to manage what can be used and what should be marked as unavailable.

I have quite a lot of tutorials about the [Swift Package Manager](https://theswiftdev.com/swift-package-manager-tutorial/) on my blog, this is a great way to get familiar with it and you can start building your own library step-by-step. 😊
