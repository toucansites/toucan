---
type: post
slug: working-with-diffable-data-sources-and-table-views-using-uikit
title: Working with diffable data sources and table views using UIKit
description: In this tutorial we're going to build a screen to allow single and multiple selections using diffable data source and a table view.
publication: 2022-03-24 16:20:00
tags: UIKit, iOS, UITableView
authors:
  - tibor-bodecs
---

## Project setup

We're going to use a regular storyboard-based Xcode project, since we're working with UIKit.

We're also going to need a table view, for this purpose we could go with a [traditional setup](https://theswiftdev.com/uitableview-tutorial-in-swift/), but since we're using modern UIKit practices we're going to do things just a bit different this time.

It's quite unfortunate that we still have to provide our own type-safe reusable extensions for UITableView and UICollectionView classes. Anyway, here's a quick snippet that we'll use. ⬇️

```swift
import UIKit

extension UITableViewCell {
    
    static var reuseIdentifier: String {
        String(describing: self)
    }

    var reuseIdentifier: String {
        type(of: self).reuseIdentifier
    }
}

extension UITableView {
        
    func register<T: UITableViewCell>(_ type: T.Type) {
        register(T.self, forCellReuseIdentifier: T.reuseIdentifier)
    }

    func reuse<T: UITableViewCell>(_ type: T.Type, _ indexPath: IndexPath) -> T {
        dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as! T
    }
}
```

I've also created a subclass for UITableView, so I can configure everything inside the initialize function that we're going to need in this tutorial.

```swift
import UIKit

open class TableView: UITableView {

    public init(style: UITableView.Style = .plain) {
        super.init(frame: .zero, style: style)
        
        initialize()
    }

    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func initialize() {
        translatesAutoresizingMaskIntoConstraints = false
        allowsMultipleSelection = true
    }
    
    func layoutConstraints(in view: UIView) -> [NSLayoutConstraint] {
        [
            topAnchor.constraint(equalTo: view.topAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor),
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ]
    }
}
```

We are going to build a settings screen with a single selection and a multiple selection area, so it's nice to have some extensions too that'll help us to manage the selected table view cells. 💡

```swift
import UIKit

public extension UITableView {
    
    func select(_ indexPaths: [IndexPath],
                animated: Bool = true,
                scrollPosition: UITableView.ScrollPosition = .none) {
        for indexPath in indexPaths {
            selectRow(at: indexPath, animated: animated, scrollPosition: scrollPosition)
        }
    }
    

    func deselect(_ indexPaths: [IndexPath], animated: Bool = true) {
        for indexPath in indexPaths {
            deselectRow(at: indexPath, animated: animated)
        }
    }
    
    func deselectAll(animated: Bool = true) {
        deselect(indexPathsForSelectedRows ?? [], animated: animated)
    }

    func deselectAllInSection(except indexPath: IndexPath) {
        let indexPathsToDeselect = (indexPathsForSelectedRows ?? []).filter {
            $0.section == indexPath.section && $0.row != indexPath.row
        }
        deselect(indexPathsToDeselect)
    }
}
```

Now we can focus on creating a custom cell, we are going to use the new cell configuration API, but first we need a model for our custom cell class.

```swift
import Foundation

protocol CustomCellModel {
    var text: String { get }
    var secondaryText: String? { get }
}

extension CustomCellModel {
    var secondaryText: String? { nil }
}
```

Now we can use this cell model and configure the CustomCell using the model properties. This cell will have two states, if the cell is selected we're going to display a filled check mark icon, otherwise just an empty circle. We also update the labels using the abstract model values. ✅

```swift
import UIKit

class CustomCell: UITableViewCell {

    var model: CustomCellModel?

    override func updateConfiguration(using state: UICellConfigurationState) {
        super.updateConfiguration(using: state)
        
        var contentConfig = defaultContentConfiguration().updated(for: state)
        contentConfig.text = model?.text
        contentConfig.secondaryText = model?.secondaryText
        
        contentConfig.imageProperties.tintColor = .systemBlue
        contentConfig.image = UIImage(systemName: "circle")

        if state.isHighlighted || state.isSelected {
            contentConfig.image = UIImage(systemName: "checkmark.circle.fill")
        }
        contentConfiguration = contentConfig
    }
}
```

Inside the ViewController class we can easily setup the newly created table view. Since we're using a storyboard file we can override the init(coder:) method this time, but if you are instantiating the controller programmatically then you could simply create your own init method.

By the way I also wrapped this view controller inside a navigation controller so I'm display a custom title using the large style by default and there are some missing code pieces that we have to write.

