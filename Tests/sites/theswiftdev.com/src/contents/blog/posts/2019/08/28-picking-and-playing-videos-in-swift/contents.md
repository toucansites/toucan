---
slug: picking-and-playing-videos-in-swift
title: Picking and playing videos in Swift
description: Learn how to record or select a video file using a video picker controller and the AVPlayer class, written entirely in Swift 5.
publication: 2019-08-28 16:20:00
tags: UIKit, iOS
---

## Let's pick some videos!

If you remember my previous [tutorial about image picking in iOS](https://theswiftdev.com/2019/01/30/picking-images-with-uiimagepickercontroller-in-swift-5/), then you know that I already made quite a reusable picker class built on top of UIKit. If you don't know how the `UIImagePickerController` class works, please read that tutorial first because it gives you a great overview about the basics.

First of all you'll need to add some keys into your `Info.plist` file, because you'd like to access some personal data. You know: privacy is very important. 🤫

```plist
<key>NSCameraUsageDescription</key>
<string>This app wants to take pictures & videos.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app wants to use your picture & video library.</string>
<key>NSMicrophoneUsageDescription</key>
<string>This app wants to record sound.</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>This app wants to save pictures & videos to your library.</string>
```

Since we're not going to capture silent videos we also have to add the Privacy - Microphone Usage Description field. Ready, set, action! 🎬

I'm not going to lie to you, but I was a little bit lazy this time, so our `VideoPicker` class will be 90% the same as our `ImagePicker` class was. You can make an abstract class, whatever, I'll show you the final code, then we can talk about the differences. 😅

```swift
import UIKit

public protocol VideoPickerDelegate: class {
    func didSelect(url: URL?)
}

open class VideoPicker: NSObject {

    private let pickerController: UIImagePickerController
    private weak var presentationController: UIViewController?
    private weak var delegate: VideoPickerDelegate?

    public init(presentationController: UIViewController, delegate: VideoPickerDelegate) {
        self.pickerController = UIImagePickerController()

        super.init()

        self.presentationController = presentationController
        self.delegate = delegate

        self.pickerController.delegate = self
        self.pickerController.allowsEditing = true
        self.pickerController.mediaTypes = ["public.movie"]
        self.pickerController.videoQuality = .typeHigh
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

        if let action = self.action(for: .camera, title: "Take video") {
            alertController.addAction(action)
        }
        if let action = self.action(for: .savedPhotosAlbum, title: "Camera roll") {
            alertController.addAction(action)
        }
        if let action = self.action(for: .photoLibrary, title: "Video library") {
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

    private func pickerController(_ controller: UIImagePickerController, didSelect url: URL?) {
        controller.dismiss(animated: true, completion: nil)

        self.delegate?.didSelect(url: url)
    }
}

extension VideoPicker: UIImagePickerControllerDelegate {

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.pickerController(picker, didSelect: nil)
    }

    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

        guard let url = info[.mediaURL] as? URL else {
            return self.pickerController(picker, didSelect: nil)
        }

//        //uncomment this if you want to save the video file to the media library
//        if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(url.path) {
//            UISaveVideoAtPathToSavedPhotosAlbum(url.path, self, nil, nil)
//        }
        self.pickerController(picker, didSelect: url)
    }
}

extension VideoPicker: UINavigationControllerDelegate {

}
```

There are just a few small that changes. The first one is the mediaTypes property, you can use the "public.movie" value this time. Also you should set the videoQuality property on the pickerController, because 4k is always better than 320. 🤪

The delegate is the last thing that changed a little bit. After the picker finish the job you can get the `.mediaURL` property, which is a URL to get your media file (a.k.a. the captured / selected video file). If a new file was recorded you can also save it to the media library, that's just two lines of extra code.

Congrats, [play-back](https://github.com/awojnowski/SwiftVideoPlayer) time! 📹

## Playing video files using AVPlayer & UIView

Isn't it great when a webpage has some nicely themed video in the background of the header? Well, you can have the exact same thing in iOS by using AVFoundation, UIKit and some low-level layer magic. Don't worry it's not that difficult. 😬

You can use a regular `UIView` subclass, then replace its default layer with an `AVPlayerLayer`. This will allow you to play videos directly in the view. Also an `AVPlayer` is just a simple controller object that can manage the playback and timing of a media file.

The hardest part was checking the status changes of the media file. For example when I first tried to record a new video the payback of the player view constantly [stopped](https://stackoverflow.com/questions/19291636/avplayer-stops-playing-and-doesnt-resume-again) after a second. I had to [search for answers](https://stackoverflow.com/questions/40781738/how-to-detect-avplayer-actually-started-to-play-in-swift), because I'm not an [AVFoundation](https://developer.apple.com/av-foundation/) expert at all, but it turned out that you should watch for the rate property, because the system is trying to buffer the video and that can cause some problems.

Anyway I was able to put together a fairly nice `VideoView` with some nice additional features like constantly looping the video or choosing between the fill / fit aspect content modes. I'm not telling you that this is a 100% bulletproof solution, but it's a good starting point, plus it's more than enough in some cases. 👻

```swift
import UIKit
import AVFoundation

open class VideoView: UIView {

    public enum Repeat {
        case once
        case loop
    }

    override open class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }

    private var playerLayer: AVPlayerLayer {
        return self.layer as! AVPlayerLayer
    }

    public var player: AVPlayer? {
        get {
            self.playerLayer.player
        }
        set {
            self.playerLayer.player = newValue
        }
    }


    open override var contentMode: UIView.ContentMode {
        didSet {
            switch self.contentMode {
            case .scaleAspectFit:
                self.playerLayer.videoGravity = .resizeAspect
            case .scaleAspectFill:
                self.playerLayer.videoGravity = .resizeAspectFill
            default:
                self.playerLayer.videoGravity = .resize
            }
        }
    }

    public var `repeat`: Repeat = .once

    public var url: URL? {
        didSet {
            guard let url = self.url else {
                self.teardown()
                return
            }
            self.setup(url: url)
        }
    }

    @available(*, unavailable)
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.initialize()
    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.initialize()
    }

    public init() {
        super.init(frame: .zero)

        self.translatesAutoresizingMaskIntoConstraints = false

        self.initialize()
    }

    open func initialize() {

    }

    deinit {
        self.teardown()
    }


    private func setup(url: URL) {

        self.player = AVPlayer(playerItem: AVPlayerItem(url: url))

        self.player?.currentItem?.addObserver(self,
                                              forKeyPath: "status",
                                              options: [.old, .new],
                                              context: nil)

        self.player?.addObserver(self, forKeyPath: "rate", options: [.old, .new], context: nil)


        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.itemDidPlayToEndTime(_:)),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: self.player?.currentItem)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.itemFailedToPlayToEndTime(_:)),
                                               name: .AVPlayerItemFailedToPlayToEndTime,
                                               object: self.player?.currentItem)
    }

    private func teardown() {
        self.player?.pause()

        self.player?.currentItem?.removeObserver(self, forKeyPath: "status")

        self.player?.removeObserver(self, forKeyPath: "rate")

        NotificationCenter.default.removeObserver(self,
                                                  name: .AVPlayerItemDidPlayToEndTime,
                                                  object: self.player?.currentItem)

        NotificationCenter.default.removeObserver(self,
                                                  name: .AVPlayerItemFailedToPlayToEndTime,
                                                  object: self.player?.currentItem)

        self.player = nil
    }



    @objc func itemDidPlayToEndTime(_ notification: NSNotification) {
        guard self.repeat == .loop else {
            return
        }
        self.player?.seek(to: .zero)
        self.player?.play()
    }

    @objc func itemFailedToPlayToEndTime(_ notification: NSNotification) {
        self.teardown()
    }


    open override func observeValue(forKeyPath keyPath: String?,
                                          of object: Any?,
                                          change: [NSKeyValueChangeKey : Any]?,
                                          context: UnsafeMutableRawPointer?) {
        if keyPath == "status", let status = self.player?.currentItem?.status, status == .failed {
            self.teardown()
        }

        if
            keyPath == "rate",
            let player = self.player,
            player.rate == 0,
            let item = player.currentItem,
            !item.isPlaybackBufferEmpty,
            CMTimeGetSeconds(item.duration) != CMTimeGetSeconds(player.currentTime())
        {
            self.player?.play()
        }
    }
}
```

I made a sample project for you and honestly my view controller is simple as f.ck. It demonstrates both the image picking and the video capturing capabilities. Feel free to download it from The.Swift.Dev tutorials repository, it's called [Pickers](https://github.com/theswiftdev/tutorials).
