---
type: post
slug: how-to-create-reusable-views-for-modern-collection-views
title: How to create reusable views for modern collection views?
description: A quick intro to modern collection views using compositional layout, diffable data source and reusable view components.
publication: 2017-10-10 16:20:00
tags: UIKit, iOS
authors:
  - tibor-bodecs
---

## Reusable views inside a generic cell

We all love to create [custom views](https://theswiftdev.com/custom-views-input-forms-and-mistakes/) for building various user interface elements, right? We also love to use collection views to display data using a grid or a list layout. Collection view cells are custom views, but what if you'd like to use the exact same cell as a view?

Turns out that you can provide your own [UIContentConfiguration](https://developer.apple.com/documentation/uikit/uicontentconfiguration), just like the built-in ones that you can use to setup [cells to look like list items](https://www.biteinteractive.com/collection-view-content-configuration-in-ios-14/). If you take a look at the [modern collection views sample code](https://developer.apple.com/documentation/uikit/views_and_controls/collection_views/implementing_modern_collection_views), which I highly recommend, you'll see how to implement custom content configurations in order to create your own cell types. There are a few things that I don't like about this approach. 😕

First of all, your view has to conform to the [UIContentView](https://developer.apple.com/documentation/uikit/uicontentview) protocol, so you have to handle additional config related stuff inside the view. I prefer the MVVM pattern, so this feels a bit strange. The second thing that you need is a custom cell subclass, where you also have to take care of the configuration updates. What if there was some other way?

Let's start our setup by creating a new subclass for our future cell object, we're simply going to provide the usual initialize method that I always use for my subclasses. Apple often calls this method configure in their samples, but they're more or less the same. 😅

```swift
import UIKit

open class CollectionViewCell: UICollectionViewCell {
        
    @available(*, unavailable)
    private override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.initialize()
    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) isn not available")
    }
    
    open func initialize() {
        
    }

}
```

All right, this is just a basic subclass so we don't have to deal with the init methods anymore. Let's create one more subclass based on this object. The ReusableCell type is going to be a generic type, it's going to have a view property, which is going to be added as a subview to the contentView and we also pin the constraints to the content view.

```swift
import UIKit

open class ReusableCell<View: UIView>: CollectionViewCell {
    
    var view: View!

    open override func initialize() {
        super.initialize()

        let view = View()
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        self.view = view
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: contentView.topAnchor),
            view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
    }
}
```

By using this reusable cell type, it's going to be possible to add a custom view to the cell. We just need to create a new custom view, but that's quite an easy task to do. ✅

```swift
import UIKit

extension UIColor {

    static var random: UIColor {
        .init(red: .random(in: 0...1),
              green: .random(in: 0...1),
              blue: .random(in: 0...1),
              alpha: 1)
    }
}

class CustomView: View {

    let label = UILabel(frame: .zero)

    override func initialize() {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        addSubview(label)
        
        // If you want to set a fixed height for the cell you can use this constraint...
        // let fixedHeightConstraint = heightAnchor.constraint(equalToConstant: 120)
        // fixedHeightConstraint.priority = .defaultHigh
        backgroundColor = .random

        NSLayoutConstraint.activate([
            // fixedHeightConstraint,
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
        ])
    }
}
```

This custom view has a label, which we can pin to the superview with some extra padding. You can [store all your subviews as strong properties](https://theswiftdev.com/uikit-loadview-vs-viewdidload/), since Apple is going to take care of the deinit, even though the addSubview creates a strong reference, you don't have to worry about it anymore.

If you want to create a cell that supports dynamic height, you should simply pin the edge layout constraints, but if you'd like to use a fixed height cell you can add your own height anchor constraint with a constant value. You have to set a custom priority for the height constraint this way the auto layout system won't break and it's going to be able to satisfy all the necessary constraints.

## Compositional layout basics

The [UICollectionViewCompositionalLayout](https://developer.apple.com/documentation/uikit/uicollectionviewcompositionallayout) class is a highly adaptive and flexible layout tool that you can use to build modern collection view layouts. It has three main components that you can configure to display your custom user interface elements in many different ways.

> You combine the components by building up from items into a group, from groups into a section, and finally into a full layout, like in this example of a basic list layout:

There are plenty of great [resources](https://www.zealousweb.com/how-to-use-compositional-layout-in-collection-view/) and [tutorials](https://www.raywenderlich.com/5436806-modern-collection-views-with-compositional-layouts) about this topic, so I won't get too much into the details now, but we're going to create a simple layout that can display full width ([fractional layout dimension](https://developer.apple.com/documentation/uikit/nscollectionlayoutdimension)) items in a full width group, by using and estimated height to support dynamic cell sizes. I suppose this is quite a common use-case for many of us. We can create an extension on the UICollectionViewLayout object to instantiate a new list layout. 🙉

```swift
extension UICollectionViewLayout {
    static func createListLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
      
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)

        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}
```

Now it is possible to add a collectionView to our view hierarchy inside the view controller.

```swift
class ViewController: UIViewController {

    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .createListLayout())

    override func loadView() {
        super.loadView()

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: collectionView.topAnchor),
            view.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor),
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }
}
```

You can also create your own auto layout helper extensions, or use [SnapKit](http://snapkit.io/) to quickly setup your layout constraints. It is relatively easy to work with anchors, you should read my other tutorial about [mastering auto layout anchors](https://theswiftdev.com/mastering-ios-auto-layout-anchors-programmatically-from-swift/) if you don't know much about them.

## Cell registration and diffable data source

Apple has a [new set of APIs](https://developer.apple.com/documentation/uikit/uicollectionview/cellregistration) to register and dequeue cells for modern collection views. It is worth to mention that almost everything we talk about this tutorials is only available on iOS14+ so if you are planning to support an older version you won't be able to use these features.

If you want to learn more about the topic, I'd like to recommend an [article](https://www.donnywals.com/configure-collection-view-cells-with-uicollectionview-cellregistration/) by Donny Wals and there is a great, but a bit longer [post](https://www.swiftbysundell.com/articles/building-modern-collection-views-in-swift/) by John Sundell about modern collection views. I'm using the same helper extension to get a cell provider using a cell registration object, to make the process more simple, plus we're going to need some random sentences, so let's add a few helpers. 💡

```swift
extension String {
    static func randomWord() -> String {
        (0..<Int.random(in: 1...10)).map { _ in String(format: "%c", Int.random(in: 97..<123)) }.joined(separator: "")
    }

    static func randomSentence() -> String {
        (0...50).map { _ in randomWord() }.joined(separator: " ")
    }
}

extension UICollectionView.CellRegistration {

    var cellProvider: (UICollectionView, IndexPath, Item) -> Cell {
        { collectionView, indexPath, product in
            collectionView.dequeueConfiguredReusableCell(using: self, for: indexPath, item: product)
        }
    }
}
```

Now we can use the new [UICollectionViewDiffableData](https://developer.apple.com/documentation/uikit/uicollectionviewdiffabledatasource) class to specify our sections and items inside the collection view. You can define your sections as an enum, and in this case we're going to use a String type as our items. There is a [great tutorial](https://www.appcoda.com/diffable-data-source/) by AppCoda about diffable data sources.

Long story short, you should make a new cell configuration where now you can use the ReusableCell with a CustomView, then it is possible to setup the diffable data source with the cellProvider on the cellRegistration object. Finally we can apply an initial snapshot by appending a new section and our items to the snapshot. You can update the data source with the snapshot and the nice thing about is it that you can also animate the changes if you want. 😍

```swift
enum Section {
    case `default`
}

class ViewController: UIViewController {

    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .createListLayout())
    var dataSource: UICollectionViewDiffableDataSource<Section, String>!
    let data: [String] = (0..<10).map { _ in String.randomSentence() }

    override func loadView() {
        super.loadView()

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: collectionView.topAnchor),
            view.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor),
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self

        createDataSource()
        applyInitialSnapshot()
    }

    func createDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<ReusableCell<CustomView>, String> { cell, indexPath, model in
            cell.view.label.text = model
        }

        dataSource = UICollectionViewDiffableDataSource<Section, String>(collectionView: collectionView,
                                                                         cellProvider: cellRegistration.cellProvider)
    }
    
    func applyInitialSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, String>()
        snapshot.appendSections([.default])
        snapshot.appendItems(data)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension ViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = dataSource.itemIdentifier(for: indexPath)

        print(item ?? "n/a")
    }
}
```

You still have to implement a delegate method if you'd like to handle cell selection, but fortunately the diffable data source has an itemIdentifier method to look up elements inside the data source.

As you can see it's pretty easy to come up with a generic cell that can be used to render a custom view inside a collection view. I believe that the "official" cell configuration based approach is a bit more complicated, plus you have to write quite a lot of code if it comes to modern collection views.

I'm going to update my original collection view framework with these new techniques for sure. The new compositional layout is way more powerful compared to regular flow layouts, diffable data sources are also amazing and the new cell registration API is also nice. I believe that the collection view team at Apple did an amazing job during the years, it's still one of my favorite components if it comes to UIKit development. I highly recommend learning these modern techniques. 👍
