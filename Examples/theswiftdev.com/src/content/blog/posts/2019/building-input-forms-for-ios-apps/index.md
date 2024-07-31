---
type: post
slug: building-input-forms-for-ios-apps
title: Building input forms for iOS apps
description: Learn how to build complex forms with my updated collection view view-model framework without the struggle using Swift.
publication: 2019-05-23 16:20:00
tags: UIKit, iOS
authors:
  - tibor-bodecs
---

> WARN: This method is not working, since cells in the form are going to be reused and this leads to some inconsistency... please [read my other post](https://theswiftdev.com/2019/10/21/custom-views-input-forms-and-mistakes/). 🤷‍♂️

## CollectionView and input forms

My [CollectionView](https://github.com/corekit/collectionview) framework just got a HUGE update. There are lots of new changes, but one of the biggest improvement is the way I deal with view models. In the past, you had to use long function names in your view model including the generic view & model class names. If you have ever read my [ultimate UICollectionView guide](https://theswiftdev.com/2018/04/17/ultimate-uicollectionview-guide-with-ios-examples-written-in-swift/) you should know what I'm talking about. Good news: I have a way better solution now! 😉

This update not just cleans up my code a lot, but it allows me to add custom view model handlers, so I can interact with input fields, toggles, etc. in a ridiculously easy way. Another huge improvement is that I started to use view identifiers. It was accidental discovery, I only wanted to look for [an alternative solution for identifying views by tags](https://theswiftdev.com/2019/04/02/uniquely-identifying-views/), then I had this brilliant idea: why not look up cells by ids as well?

As a result I'm now able to create forms by using the framework. I still believe that collection views are the ultimate building blocks for most of the applications. Yeah, you can still say that there is no silver bullet, but I'm just fine if this solution can cover 90% of the my use-cases. After all, most of the apps are just visualizing JSON data in a nice, or not-so-nice way. 🤷‍♂️ #sarcasm

## Reusable form components

Let's build a form by using the brand new [framework](https://github.com/corekit/collectionview). First of all, you'll need to integrate it by using a package manager. I really hope that in a few weeks we can use [Swift Package Manager](https://theswiftdev.com/2017/11/09/swift-package-manager-tutorial/), until than you you should go with CocoaPods or carthage.

```
# cocoapods
source 'https://github.com/CoreKit/CocoaPods.git'
pod 'CollectionView', '~> 2.0.0'

# carthage
github "CoreKit/CollectionView" "2.0.0"
```

Now let's create a reusable cell for our input fields. Feel free to use a xib file as usual, the only difference in the implementation is going to be that I remove the target listener in the reset method. We'll add one later on in the view-model. 🎯

```swift
import Foundation
import CollectionView

class InputCell: Cell {

    @IBOutlet weak var textField: UITextField!

    override func reset() {
        super.reset()

        self.textField.removeTarget(nil, action: nil, for: .editingChanged)
    }
}
```

I'm also going to create a simple entity for displaying a placeholder if the form field is empty and storing the actual value of the input field, let's call this InputEntity.

```swift
import Foundation

struct InputEntity {
    var placeholder: String
    var value: String?
}
```

Now the hardest part: making a connection between the view and the model.

```swift
import Foundation
import CollectionView

class InputViewModel: ViewModel<InputCell, InputEntity> {

    var editingChangeHandler: ViewModelHandler?

    override var height: CGFloat {
        return 60
    }

    override func updateView() {
        self.view?.textField.placeholder = self.model.placeholder
        self.view?.textField.text = self.model.value

        self.view?.textField.addTarget(self,
                                       action: #selector(self.editingChanged(_:)),
                                       for: .editingChanged)
        self.view?.textField.addTarget(self,
                                       action: #selector(self.editingDidEnd(_:)),
                                       for: .editingDidEnd)
    }

    func onEditingChange(_ handler: @escaping ViewModelHandler) -> Self {
        self.editingChangeHandler = handler
        return self
    }

    @objc func editingChanged(_ textField: UITextField) {
        self.model.value = textField.text
        self.editingChangeHandler?(self)
    }

    @objc func editingDidEnd(_ textField: UITextField) {
        print("nothing-to-do-here-now...")
    }
}
```

It's quite a complex view model, but it can do a lot as well. The first thing that you should understand is the ViewModelHandler which is basically a generic alias that you can utilize in the view models. It gives you the ability to pass around the type-safe view-model for the callbacks. You'll see that later on.

The second major change is the updateView method, which is used to update the view based on the data coming from the model. I'm also adding my target listeners to my view, so I can handle user input directly inside the view-model class.

The onEditingChange method is the "public" api of the view-model. I use the on prefix now for adding handlers, and listeners to my view-models. It basically calls the stored block if a change event happens. You can add as many event handler blocks as you want. I really hope that you'll get the hang of this approach.

One more thing: returning the the height of the cell is a one-liner now! 🎊

Composing forms and more
The plan is for now to have an input form with two input fields. One for the email address, the other is going to be used for the password. The trick is going to be that this time I won't show you the entire code, but you have to figure out the rest.

However I'll show you everything that you'll ever need to know in order to make your own forms, even some complex ones. Don't worry, it's just a few lines of code.

```swift
import UIKit
import CollectionView

class ViewController: CollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let grid = Grid(columns: 1, margin: UIEdgeInsets(all: 16), padding: .zero)
        self.collectionView.source = .init(grid: grid, [
            [
                InputViewModel(id: "email-input", .init(placeholder: "Email", value: nil))
                .onEditingChange { viewModel in
                    guard let passwordViewModel = viewModel.by(id: "password-input") as? InputViewModel else {
                        return
                    }
                    passwordViewModel.model.value = viewModel.model.value ?? ""
                    passwordViewModel.updateView()
                },
                InputViewModel(id: "password-input", .init(placeholder: "Password", value: nil)),
            ],
        ])
        self.collectionView.reloadData()
    }
}
```

If you've ever worked with my collection view framework, you should know that I always use a grid system, because I don't really like to calculate numbers.

The source is a set of view-models, grouped by sections. The only interesting part here is that sources can now be initialized with an array of sections and view-models.

If you initialize a view-model with and identifier, later on you can query that one by the id. This is exactly whats happening inside the editing change handler block. Every view-model has the ability to return some other view-model by the id. View-models are type-safe by default, the viewModel passed inside the block too, thanks to the generic ViewModelHandler alias.

So in this little example, if you type something into the first input field, the exact same text will appear in the second text field. You can get all the view models by id when you need them. For example if you have to submit this form, you can grab the email and password fields by using the same approach.

## Building a login form

I challenge you to build a login form on your own by using my framework. I guarantee yout that it shouldn't take more than 30mins of work. I'll show you the final view controller that I would use, so this might gives you some help.

If you want to spice up things a little bit, you can even add a checkbox for accepting the privacy policy. The main idea here is that you should create reusable components for every single item in your form. So for example a ToggleView with a corresponding view-model would be a good approach (also works for buttons). 🤫

Here is the final hint, you only have to make your own view-models and views...

```swift
import UIKit
import CollectionView

class ViewController: CollectionViewController {

    enum Ids: String {
        case email = "email-input"
        case password = "password-input"
        case privacyPolicy = "privacy-policy-checkbox"
        case submit = "submit-button"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let grid = Grid(columns: 1, margin: UIEdgeInsets(all: 16), padding: .zero)
        self.collectionView.source = .init(grid: grid, [
            [
                InputViewModel(id: Ids.email.rawValue, .init(placeholder: "Email", value: nil))
                .onEditingEnd { viewModel in
                    guard let passwordViewModel = viewModel.by(id: Ids.password.rawValue) as? InputViewModel else {
                        return
                    }
                    passwordViewModel.view?.textField.becomeFirstResponder()
                },
                InputViewModel(id: Ids.password.rawValue, .init(placeholder: "Password", value: nil, secure: true))
                .onEditingEnd { viewModel in
                    viewModel.view?.textField.endEditing(true)
                },
            ],
            [
                ToggleViewModel(id: Ids.privacyPolicy.rawValue, .init(label: "Privacy policy", value: false))
                .onValueChange { viewModel in
                    guard let submitViewModel = viewModel.by(id: Ids.submit.rawValue) as? ButtonViewModel else {
                        return
                    }
                    var model = submitViewModel.model
                    model.enabled = viewModel.model.value
                    submitViewModel.model = model
                    submitViewModel.updateView()
                },
            ],
            [
                ButtonViewModel(id: Ids.submit.rawValue, .init(title: "Submit", enabled: false))
                .onSubmit { viewModel in
                    guard
                        let emailViewModel = viewModel.by(id: Ids.email.rawValue) as? InputViewModel,
                        let passwordViewModel = viewModel.by(id: Ids.password.rawValue) as? InputViewModel
                    else {
                        return
                    }
                    /* ... */
                },
            ],
        ])
        self.collectionView.reloadData()
    }
}
```

That's it for now, an almost complete login form, with just a few lines of code. Of course there is an underlying framework, but if you check the [source code](https://github.com/corekit/collectionview), you'll actually see that it contains nothing that would be considered as black magic. 💫
