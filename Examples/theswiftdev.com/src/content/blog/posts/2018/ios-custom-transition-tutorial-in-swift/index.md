---
type: post
slug: ios-custom-transition-tutorial-in-swift
title: iOS custom transition tutorial in Swift
description: In this tutorial, you'll learn how to replace the push, pop and modal animations with custom transitions & percent driven interactions.
publication: 2018-04-26 16:20:00
tags: 
    - uikit
    - ios
authors:
    - tibor-bodecs
---

## UIKit custom transition API - a theoretical lesson

There are many classes and delegates involved during the process of making a [custom transition](https://developer.apple.com/videos/play/wwdc2013/218/), let's walk through these items real quick, and do some coding afterwards.

### UIViewControllerTransitioningDelegate

Every view controller can have a transition delegate, in that delegate implementation you can provide the custom animation and interaction controllers. Those objects will be responsible for the actual animation process, and this delegate is the place where you can "inject your code" to the UIKit framework. 💉

### UINavigationControllerDelegate

The navigation controller delegate also has two methods that are responsible for custom push and pop [animations](https://stackoverflow.com/questions/26569488/navigation-controller-custom-transition-animation). It's almost the same as the transitioning delegate for the view controllers, but you'll see this in action later on. 💥

### UINavigationController.Operation

The navigation controller operation is just an `enum` which contains the "direction" of the navigation animation. Usually push or pop.

> NOTE: Presenting and dismissing something modally is not exactly the same thing as pushing & popping view controllers inside a navigation stack. More on this later.

### UIViewControllerAnimatedTransitioning

These objects are returned by the transition delegate, so basically this is the place where you implement the fancy custom view animations. 😉

### UIViewControllerContextTransitioning

This context encapsulates all the info about the transitioning, you can get the participating views, controllers and many more from this object. The transitioning context is available for you to use it during the animation.

### UIPercentDrivenInteractiveTransition

An object that drives an interactive animation between one view controller and another.

In a nutshell, this is the thing that gives you the magical ability to swipe a navigation controller interactively back (and forth if you changed your mind) with your fingers from the edge of the screen. 📱

## Custom transition animations programmatically

Let's do some real coding! I'll show you how to make a basic fade [animation between view controllers](https://www.raywenderlich.com/170144/custom-uiviewcontroller-transitions-getting-started) inside a navigation stack. First we'll start with the push animation.

```swift
open class FadePushAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    open func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?
    ) -> TimeInterval {
        0.5
    }

    open override func animateTransition(
        using transitionContext: UIViewControllerContextTransitioning
    ) {
        guard
            let toViewController = transitionContext.viewController(forKey: .to)
        else {
            return
        }
        transitionContext.containerView.addSubview(toViewController.view)
        toViewController.view.alpha = 0

        let duration = self.transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, animations: {
            toViewController.view.alpha = 1
        }, completion: { _ in
            transitionContext.completeTransition(
                !transitionContext.transitionWasCancelled
            )
        })
    }
}
```

As you can see creating a custom transition animation is really simple. You just have to implement two delegate methods. One of them will return the duration of the animation, and the other will contain the actual transition.

The transition context provides a custom `containterView` object that you can use in the animation, also you can grab the participating views and controllers from this object as I mentioned it before. Now let's reverse this animation. 👈

```swift
open class FadePopAnimator: CustomAnimator {

    open func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?
    ) -> TimeInterval {
        0.5
    }

    open override func animateTransition(
        using transitionContext: UIViewControllerContextTransitioning
    ) {
        guard
            let fromViewController = transitionContext.viewController(forKey: .from),
            let toViewController = transitionContext.viewController(forKey: .to)
        else {
            return
        }

        transitionContext.containerView.insertSubview(toViewController.view, belowSubview: fromViewController.view)

        let duration = self.transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, animations: {
            fromViewController.view.alpha = 0
        }, completion: { _ in
            transitionContext.completeTransition(
                !transitionContext.transitionWasCancelled
            )
        })
    }
}
```

Finally you just have to implement the navigation controller's delegate method in order to replace the built-in UIKit system animations. 🛠

```swift
extension MainViewController: UINavigationControllerDelegate {

    func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push:
            return FadePushAnimator()
        case .pop:
            return FadePopAnimator()
        default:
            return nil
        }
    }
}
```

Note that you don't have to make two separate classes (pop & push), you can also pass the operation and implement the animations in a single animated transitioning class.

Percent driven interactive transitions
So, now you know how to implement a custom transition, but it's time to make it interactive! The process is pretty simple, you'll only need a gesture recognizer and a proper delegate method to make things work. ⌨️

```swift
class DetailViewController: UIViewController {

    var interactionController: UIPercentDrivenInteractiveTransition?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .lightGray

        let edge = UIScreenEdgePanGestureRecognizer(
            target: self,
            action: #selector(self.handleEdgePan(_:))
        )
        edge.edges = .left
        self.view.addGestureRecognizer(edge)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.navigationController?.delegate = self
    }

    @objc func handleEdgePan(_ gesture: UIScreenEdgePanGestureRecognizer) {
        let translate = gesture.translation(in: gesture.view)
        let percent = translate.x / gesture.view!.bounds.size.width

        switch gesture.state {
        case .began:
            self.interactionController = UIPercentDrivenInteractiveTransition()
            self.navigationController?.popViewController(animated: true)
        case .changed:
            self.interactionController?.update(percent)
        case .ended:
            let velocity = gesture.velocity(in: gesture.view)

            if percent &gt; 0.5 || velocity.x &gt; 0 {
                self.interactionController?.finish()
            }
            else {
                self.interactionController?.cancel()
            }
            self.interactionController = nil
        default:
            break
        }
    }
}

extension DetailViewController: UINavigationControllerDelegate {

    /* ... */

    func navigationController(
        _ navigationController: UINavigationController,
        interactionControllerFor animationController: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
        interactionController
    }
}
```

Inside the controller that will be popped you can take ownership of the navigation controller's delegate and implement the interactive transition controller using a left screen edge pan gesture recognizer. This whole code usually goes into a new subclass of `UIPercentDrivenInteractiveTransition` but for the sake of simplicity this time we'll skip that, and go with this really easy solution. In the [final example code](https://gitlab.com/theswiftdev/custom-transitions) you'll find the "subclassed version" of the interactive transition. 😅

## Navigation vs modal presentation

Ok, let's cover one more thing real quick: customizing [modal](https://github.com/pronebird/CustomModalTransition) presentation animations for view controllers. There is a minor difference between customizing the navigation stack animations and modal presentation styles. If you want to customize a view controller transition you'd usually do something like this. 👍

```swift
class DetailViewController: UIViewController {

     /* ... */

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        guard let controller = segue.destination as? ModalViewController else {
            return
        }

        controller.transitioningDelegate = self
        controller.modalPresentationStyle = .custom
        controller.modalPresentationCapturesStatusBarAppearance = true
    }
}
Here comes the transitioning delegate, using the same objects that we already have.

extension DetailViewController: UIViewControllerTransitioningDelegate {

    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FadePushAnimator()
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FadePopAnimator()
    }
}
```
If you run the code and present the modal view controller, that'll work just fine. The problem occurs when you try to dismiss the presented view controller. The whole app will turn to a [black screen](https://stackoverflow.com/questions/28558882/custom-transition-results-in-black-screen-or-unresponsive-screen) of death ([BSOD](https://en.wikipedia.org/wiki/Blue_Screen_of_Death)). 🖥

> (pop != dismiss) && (push != present)

You have to modify the pop animation in order to support modal dismissal animations. In short: the problem is with placing views and memory management.

```swift
open class FadePopAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    public enum TransitionType {
        case navigation
        case modal
    }

    let type: TransitionType
    let duration: TimeInterval

    public init(type: TransitionType, duration: TimeInterval = 0.25) {
        self.type = type
        self.duration = duration

        super.init()
    }

    open func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.duration
    }

    open override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromViewController = transitionContext.viewController(forKey: .from)
        else {
            return
        }

        if self.type == .navigation, let toViewController = transitionContext.viewController(forKey: .to) {
            transitionContext.containerView.insertSubview(toViewController.view, belowSubview: fromViewController.view)
        }

        let duration = self.transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, animations: {
            fromViewController.view.alpha = 0
        }, completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
```

The most simple solution is to introduce a new property so you can make a decision to pop or dismiss the view controller based on that flag. Now you can safely use the same animators for modally presented view controllers as well. 😬

The sample code is inside The.Swift.Dev. [tutorials](https://github.com/theswiftdev/tutorials) repository, you'll find examples for replacing the [default](https://gist.github.com/alanzeino/603293f9da5cd0b7f6b60dc20bc766be) push & pop navigation animations with custom ones.

Note that the navigation bar will always use a fade animation, unfortunately that can not be customized. Also I've made a custom modal presentation, and everything is using the interactive transitions too. Obviously there is a lot more, but below are some links that you can follow if you hit an obstacle during your journey.

Also if you don't want to manually implement custom animation effects you can use [Hero](https://github.com/lkzhao/Hero) the elegant transition [library](https://github.com/carguezu/CGZTransitions).
