---
type: post
title: VIPER best practices for iOS developers
description: "In this tutorial I'm going to show you a complete guide about how to build a VIPER based iOS application, written entirely in Swift."
publication: 2019-03-11 16:20:00
tags: 
    - viper
authors:
    - tibor-bodecs
---

## Getting started with VIPER

First of all, you should read my previous (more theoretical) article [about the VIPER architecture](https://theswiftdev.com/2018/03/12/the-ultimate-viper-architecture-tutorial/) itself. It's a pretty decent writing explaining all the VIPER components and memory management. I've also polished it a little bit, last week. ⭐️

The problem with that article however was that I haven't show you the real deal, aka. the Swift code for implementing VIPER. Now after a full year of projects using this architecture I can finally share all my best practices with you.

So, let's start by creating a brand new Xcode project, use the single view app template, name the project (VIPER best practices), use Swift and now you're ready to take the next step of making an awesome "enterprise grade" iOS app.

## Generating VIPER modules

Lesson 1: never create a module by hand, always use a code generator, because it's a repetative task, it's fuckin' boring plus you should focus on more important things than making boilerplate code. You can use my lightweight module generator called:

> WARN: This section is outdated, you should use the swift template repository.

Just download or clone the repository from [GitHub](https://github.com/binarybirds/swift-template). You can install the binary tool by running swift run install --with-templates. This will install the vipera app under /usr/local/bin/ and the basic templates under the ~/.vipera directory. You can use your own templates too, but for now I'll work with the default one. 🔨

I usually start with a module called Main that's the root view of the application. You can generate it by calling vipera Main in the project directory, so the generator can use the proper project name for the header comments inside the template files.

Clean up the project structure a little bit, by applying my [conventions for Xcode](https://theswiftdev.com/2016/07/06/conventions-for-xcode/), this means that resources goes to an Assets folder, and all the Swift files into the Sources directory. Nowadays I also change the AppDelegate.swift file, and I make a separate extension for the UIApplicationDelegate protocol.

Create a Modules group (with a physical folder too) under the Sources directory and move the newly generated Main module under that group. Now fix the project issues, by selecting the Info.plist file from the Assets folder for the current target. Also do remove the Main Interface, and after that you can safely delete the Main.storyboard and the ViewController.swift files, because we're not going to need them at all.

Inside the AppDelegate.swift file, you have to set the Main module's view controller as the root view controller, so it should look somewhat like this:

```swift
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder {

    var window: UIWindow?
}

extension AppDelegate: UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = MainModule().buildDefault()
        self.window?.makeKeyAndVisible()

        return true
    }
}
```

Congratulations, you've created your very first VIPER module! 🎉

## UITabBarController & VIPER

I have a super simple solution for using a tab bar controller in a VIPER module. First let's generate a few new modules, those are going to be the tabs. I'm going to use the [JSONPlaceholder](https://jsonplaceholder.typicode.com/) service, so let's imagine a separate tab for each of these resources: posts, albums, photos, todos (with the same module name). Generate them all, and move them into the modules folder.

Now, let's generate one more module called Home. This will implement our tab bar controller view. If you want you can use the Main module for this purpose, but I like to keep that for animation purposes, to have a neat transition between the loading screen and my Home module (it all depends on your needs).

So the main logic that we're going to implement is this: the main view will notify the presenter about the viewDidAppear event, and the presenter will ask the router to display the Home module. The Home module's view will be a subclass of a UITabBarController, it'll also notify it's presenter about viewDidLoad, and the presenter will ask for the proper tabs, by using its router.

Here is the code, without the interfaces:

```swift
class MainDefaultView: UIViewController {

    var presenter: MainPresenter?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.presenter?.viewDidAppear()
    }
}

extension MainDefaultPresenter: MainPresenter {

    func viewDidAppear() {
        self.router?.showHome()
    }
}

extension MainDefaultRouter: MainRouter {

    func showHome() {
        let viewController = HomeModule().buildDefault()
        self.viewController?.present(viewController, animated: true, completion: nil)
    }
}

extension HomeDefaultView: HomeView {

    func display(_ viewControllers: [UIViewController]) {
        self.viewControllers = viewControllers
    }
}

// MARK: - Home module

extension HomeDefaultPresenter: HomePresenter {

    func setupViewControllers() {
        guard let controllers = self.router?.getViewControllers() else {
            return
        }
        self.view?.display(controllers)
    }

}

extension HomeDefaultRouter: HomeRouter {

    func getViewControllers() -> [UIViewController] {
        return [
            PostsModule().buildDefault(),
            AlbumsModule().buildDefault(),
            PhotosModule().buildDefault(),
            TodosModule().buildDefault(),
        ].map { UINavigationController(rootViewController: $0) }
    }
}

class HomeModule {

    func buildDefault() -> UIViewController {
        /* ... */

        presenter.setupViewControllers()

        return view
    }
}
```

There is one additional line inside the Home module builder function that triggers the presenter to setup proper view controllers. That's just because the UITabBarController viewDidLoad method gets called before the init process finishes. This behaviour is quite undocumented but I assume it's an UIKit hack in order to maintain the view references (or just a simple bug... is anyone from Apple here?). 😊

Anyway, now you have a proper tab bar inside the project integrated as a VIPER module. It's time to get some data from the server and here comes another important lesson: not everything is a VIPER module.

Services and entities
As you might noticed there is no such thing as an Entity inside my modules. I usually wrap APIs, CoreData and many more data providers as a service. This way, all the related entities can be abstracted away, so the service can be easily replaced (with a mock for example) and all my interactors can use the service through the protocol definition without knowing the underlying implementation.

Another thing is that I always use [my promise library](https://github.com/corekit/promises) if I have to deal with async code. The reason behind it is pretty simple: it's way more elegant than using callbacks and optional [result](https://theswiftdev.com/2019/01/28/how-to-use-the-result-type-to-handle-errors-in-swift/) elements. You should learn promises too. So here is some part of my service implementation around the JSONPlaceholder API:

```swift
protocol Api {

    func posts() -> Promise<[Post]>
    func comments(for post: Post) -> Promise<[Comment]>
    func albums() -> Promise<[Album]>
    func photos(for album: Album) -> Promise<[Photo]>
    func todos() -> Promise<[Todo]>
}

// MARK: - entities

struct Post: Codable {

    let id: Int
    let title: String
    let body: String
}

// MARK: - API implementation

class JSONPlaceholderService {

    var baseUrl = URL(string: "https://jsonplaceholder.typicode.com/")!

    enum Error: LocalizedError {
        case invalidStatusCode
        case emptyData
    }

    private func request<T>(path: String) -> Promise<T> where T: Decodable {
        let promise = Promise<T>()
        let url = baseUrl.appendingPathComponent(path)
        print(url)
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                promise.reject(error)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                promise.reject(Error.invalidStatusCode)
                return
            }
            guard let data = data else {
                promise.reject(Error.emptyData)
                return
            }
            do {
                let model = try JSONDecoder().decode(T.self, from: data)
                promise.fulfill(model)
            }
            catch {
                promise.reject(error)
            }
        }.resume()
        return promise
    }
}

extension JSONPlaceholderService: Api {

    func posts() -> Promise<[Post]> {
        return self.request(path: "posts")
    }

    /* ... */
}
```

Usually I have a mock service implementation next to this one, so I can easily test out everything I want. How do I switch between these services? Well, there is a shared ([singleton](https://theswiftdev.com/2018/05/23/swift-singleton-design-pattern/) - don't hate me it's completely fine 🤪) App class that I use mostly for [styling purposes](https://theswiftdev.com/2019/02/19/styling-by-subclassing/), but I also put the dependency injection ([DI](https://theswiftdev.com/2018/07/17/swift-dependency-injection-design-pattern/)) related code there too. This way I can pass around proper service objects for the VIPER modules.

```swift
class App {

    static let shared = App()

    private init() {

    }

    var apiService: Api {
        return JSONPlaceholderService()
    }
}

// MARK: - module

class PostsModule {

    func buildDefault() -> UIViewController {
        let view = PostsDefaultView()
        let interactor = PostsDefaultInteractor(apiService: App.shared.apiService)

        /* ... */

        return view
    }
}

// MARK: - interactor

class PostsDefaultInteractor {

    weak var presenter: PostsPresenter?

    var apiService: Api

    init(apiService: Api) {
        self.apiService = apiService
    }
}

extension PostsDefaultInteractor: PostsInteractor {

    func posts() -> Promise<[Post]> {
        return self.apiService.posts()
    }

}
```

You can do this in a 100 other ways, but I currently prefer this approach. This way interactors can directly call the service with some extra details, like filters, order, sort, etc. Basically the service is just a high concept wrapper around the endpoint, and the interactor is creating the fine-tuned (better) API for the presenter.

## Making promises

Implementing the business logic is the task of the presenter. I always use promises so a basic presenter implementation that only loads some content asynchronously and displays the results or the error (plus a loading indicator) is just a few lines long. I'm always trying to implement the three [basic UI stack elements](http://scotthurff.com/posts/why-your-user-interface-is-awkward-youre-ignoring-the-ui-stack) (loading, data, error) by using the same protocol naming conventions on the view. 😉

On the view side I'm using my good old collection view logic, which significantly reduces the amount of code I have to write. You can go with the traditional way, implementing a few data source & delegate method for a table or collection view is not so much code after all. Here is my view example:

```swift
extension PostsDefaultPresenter: PostsPresenter {

    func viewDidLoad() {
        self.view?.displayLoading()
        self.interactor?.posts()
        .onSuccess(queue: .main) { posts  in
            self.view?.display(posts)
        }
        .onFailure(queue: .main) { error in
            self.view?.display(error)
        }
    }
}

// MARK: - view

class PostsDefaultView: CollectionViewController {

    var presenter: PostsPresenter?

    init() {
        super.init(nibName: nil, bundle: nil)

        self.title = "Posts"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.presenter?.viewDidLoad()
    }
}

extension PostsDefaultView: PostsView {

    func displayLoading() {
        print("loading...")
    }

    func display(_ posts: [Post]) {
        let grid = Grid(columns: 1, margin: UIEdgeInsets(all: 8))

        self.source = CollectionViewSource(grid: grid, sections: [
            CollectionViewSection(items: posts.map { PostViewModel($0) })
        ])
        self.collectionView.reloadData()
    }

    func display(_ error: Error) {
        print(error.localizedDescription)
    }
}
```

The cell and the ViewModel is outside the VIPER module, I tend to dedicate an App folder for the custom application specific views, extensions, view models, etc.

```swift
class PostCell: CollectionViewCell {

    @IBOutlet weak var textLabel: UILabel!
}

class PostViewModel: CollectionViewViewModel<PostCell, Post> {

    override func config(cell: PostCell, data: Post, indexPath: IndexPath, grid: Grid) {
        cell.textLabel.text = data.title
    }

    override func size(data: Post, indexPath: IndexPath, grid: Grid, view: UIView) -> CGSize {
        let width = grid.width(for: view, items: grid.columns)
        return CGSize(width: width, height: 64)
    }
}
```

Nothing special, if you'd like to know more about this collection view architecture, you should read my other [tutorial about mastering collection views](https://theswiftdev.com/2018/04/17/ultimate-uicollectionview-guide-with-ios-examples-written-in-swift/).

## Module communication

Another important lesson is to learn how to communicate between two VIPER modules. Normally I go with simple variables - and delegates if I have to send back some sort of info to the original module - that I pass around inside the build methods. I'm going to show you a really simple example for this too.

```swift
class PostsDefaultRouter {

    weak var presenter: PostsPresenter?
    weak var viewController: UIViewController?
}

extension PostsDefaultRouter: PostsRouter {

    func showComments(for post: Post) {
        let viewController = PostDetailsModule().buildDefault(with: post, delegate: self)
        self.viewController?.show(viewController, sender: nil)
    }
}

extension PostsDefaultRouter: PostDetailsModuleDelegate {

    func toggleBookmark(for post: Post) {
        self.presenter?.toggleBookmark(for: post)
    }
}

// MARK: - details


protocol PostDetailsModuleDelegate: class {
    func toggleBookmark(for post: Post)
}

class PostDetailsModule {

    func buildDefault(with post: Post, delegate: PostDetailsModuleDelegate? = nil) -> UIViewController {
        let view = PostDetailsDefaultView()
        let interactor = PostDetailsDefaultInteractor(apiService: App.shared.apiService,
                                                      bookmarkService: App.shared.bookmarkService)
        let presenter = PostDetailsDefaultPresenter(post: post)

        /* ... */

        return view
    }
}

class PostDetailsDefaultRouter {

    weak var presenter: PostDetailsPresenter?
    weak var viewController: UIViewController?
    weak var delegate: PostDetailsModuleDelegate?
}

extension PostDetailsDefaultRouter: PostDetailsRouter {

    func toggleBookmark(for post: Post) {
        self.delegate?.toggleBookmark(for: post)
    }
}


class PostDetailsDefaultPresenter {

    var router: PostDetailsRouter?
    var interactor: PostDetailsInteractor?
    weak var view: PostDetailsView?

    let post: Post

    init(post: Post) {
        self.post = post
    }
}

extension PostDetailsDefaultPresenter: PostDetailsPresenter {

    func reload() {
        self.view?.setup(with: self.interactor!.bookmark(for: self.post))

        //display loading...
        self.interactor?.comments(for: self.post)
        .onSuccess(queue: .main) { comments in
            self.view?.display(comments)
        }
        .onFailure(queue: .main) { error in
            //display error...
        }
    }

    func toggleBookmark() {
        self.router?.toggleBookmark(for: self.post)
        self.view?.setup(with: self.interactor!.bookmark(for: self.post))
    }
}
```

In the builder method I can access every component of the VIPER module so I can simply pass around the variable to the designated place (same applies for the delegate parameter). I usually set input variables on the presenter and delegates on the router.

It's usually a presenter who needs data from the original module, and I like to store the delegate on the router, because if the navigation pattern changes I don't have to change the presenter at all. This is just a personal preference, but I like the way it looks like in code. It's really hard to write down these things in a single article, so I'd recommend to download my finished sample code from [GitHub](https://github.com/theswiftdev/tutorials).

## Summary

As you can see I'm using various design patterns in this VIPER architecture tutorial. Some say that there is no silver bullet, but I believe that I've found a really amazing methodology that I can turn on my advantage to build quality apps in a short time.

Combining Promises, MVVM with collection views on top of a VIPER structure simply puts every single piece into the right place. Over-engineered? Maybe. For me it's worth the overhead. What do you think about it? Feel free to message me through twitter. You can also subscribe to my monthly newsletter below.
