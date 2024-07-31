---
type: post
slug: picking-images-with-uiimagepickercontroller-in-swift-5
title: Picking images with UIImagePickerController in Swift 5
description: Learn how to get an image from the photo library or directly from the camera by using the UIImagePickerController class in Swift 5.
publication: 2019-01-30 16:20:00
tags: UIKit, iOS
authors:
  - tibor-bodecs
---

> Are you looking for a video picker as well? 🍿 Check out my another post about [picking & playing video files in iOS](https://theswiftdev.com/2019/08/28/picking-and-playing-videos-in-swift/).

## A reusable image picker class for iOS

So in this [tutorial](http://blogs.innovationm.com/image-picker-controller-tutorial-ios/) we're going to create a reusable class built on top of UIKit in order to make image selection more pleasant for your apps, everything written in Swift 5.

> This article was inspired by my previous attempt to solve the image picking issue in a [protocol oriented way](https://medium.com/@ilkerbltc/protocol-oriented-approach-to-get-image-or-video-via-uiimagepickercontroller-on-ios-e3909090815d), but that article is nowadays a little bit obsolated, plus I wouldn't use that technique anymore.

People always learn from the past, so instead of using a protocol oriented approach, this time I'll simply go with an ImagePicker class. No singletons, no extra library, just a small helper class that can be instantiated in the appropriate place, to do it's job. 🌄

> NOTE: I'm only going to focus on picking edited images, if you'd like to use live photos or movies, you can always customize the ImagePicker class, or create an abstract one and implement subclasses for each media type. I'd do so too. 😅

So let's dive in, here is my basic implementation, but you can download a complete example project with video picking as well from The.Swift.Dev. tutorials repository on [GitHub](https://github.com/theswiftdev/tutorials).

## Privacy first!

Nowadays privacy matters a lot, so you have to add two important keys to your applications `Info.plist` file, otherwise you'll end up with a horrible crash! ⚠️


Since you'd like to get some private data, you have to provide an explanation message for the user (and for Apple) why the app is requesting camera & photo library access. The `NSCameraUsageDescription` is for camera and `NSPhotoLibraryUsageDescription` key is for photo library access. Both values should be a straightforward string that'll explain the user why you need his/her nude pictures. Privacy is important! 🔒

```plist
<key>NSCameraUsageDescription</key>
<string>This app wants to take pictures.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app wants to use your photos.</string>
```

Obviously if you'd like to use photos directly taken from the camera, but you don't want to access the photo library, you just have to add the proper key. That's it now we're ready to do some actual coding. ⌨️

## The anatomy of UIImagePickerController

The anatomy of a UIPickerController is quite simple. Basically it's a regular view controller, you just have to set a few extra properties to make it work.

```swift
let pickerController = UIImagePickerController()
pickerController.delegate = self
pickerController.allowsEditing = true
pickerController.mediaTypes = ["public.image", "public.movie"]
pickerController.sourceType = .camera
```

Allows editing is a flag that indicates if the resizing & cropping interface should be presented after selecting & taking a picture, if true you should use the .editedImage instead of the .originalImage key - inside the picker delegate - to get the proper image from the image info dictionary.

There are basically two kinds of media types available: images and movies. You can get the available media type strings for each source type by calling a class method on the picker: 

```swift
UIImagePickerController.availableMediaTypes(
    for: .camera
)
```

There are 3 available source types: .camera, which is the camera, and there are two other options to get pictures from the photo library. The `.photoLibrary` enum case will give you full access, but you can limit the selection scope only for the camera roll if you choose .savedPhotosAlbum.

The delegate should implement both the `UIImagePickerControllerDelegate` and the `UINavigationControllerDelegate` protocols, however usually my navigation controller delegate is just an empty implementation. If you need extra navigation related logic, you might need to create a few methods there as well.

Awww, let's just put everything together...

```swift
import UIKit

public protocol ImagePickerDelegate: class {
    func didSelect(image: UIImage?)
}

open class ImagePicker: NSObject {

    private let pickerController: UIImagePickerController
    private weak var presentationController: UIViewController?
    private weak var delegate: ImagePickerDelegate?

    public init(presentationController: UIViewController, delegate: ImagePickerDelegate) {
        self.pickerController = UIImagePickerController()

        super.init()

        self.presentationController = presentationController
        self.delegate = delegate

        self.pickerController.delegate = self
        self.pickerController.allowsEditing = true
        self.pickerController.mediaTypes = ["public.image"]
    }

    private func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
        guard UIImagePickerController.isSourceTypeAvailable(type) else {
            return nil
        }

        return UIAlertAction(title: title, style: .default) { [unowned self] _ in
            self.pickerController.sourceType = type
            self.presentationController?.present(self.pickerController, animated: true)
        }
    }

    public func present(from sourceView: UIView) {

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        if let action = self.action(for: .camera, title: "Take photo") {
            alertController.addAction(action)
        }
        if let action = self.action(for: .savedPhotosAlbum, title: "Camera roll") {
            alertController.addAction(action)
        }
        if let action = self.action(for: .photoLibrary, title: "Photo library") {
            alertController.addAction(action)
        }

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        if UIDevice.current.userInterfaceIdiom == .pad {
            alertController.popoverPresentationController?.sourceView = sourceView
            alertController.popoverPresentationController?.sourceRect = sourceView.bounds
            alertController.popoverPresentationController?.permittedArrowDirections = [.down, .up]
        }

        self.presentationController?.present(alertController, animated: true)
    }

    private func pickerController(_ controller: UIImagePickerController, didSelect image: UIImage?) {
        controller.dismiss(animated: true, completion: nil)

        self.delegate?.didSelect(image: image)
    }
}

extension ImagePicker: UIImagePickerControllerDelegate {

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.pickerController(picker, didSelect: nil)
    }

    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.editedImage] as? UIImage else {
            return self.pickerController(picker, didSelect: nil)
        }
        self.pickerController(picker, didSelect: image)
    }
}

extension ImagePicker: UINavigationControllerDelegate {

}
```

If you don't need to select from a source type, things are pretty straightforward, you can simply present your picker view controller, handle everything in the delegate and you are done. However, if you need to choose from an input source, that involves a little bit more logic, especially on iPads. 📱

I'm using a `UIAlertController` in order to compose a source type selection dialog. I'm trying to add 3 actions (based on the picking source type), but only if the source type is available on that given device (e.g. `.camera` is not available in the simulator). You can check availability through: UIImagePickerController.isSourceTypeAvailable(type).

> NOTE: Alert controllers needs a few extra things on iPads, that's why I'm setting up the `popoverPresentationController` properties in the present method. It's usually enough to set the sourceView and the sourceRect properties, but you can also customize arrow directions. ⬅️➡️⬆️⬇️

It's always your task to check if the device is an iPad & set the proper source view & rect if it's needed, otherwise your app will crash on iPads. Another thing is that you have to dismiss the UIPickerViewController after the picker did it's job! ⚠️

## Time to say cheese! 🧀

> How to use the image picker class?

Well, now you are ready to take some pictures. I've made a simple view controller to show you a real quick example. You only need a `UIImageView` and a `UIButton`.

Now this is the code for the sample view controller. Nothing magical, I just pass the controller as a presentationController for the `ImagePicker` so it'll be able to present the `UIImagePickerController` on top of that. I separated the delegate from the presentation controller, because sometimes it comes handy. 🤷‍♂️

```swift
class ViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!

    var imagePicker: ImagePicker!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
    }

    @IBAction func showImagePicker(_ sender: UIButton) {
        self.imagePicker.present(from: sender)
    }
}

extension ViewController: ImagePickerDelegate {

    func didSelect(image: UIImage?) {
        self.imageView.image = image
    }
}
```

The `ImagePickerDelegate` delegate in this case is the most simple one I can imagine. It just gives the picked image so you're ready to use it. However in [some cases](https://stackoverflow.com/questions/44465904/photopicker-discovery-error-error-domain-pluginkit-code-13) you might need a few additional info from the image picker.

If you want to take this approach one step further, you can create an abstract class or a protocol that defines the basic functionality and based on that you can implement various media picker controllers to fit your needs.