```swift
import UIKit

class ViewController: UIViewController {
    
    var tableView: TableView
    
    required init?(coder: NSCoder) {
        self.tableView = TableView(style: .insetGrouped)

        super.init(coder: coder)
    }
    
    override func loadView() {
        super.loadView()
        
        view.addSubview(tableView)

        NSLayoutConstraint.activate(tableView.layoutConstraints(in: view))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Table view"
        navigationController?.navigationBar.prefersLargeTitles = true

        tableView.register(CustomCell.self)
        tableView.delegate = self

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        reload()
    }
    
    func reload() {
        /// coming soon...
    }

}

extension ViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /// coming soon...
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        /// coming soon...
    }
}
```

We don't have to implement the table view data source methods, but we're going to use a diffable data source for that purpose, let me show you how it works.

## Diffable data source

I've already included one example containing a diffable data source, but that was a tutorial for [creating modern collection views](https://theswiftdev.com/how-to-create-reusable-views-for-modern-collection-views/). A diffable data source is literally a data source tied to a view, in our case the [UITableViewDiffableDataSource](https://developer.apple.com/documentation/uikit/uitableviewdiffabledatasource) generic class is going to act as a data source object four our table view. The good think about these data sources is that you can easily manipulate the sections and rows inside the table view without the need of working with index paths.

So the main idea here is that we'd like to display two sections, one with a single selection option for selecting a number, and the second option group is going to contain a multi-selection group with some letters from the alphabet. Here are the data models for the section items.

```swift
enum NumberOption: String, CaseIterable {
    case one
    case two
    case three
}

extension NumberOption: CustomCellModel {
 
    var text: String { rawValue }
}

enum LetterOption: String, CaseIterable {
    case a
    case b
    case c
    case d
}

extension LetterOption: CustomCellModel {
 
    var text: String { rawValue }
}
```

Now we should be able to display these items inside the table view, if we implement the regular data source methods, but since we're going to work with a diffable data source we need some additional models. To eliminate the need of index paths, we can use a Hashable enum to define our sections, we're going to have two sections, one for the numbers and another for the letters. We're going to wrap the corresponding type inside an enum with type-safe case values.

```swift
enum Section: Hashable {
    case numbers
    case letters
}

enum SectionItem: Hashable {
    case number(NumberOption)
    case letter(LetterOption)
}

struct SectionData {
    var key: Section
    var values: [SectionItem]
}
```

We're also going to introduce a SectionData helper, this way it's going to be more easy to insert the necessary sections and section items using the data source.

```swift
final class DataSource: UITableViewDiffableDataSource<Section, SectionItem> {
    
    init(_ tableView: UITableView) {
        super.init(tableView: tableView) { tableView, indexPath, itemIdentifier in
            let cell = tableView.reuse(CustomCell.self, indexPath)
            cell.selectionStyle = .none
            switch itemIdentifier {
            case .number(let model):
                cell.model = model
            case .letter(let model):
                cell.model = model
            }
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let id = sectionIdentifier(for: section)
        switch id {
        case .numbers:
            return "Pick a number"
        case .letters:
            return "Pick some letters"
        default:
            return nil
        }
    }

    func reload(_ data: [SectionData], animated: Bool = true) {
        var snapshot = snapshot()
        snapshot.deleteAllItems()
        for item in data {
            snapshot.appendSections([item.key])
            snapshot.appendItems(item.values, toSection: item.key)
        }
        apply(snapshot, animatingDifferences: animated)
    }
}
```

We can provide a custom init method for the data source, where we can use the cell provider block to configure our cells with the given item identifier. As you can see the item identifier is actually the SectionItem enum that we created a few minutes ago. We can use a switch to get back the underlying model, and since these models conform to the CustomCellModel protocol we can set the cell.model property. It is also possible to implement the regular titleForHeaderInSection method and we can switch the section id and return a proper label for each section.

The final method is a helper, I'm using it to reload the data source with the given section items.

```swift
import UIKit

class ViewController: UIViewController {
    
    var tableView: TableView
    var dataSource: DataSource
    
    required init?(coder: NSCoder) {
        self.tableView = TableView(style: .insetGrouped)
        self.dataSource = DataSource(tableView)

        super.init(coder: coder)
    }
    
    override func loadView() {
        super.loadView()
        
        view.addSubview(tableView)

        NSLayoutConstraint.activate(tableView.layoutConstraints(in: view))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Table view"
        navigationController?.navigationBar.prefersLargeTitles = true

        tableView.register(CustomCell.self)
        tableView.delegate = self

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        reload()
    }
    
    func reload() {
        dataSource.reload([
            .init(key: .numbers, values: NumberOption.allCases.map { .number($0) }),
            .init(key: .letters, values: LetterOption.allCases.map { .letter($0) }),
        ])
    }

}

extension ViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // coming soon...
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        // coming soon...
    }
}
```

