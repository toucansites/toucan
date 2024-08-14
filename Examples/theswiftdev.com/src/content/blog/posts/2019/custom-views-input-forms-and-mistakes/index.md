---
type: post
title: Custom views, input forms and mistakes
description: Just a little advice about creating custom view programmatically and the truth about why form building with collection views sucks.
publication: 2019-10-21 16:20:00
tags: 
  - uikit
authors:
  - tibor-bodecs
---

## How NOT to build forms for iOS apps?

Let's start with an honest statement: I messed up with this tutorial (a lot):

[Building input forms for iOS apps](https://theswiftdev.com/2019/05/23/building-input-forms-for-ios-apps/)

The thing is that this form building methodology only works if the cells are always visible on screen, which is quite a rare case. I discovered this issue while I was working on my current project and some fields were constantly disappearing and moving the cursor to the next input field stopped working when the cell was out of frame.

> Reusability & memory efficiency is not always what you want.

Seems like `UICollectionView` is not the best solution for making input forms, because the constant cell reusability will mess up some of the expected behavior. It's still good for lists with "a thousand elements", but for an input form I would not recommend this technique anymore. Yep, my mistake, sorry about it... 😬

## Learning by making mistakes

Long story short, I made a mistake and probably you'll also make a lot during your developer career. Does this make you a bad programmer? Not at all. We're human, we're constantly making smaller or bigger mistakes, but...

> (Remain and) turn it into strength

Your mistakes will always stay with you, but you can learn from them a lot. The problem only starts if you keep doing the same mistakes again and again, or you don't even realize that you're doing something wrong. It's really hard to take one step back and see the problem from a bigger perspective. Sometimes you simply need someone else to point out the issue for you, but negative feedback can also be painful.

Anyway, I don't want to be too much philosophical, this is a Swift developer blog ffs.

### A few things that I learned:

- my ideas are not always working, so don't trust me 100% (haha) 🤣
- it's always better to code/work in pair with someone else
- sometimes the "padawan" will teach the "master" 😉
- a professional qa team can save you a lot of time
- [VIPER is my architectural "silver bullet"](https://theswiftdev.com/2018/03/12/the-ultimate-viper-architecture-tutorial/), not [collection views](https://theswiftdev.com/2018/04/17/ultimate-uicollectionview-guide-with-ios-examples-written-in-swift/)
- UICollectionView based form building is not working...
- ...but the collection view framework still rocks for complex interfaces
- have some dedicated time for code cosmetics & refactor
- use view subclasses programmatically (or SwiftUI in the future)

So the last point is the most interesting one, let me explain why.

## Custom view subclasses from code only

Creating a [UIView subclass programmatically](https://theswiftdev.com/2018/10/16/custom-uiview-subclass-from-a-xib-file/) is a relatively easy task. You can load a nib file or you can do it straight from code. A few weeks ago I've learned a new trick, that was bugging me all the time I made a new subclass in Swift:

> Why the hell do I have to implement `init(coder:)` if I'm not using IB at all?

Also what the heck is going on with `init(frame:)`, I don't want to deal with these two [init methods](https://theswiftdev.com/2017/10/11/uikit-init-patterns/) anymore, since I'm using auto layout and I'm completely trying to ignore interface builder with the messed up storyboards and nibs as well.

```swift
class View: UIView {

    @available(*, unavailable)
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.initialize()
    }

    @available(*, unavailable)
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

The solution: mark these stupid init functions as unavailable, so no-one can use them anymore. The only source of truth will be your own init method, which is quite a relief if you were so annoyed about the messed up initialization process like I was. 😤

Now you have your own base class that you can use as a parent for your future views. Of course you'll need to do the same thing for almost every UI element, like labels, buttons, text fields, etc. That's a lot of work, but on a long term it's totally worth it.

```swift
import UIKit

class TitleLabel: Label {

    override func initialize() {
        super.initialize()

        self.textAlignment = .center
        self.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        self.textColor = .systemBlue
    }

    func constraints(in view: UIView, padding: CGFloat = 8) -> [NSLayoutConstraint] {
        [
            self.topAnchor.constraint(equalTo: view.topAnchor, constant: padding),
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -1 * padding),
        ]
    }
}
```

A good practice can be to have subclass for each and every custom user interface component, like the primary button, secondary button, title label, header label, etc. This way you don't have to configure your views in the view controller, plus you can put your frequently used constraints into the subclass using some helper methods.

Also you can have some nice extensions, those can help you with view configurations. You know, just like modifiers in SwiftUI. You can even recreate the exact same syntax. The underlying behavior won't be the same, but that's another story. 📚

## What about the form new builder in iOS?

Oh, yeah almost forgot. I have a brand new, but still very similar solution. I'm using view subclasses instead of collection view components, plus the collection view have been replaced with a `UIScrollView` + `UIStackView` combination. 🐐

```swift
class ViewController: UIViewController {

    weak var scrollView: ScrollView!
    weak var stackView: VerticalStackView!

    override func loadView() {
        super.loadView()

        let scrollView = ScrollView()
        self.view.addSubview(scrollView)
        self.scrollView = scrollView
        NSLayoutConstraint.activate([/*...*/])

        let stackView = VerticalStackView()
        self.scrollView.addSubview(stackView)
        self.stackView = stackView
        NSLayoutConstraint.activate([/*...*/])
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "StackForm"
        self.navigationController?.navigationBar.prefersLargeTitles = true

        let email = EmailTextField(id: "email-input", placeholder: "Email")
        self.stackView.addArrangedSubview(email)

        let password = PasswordTextField(id: "password-input", placeholder: "Password")
        self.stackView.addArrangedSubview(password)

        let submit = SubmitButton(id: "submit-button", title: "Submit")
        .onTouch { [weak self] _ in self?.submit() }
        self.stackView.addArrangedSubview(submit)
    }

    func submit() {
        guard
            let email = (self.view.view(withId: "email-input") as? UITextField)?.text,
            let password = (self.view.view(withId: "password-input") as? UITextField)?.text
        else {
            return
        }
        print("Account: \(email) - \(password)")
    }
}
```

As you can see I'm still using the same [view identification technique](https://theswiftdev.com/2019/04/02/uniquely-identifying-views/), plus I still prefer to have the SwiftUI-like `.onTouch` action handlers. You might ask though:

## Why don't you simply go with SwiftUI?

Well, the thing is that SwiftUI is iOS 13 only, which is only around ~55% adoption nowadays, that's one of the main reasons, but also SwiftUI is kind of incomplete.

I'm trying to get as close as I can to SwiftUI, so the transition will be less pain in the ass when the time comes. SwiftUI will be amazing, but still it's a giant leap forward. Sometimes I believe that Apple is rushing things just because of marketing / developer needs (yeah, we are very impatient animals). Maybe a simple wrapper framework around UIKit / AppKit without the whole declarative syntax would have been a better idea as a first step... who knows... CoreKit -> AppleKit? 🤔

Anyway, you can download a working example of my latest form building solution in Swift 5 from [GitHub](https://github.com/theswiftdev/tutorials). Just look for the `StackForm` folder inside the repository.
