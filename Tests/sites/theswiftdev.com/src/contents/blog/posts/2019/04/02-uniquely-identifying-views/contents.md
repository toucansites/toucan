---
slug: uniquely-identifying-views
title: Uniquely identifying views
description: Learn how to use string based UIView identifiers instead of tags. If you are tired of tagging views, check out these alternative solutions.
publication: 2019-04-02 16:20:00
tags: UIKit, iOS
---


## First approach: accessibility to the rescue!

Long story short, I was quite tired of tagging views with stupid number values, so I looked for a better alternative solution to fix my problem. As it turned out, there is a property called `accessibilityIdentifier` that can do the job.

```swift
extension UIView {

    var id: String? {
        get {
            return self.accessibilityIdentifier
        }
        set {
            self.accessibilityIdentifier = newValue
        }
    }

    func view(withId id: String) -> UIView? {
        if self.id == id {
            return self
        }
        for view in self.subviews {
            if let view = view.view(withId: id) {
                return view
            }
        }
        return nil
    }
}
```

I made a simple extension around the UIView class, so now I can use a proper string value to uniquely identify any view object in the view hierarchy. It's quite a nice solution, now I can name my views in a really nice way. As a gratis storing the name under the accessibilityIdentifier will benefit your UI tests. 😉

## Second approach: using enums

The main idea is to have an Int based enum for every view identifier, so basically you can use the tag property to store the enum's rawValue. It's still not so nice as the one above, but it's way more safe than relying on pure integers. 😬

```swift
enum ViewIdentifier: Int {
    case submitButton
}

extension UIView {

    var identifier: ViewIdentifier? {
        set {
            if let value = newValue {
                self.tag = value.rawValue
            }
        }
        get {
            return ViewIdentifier(rawValue: self.tag)
        }
    }

    func view(withId id: ViewIdentifier) -> UIView? {
        return self.viewWithTag(id.rawValue)
    }
}
```

Honestly I just came up with the second approach right after I copy & pasted the first snippet to this article, but what the heck, maybe someone else will like it. 😂

If you have a better solution for this problem, feel free to share it with me.
