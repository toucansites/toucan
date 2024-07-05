---
slug: uicollectionview-data-source-and-delegates-programmatically
title: UICollectionView data source and delegates programmatically
description: In this quick UIKit tutorial I'll show you how to create a simple UICollectionView without Interface Builder, but only using Swift.
publication: 2018-06-26 16:20:00
tags: UIKit, iOS, UICollectionView
---


## UICollectionViewCell programmatically

If you'd like to add views to your cell, you should use the `init(frame:)` method, and set up your view hierarchy there. Instead of awakeFromNib you should style your views in the `init` method as well. You can reset everything inside the usual `prepareForReuse` method. As you can see by [using anchors](https://theswiftdev.com/2018/06/14/mastering-ios-auto-layout-anchors-programmatically-from-swift/) sometimes it's worth to ditch IB entirely. 🎉

```swift
class Cell: UICollectionViewCell {

    static var identifier: String = "Cell"

    weak var textLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)

        let textLabel = UILabel(frame: .zero)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textLabel)
        NSLayoutConstraint.activate([
            contentView.centerXAnchor.constraint(equalTo: textLabel.centerXAnchor),
            contentView.centerYAnchor.constraint(equalTo: textLabel.centerYAnchor),
        ])
        self.textLabel = textLabel
        reset()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        reset()
    }

    func reset() {
        textLabel.textAlignment = .center
    }
}
```

## UICollectionView programmatically

Creating [collection view controllers using only Swift](https://theswiftdev.com/2018/04/17/ultimate-uicollectionview-guide-with-ios-examples-written-in-swift/) code requires only a few additional lines. You can implement `loadView` and create your `UICollectionView` object there. Store a `weak` reference of it inside the controller, and the rest is the same.

```swift
class ViewController: UIViewController {

    weak var collectionView: UICollectionView!

    var data: [Int] = Array(0..<10)

    override func loadView() {
        super.loadView()

        let collectionView = UICollectionView(
            frame: .zero, 
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: collectionView.topAnchor),
            view.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor),
        ])
        collectionView = collectionView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(Cell.self, forCellWithReuseIdentifier: Cell.identifier)
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .white
    }
}

extension ViewController: UICollectionViewDataSource {

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        data.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: Cell.identifier, 
            for: indexPath
        ) as! Cell

        let data = data[indexPath.item]
        cell.textLabel.text = String(data)
        return cell
    }
}

extension ViewController: UICollectionViewDelegate {

    func collectionView(
        _ collectionView: UICollectionView, 
        didSelectItemAt indexPath: IndexPath
    ) {

    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        .init(width: collectionView.bounds.width, height: 44)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        .init(top: 0, left: 0, bottom: 0, right: 0) //.zero
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        0
    }
}
```

That was easy. Anchors are really powerful, Interface Builder is extremely helpful, but sometimes it's just faster to create your views from code. The choice is yours, but please don't be afraid of coding user interfaces! 😅