So inside the view controller it is possible to render the table view and display both sections, even the cells are selectable by default, but I'd like to show you how to build a generic approach to store and return selected values, of course we could use the indexPathsForSelectedRows property, but I have a little helper tool which will allow single and multiple selection per section. 🤔

```swift
struct SelectionOptions<T: Hashable> {

    var values: [T]
    var selectedValues: [T]
    var multipleSelection: Bool

    init(_ values: [T], selected: [T] = [], multiple: Bool = false) {
        self.values = values
        self.selectedValues = selected
        self.multipleSelection = multiple
    }

    mutating func toggle(_ value: T) {
        guard multipleSelection else {
            selectedValues = [value]
            return
        }
        if selectedValues.contains(value) {
            selectedValues = selectedValues.filter { $0 != value }
        }
        else {
            selectedValues.append(value)
        }
    }
}
```

By using a generic extension on the UITableViewDiffableDataSource class we can turn the selected item values into index paths, this will help us to make the cells selected when the view loads.

```swift
import UIKit

extension UITableViewDiffableDataSource {

    func selectedIndexPaths<T: Hashable>(_ selection: SelectionOptions<T>,
                                         _ transform: (T) -> ItemIdentifierType) ->  [IndexPath] {
        selection.values
            .filter { selection.selectedValues.contains($0) }
            .map { transform($0) }
            .compactMap { indexPath(for: $0) }
    }
}
```

There is only one thing left to do, which is to handle the single and multiple selection using the didSelectRowAt and didDeselectRowAt delegate methods.

```swift
import UIKit

class ViewController: UIViewController {
    
    var tableView: TableView
    var dataSource: DataSource
    
    var singleOptions = SelectionOptions<NumberOption>(NumberOption.allCases, selected: [.two])
    var multipleOptions = SelectionOptions<LetterOption>(LetterOption.allCases, selected: [.a, .c], multiple: true)

    required init?(coder: NSCoder) {
        self.tableView = TableView(style: .insetGrouped)
        self.dataSource = DataSource(tableView)

        super.init(coder: coder)
    }
    
    override func loadView() {
        super.loadView()
        
        view.addSubview(tableView)

        NSLayoutConstraint.activate(tableView.layoutConstraints(in: view))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Table view"
        navigationController?.navigationBar.prefersLargeTitles = true

        tableView.register(CustomCell.self)
        tableView.delegate = self

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        reload()
    }
    
    func reload() {
        dataSource.reload([
            .init(key: .numbers, values: singleOptions.values.map { .number($0) }),
            .init(key: .letters, values: multipleOptions.values.map { .letter($0) }),
        ])

        tableView.select(dataSource.selectedIndexPaths(singleOptions) { .number($0) })
        tableView.select(dataSource.selectedIndexPaths(multipleOptions) { .letter($0) })
    }

}

extension ViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let sectionId = dataSource.sectionIdentifier(for: indexPath.section) else {
            return
        }

        switch sectionId {
        case .numbers:
            guard case let .number(model) = dataSource.itemIdentifier(for: indexPath) else {
                return
            }
            tableView.deselectAllInSection(except: indexPath)
            singleOptions.toggle(model)
            print(singleOptions.selectedValues)
            
        case .letters:
            guard case let .letter(model) = dataSource.itemIdentifier(for: indexPath) else {
                return
            }
            multipleOptions.toggle(model)
            print(multipleOptions.selectedValues)
        }
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let sectionId = dataSource.sectionIdentifier(for: indexPath.section) else {
            return
        }
        switch sectionId {
        case .numbers:
            tableView.select([indexPath])
        case .letters:
            guard case let .letter(model) = dataSource.itemIdentifier(for: indexPath) else {
                return
            }
            multipleOptions.toggle(model)
            print(multipleOptions.selectedValues)
        }
    }
}
```

This is why we've created the selection helper methods in the beginning of the article. It is relatively easy to implement a single and multi-selection section with this technique, but of course these things are even more simple if you can work with SwiftUI.

Anyway, I hope this tutorial helps for some of you, I still like UIKit a lot and I'm glad that Apple adds new features to it. Diffable data sources are excellent way of configuring table views and collection views, with these little helpers you can build your own settings or picker screens easily. 💪
