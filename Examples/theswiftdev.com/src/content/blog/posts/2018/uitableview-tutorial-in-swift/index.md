---
type: post
slug: uitableview-tutorial-in-swift
title: UITableView tutorial in Swift
description: This guide is made for beginners to learn the foundations of the UITableView class programmatically with auto layout in Swift.
publication: 2018-12-01 16:20:00
tags: UIKit, iOS, UITableView
authors:
  - tibor-bodecs
---

## How to create a table view programmatically?

Let's jump straight into the [coding](http://www.thomashanning.com/uitableview-tutorial-for-beginners/) part, but first: start Xcode, create a new iOS single view app project, enter some name & details for the project as usual, use Swift and finally open the ViewController.swift file right away. Now grab your keyboard! ⌨️

> Pro tip: use Cmd+Shift+O to quickly jump between files

I'm not going to use interface builder in this tutorial, so how do we create views programmatically? There is a method called loadView that's where you should add custom views to your view hierarchy. You can option+click the method name in Xcode & read the discussion about [loadView](https://developer.apple.com/documentation/uikit/uiviewcontroller/1621454-loadview) method, but let me summarize the whole thing.

We'll use a weak property to hold a reference to our table view. Next, we override the loadView method & call super, in order to load the controller's self.view property with a view object (from a nib or a storyboard file if there is one for the controller). After that we assign our brand new view to a local property, turn off system provided layout stuff, and insert our table view into our view hierarchy. Finally we create some real constraints using anchors & save our pointer to our weak property. Easy! 🤪

```swift
class ViewController: UIViewController {

    weak var tableView: UITableView!

    override func loadView() {
        super.loadView()

        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(tableView)
        NSLayoutConstraint.activate([
        self.view.safeAreaLayoutGuide.topAnchor.constraint(equalTo: tableView.topAnchor),
            self.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: tableView.bottomAnchor),
            self.view.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
            self.view.trailingAnchor.constraint(equalTo: tableView.trailingAnchor),
        ])
        self.tableView = tableView
    }
}
```

Always use auto layout anchors to specify view constraints, if you don't know how to use them, check my [layout anchors tutorial](https://theswiftdev.com/2018/06/14/mastering-ios-auto-layout-anchors-programmatically-from-swift/), it's takes only about 15 minutes to learn this API, and you won't regret it. It's an extremely useful tool for any iOS developer! 😉

You might ask: should I use [weak or strong](https://krakendev.io/blog/weak-and-unowned-references-in-swift) properties for view references? I'd say in most of the cases if you are not overriding self.view you should use weak! The view hierarchy will hold your custom view through a strong reference, so there is no need for stupid retain cycles & memory leaks. Trust me! 🤥

## UITableViewDataSource basics

Okay, we have an empty table view, let's display some [cells](https://samwize.com/2016/02/24/everything-about-uitableview/)! In order to fill our table view with real data, we have to conform to the UITableViewDataSource protocol. Through a simple [delegate pattern](https://theswiftdev.com/2018/06/27/swift-delegate-design-pattern/), we can provide various information for the UITableView class, so it'll to know how much sections and rows will be needed, what kind of cells should be displayed for each row, and many more little details.

Another thing is that UITableView is a really efficient class. It'll reuse all the cells that are currently not displayed on the screen, so it'll consume way less memory than a UIScrollView, if you have to deal with hundreds or thousands of items. To support this behavior we have to register our cell class with a reuse identifier, so the underlying system will know what kind of cell is needed for a specific place. ⚙️

```swift
class ViewController: UIViewController {

    var items: [String] = [
        "👽", "🐱", "🐔", "🐶", "🦊", "🐵", "🐼", "🐷", "💩", "🐰",
        "🤖", "🦄", "🐻", "🐲", "🦁", "💀", "🐨", "🐯", "👻", "🦖",
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")

        self.tableView.dataSource = self
    }
}

extension ViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        let item = self.items[indexPath.item]
        cell.textLabel?.text = item
        return cell
    }
}
```

After adding a few lines of code to our view controller file, the table view is now able to display a nice list of emojis! We are using the built-in UITableViewCell class from UIKit, which comes really handy if you are good to go with the "iOS-system-like" cell designs. We also conformed to the data source protocol, by telling how many items are in our section (currently there is only one section), and we configured our cell inside the famous cell for row at indexPath delegate method. 😎

## Customizing table view cells

UITableViewCell can provide some basic elements to display data (title, detail, image in different styles), but usually you'll need custom designed cells. Here is a basic template of a custom cell subclass, I'll explain all the methods after the code.

```swift
class MyCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.initialize()
    }

    func initialize() {

    }
    /*
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    */
    override func prepareForReuse() {
        super.prepareForReuse()

    }
}
```

The `init(style:reuseIdentifier)` method is a great place to override the cell style property if you are going to use the default UITableViewCell programmatically, but with different styles (there is no option to set cellStyle after the cell was initialized). For example if you need a `.value1` styled cell, just pass the argument directly to the super call. This way you can benefit from the 4 predefined [cell styles](https://developer.apple.com/documentation/uikit/uitableviewcellstyle).

> You'll also have to implement `init(coder:)`, so you should create a common initialize() function where you'll be able to add your custom views to the view hierarchy, like we did in the loadView method above. If you are using xib files & IB, you can use the awakeFromNib method to add extra style to your views through the standard `@IBOutlet` properties (or add extra views to the hierarchy as well). 👍

The last method that we have to talk about is `prepareForReuse`. As I mentioned before cells are being reused so if you want to reset some properties, like the background of a cell, you can do it here. This method will be called before the cell is going to be reused.

Let's make two new cell subclasses to play around with.

```swift
class DetailCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)

        self.initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.initialize()
    }

    func initialize() {
        // nothing to do here :)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.textLabel?.text = nil
        self.detailTextLabel?.text = nil
        self.imageView?.image = nil
    }
}
```

Our custom cell will have a big image background plus a title label in the center of the view with a custom sized system font. Also I've added the [Swift logo](https://commons.wikimedia.org/wiki/File:Swift_logo.svg) as an asset to the project, so we can have a nice demo image. 🖼

```swift
class CustomCell: UITableViewCell {

    weak var coverView: UIImageView!
    weak var titleLabel: UILabel!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.initialize()
    }

    func initialize() {
        let coverView = UIImageView(frame: .zero)
        coverView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(coverView)
        self.coverView = coverView

        let titleLabel = UILabel(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(titleLabel)
        self.titleLabel = titleLabel

        NSLayoutConstraint.activate([
            self.contentView.topAnchor.constraint(equalTo: self.coverView.topAnchor),
            self.contentView.bottomAnchor.constraint(equalTo: self.coverView.bottomAnchor),
            self.contentView.leadingAnchor.constraint(equalTo: self.coverView.leadingAnchor),
            self.contentView.trailingAnchor.constraint(equalTo: self.coverView.trailingAnchor),

            self.contentView.centerXAnchor.constraint(equalTo: self.titleLabel.centerXAnchor),
            self.contentView.centerYAnchor.constraint(equalTo: self.titleLabel.centerYAnchor),
        ])

        self.titleLabel.font = UIFont.systemFont(ofSize: 64)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.coverView.image = nil
    }
}
```

That's it, let's start using these new cells. I'll even tell you how to set custom height for a given cell, and how to handle cell selection properly, but first we need to get to know with another delegate protocol. 🤝

## Basic UITableViewDelegate tutorial

This delegate is responsible for lots of things, but for now we're going to cover just a few interesting aspects, like how to handle cell selection & provide a custom cell height for each items inside the table. Here is a quick sample code.

```swift
class ViewController: UIViewController {

    override func viewDidLoad() {
            super.viewDidLoad()

            self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
            self.tableView.register(DetailCell.self, forCellReuseIdentifier: "DetailCell")
            self.tableView.register(CustomCell.self, forCellReuseIdentifier: "CustomCell")

            self.tableView.dataSource = self
            self.tableView.delegate = self
    }
}
extension ViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomCell
        let item = self.items[indexPath.item]
        cell.titleLabel.text = item
        cell.coverView.image = UIImage(named: "Swift")
        return cell
    }
}

extension ViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 128
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = self.items[indexPath.item]

        let alertController = UIAlertController(title: item, message: "is in da house!", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default) { _ in }
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
}
```

As you can see I'm registering my brand new custom cell classes in the `viewDidLoad` method. I also changed the code inside the `cellForRowAt` indexPath method, so we can use the `CustomCell` class instead of `UITableViewCells`. Don't be afraid of force casting here, if something goes wrong at this point, your app should crash. 🙃

There are two delegate methods that we are using here. In the first one, we have to return a number and the system will use that height for the cells. If you want to use different cell height per row, you can achieve that too by checking indexPath property or anything like that. The second one is the handler for the selection. If someone taps on a cell, this method will be called & you can perform some action.

> An indexPath has two interesting properties: section & item (=row)

## Multiple sections with headers and footers

It's possible to have [multiple](https://medium.com/@stasost/ios-how-to-build-a-table-view-with-multiple-cell-types-2df91a206429) sections inside the table view, I won't go too much into the details, because it's pretty straightforward. You just have to use indexPaths in order to get / set / return the proper data for each section & cell.

```swift
import UIKit

class ViewController: UIViewController {

    weak var tableView: UITableView!

    var placeholderView = UIView(frame: .zero)
    var isPullingDown = false

    enum Style {
        case `default`
        case subtitle
        case custom
    }

    var style = Style.default

    var items: [String: [String]] = [
        "Originals": ["👽", "🐱", "🐔", "🐶", "🦊", "🐵", "🐼", "🐷", "💩", "🐰","🤖", "🦄"],
        "iOS 11.3": ["🐻", "🐲", "🦁", "💀"],
        "iOS 12": ["🐨", "🐯", "👻", "🦖"],
    ]

    override func loadView() {
        super.loadView()

        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(tableView)
        NSLayoutConstraint.activate([
            self.view.safeAreaLayoutGuide.topAnchor.constraint(equalTo: tableView.topAnchor),
            self.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: tableView.bottomAnchor),
            self.view.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
            self.view.trailingAnchor.constraint(equalTo: tableView.trailingAnchor),
        ])
        self.tableView = tableView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        self.tableView.register(DetailCell.self, forCellReuseIdentifier: "DetailCell")
        self.tableView.register(CustomCell.self, forCellReuseIdentifier: "CustomCell")

        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.separatorStyle = .singleLine
        self.tableView.separatorColor = .lightGray
        self.tableView.separatorInset = .zero

        self.navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .refresh, target: self, action: #selector(self.toggleCells))
    }

    @objc func toggleCells() {

        switch self.style {
        case .default:
            self.style = .subtitle
        case .subtitle:
            self.style = .custom
        case .custom:
            self.style = .default
        }

        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    // MARK: - helpers

    func key(for section: Int) -> String {
        let keys = Array(self.items.keys).sorted { first, last -> Bool in
            if first == "Originals" {
                return true
            }
            return first < last
        }
        let key = keys[section]
        return key
    }

    func items(in section: Int) -> [String] {
        let key = self.key(for: section)
        return self.items[key]!
    }

    func item(at indexPath: IndexPath) -> String {
        let items = self.items(in: indexPath.section)
        return items[indexPath.item]
    }
}

extension ViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.items.keys.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items(in: section).count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.item(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomCell
        cell.titleLabel.text = item
        cell.coverView.image = UIImage(named: "Swift")
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.key(for: section)
    }

}

extension ViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 128
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let item = self.item(at: indexPath)
        let alertController = UIAlertController(title: item, message: "is in da house!", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default) { _ in }
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
}
```

Although there is one interesting addition in the code snippet above. You can have a custom title for every section, you just have to add the `titleForHeaderInSection` data source method. Yep, it looks like shit, but this one is not about perfect UIs. 😂

However if you are not satisfied with the layout of the section titles, you can create a custom class & use that instead of the built-in ones. Here is how to do a custom section header view. Here is the implementation of the reusable view:

```swift
class HeaderView: UITableViewHeaderFooterView {

    weak var titleLabel: UILabel!

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        self.initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.initialize()
    }

    func initialize() {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(titleLabel)
        self.titleLabel = titleLabel

        NSLayoutConstraint.activate([
            self.contentView.centerXAnchor.constraint(equalTo: self.titleLabel.centerXAnchor),
            self.contentView.centerYAnchor.constraint(equalTo: self.titleLabel.centerYAnchor),
        ])

        self.contentView.backgroundColor = .black
        self.titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        self.titleLabel.textAlignment = .center
        self.titleLabel.textColor = .white
    }
}
```

There is only a few things left to do, you have to register your header view, just like you did it for the cells. It's exactly the same way, except that there is a separate registration "pool" for the header & footer views. Lastly you have to implement two additional, but relatively simple (and familiar) delegate methods.

```swift
// This goes to viewDidLoad, but I don't want to embedd that much code... :)
// self.tableView.register(HeaderView.self, forHeaderFooterViewReuseIdentifier: "HeaderView")

extension ViewController: UITableViewDelegate {

    /* ... */

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HeaderView") as! HeaderView
        view.titleLabel.text = self.key(for: section)
        return view
    }
}
```

> Footers works exactly the same as headers, you just have to implement the corresponding data source & delegate methods in order to support them.

You can even have multiple cells in the same table view based on the row or section index or any specific business requirement. I'm not going to demo this here, because I have a way better solution for mixing and reusing cells inside the [CoreKit framework](https://gitlab.com/corekit/CoreKit). It's already there for table views as well, plus I already covered this idea in my [ultimate collection view tutorial](https://theswiftdev.com/2018/04/17/ultimate-uicollectionview-guide-with-ios-examples-written-in-swift/) post. You should check that too. 🤓

## Section titles & indexes

Ok, if your brain is not melted yet, I'll show you two more little things that can be interesting for beginners. The first one is based on two additional data source methods and it's a very pleasant addition for long lists. (I prefer search bars!) 🤯

```swift
extension ViewController: UITableViewDataSource {
    /* ... */

    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return ["1", "2", "3"]
    }

    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
}
```

If you are going to implement these methods above you can have a little index view for your sections in the right side of the table view, so the end-user will be able to quickly jump between sections. Just like in the official contacts app. 📕

## Selection vs highlight

Cells are highlighted when you are holding them down with your finger. Cell is going to be selected if you release your finger from the cell.

Don't [over-complicate](https://medium.com/@imho_ios/why-uitableviewcell-highlight-and-selection-styling-are-such-a-mystery-1ae1599e660a) this. You just have to implement two methods in you custom cell class to make everything work. I prefer to deselect my cells right away, if they're not for example used by some sort of data picker layout. Here is the code:

```swift
class CustomCell: UITableViewCell {

    /* ... */

    override func setSelected(_ selected: Bool, animated: Bool) {
        self.coverView.backgroundColor = selected ? .red : .clear
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        self.coverView.backgroundColor = highlighted ? .blue : .clear
    }
}
```

As you can see, it's ridiculously easy, but most of the beginners don't know how to do this. Also they usually forget to reset cells before the reusing logic happens, so the list keeps messing up cell states. Don't worry too much about these problems, they'll go away as you're going to be more experienced with the UITableView APIs.
