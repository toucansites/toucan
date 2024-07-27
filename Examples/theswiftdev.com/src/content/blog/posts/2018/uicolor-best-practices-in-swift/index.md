---
type: post
slug: uicolor-best-practices-in-swift
title: UIColor best practices in Swift
description: Learn what are color models, how to convert hex values to UIColor and back, generate random colors, where to find beautiful palettes.
publication: 2018-05-03 16:20:00
tags: UIKit, iOS, UIColor
authors:
  - tibor-bodecs
---

## What are color models and color spaces?

A [color model](http://www.wowarea.com/english/help/color.htm) is a method of describing a color.

- RGB - Red+Green+Blue
- HSB - Hue+Saturation+Brightness

There are several other color models, but if you are dealing with iOS colors you should be familiar with these two above. Usually you are going to work with the RGBA & HSBA color models which are basically the same as above extended with the alpha channel where the letter A stands for that. 😉

A [color space](https://photo.stackexchange.com/questions/48984/what-is-the-difference-or-relation-between-a-color-model-and-a-color-space) is the set of colors which can be displayed or reproduced in a medium (whether stored, printed or displayed). For example, sRGB is a particular set of intensities for red, green and blue and defines the colors that can be reproduced by mixing those ranges of red, green and blue.

Enough from the theory, let's do some color magic! 💫💫💫

## How to work with UIColor objects using RGBA and HSBA values in Swift?

Do you remember the old [Paint](http://tanner.xyz/) program from old-school Windows times?

I've used Microsoft Paint a lot, and I loved it. 😅

Back then without any CS knowledge I was always wondering about the numbers between 0 and 255 that I had to pick. If you are working with RGB colors you usually define your color the same way, except that in iOS the values are between 0 and 1, but that's just a different representation of the fraction of 255.

So you can make a color with RGB codes using the same logic.

```swift
UIColor(
    red: CGFloat(128)/CGFloat(255),
    green: CGFloat(128)/CGFloat(255),
    blue: CGFloat(128)/CGFloat(255),
    alpha: 1
)
// this is just about the same gray color but it's more readable
UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
```

See? Pretty easy, huh? 👍

Alternatively you can use HSB values, almost the same logic applies for those values, except that hue goes from 0 'til 360 (because of the actual color wheel), however saturation and brightness are measured in a "percent like" format 0-100, so you have to think about these numbers if you map them to floating point values.

```swift
UIColor(hue: CGFloat(120)/CGFloat(360), saturation: 0.5, brightness: 0.5, alpha: 1)
UIColor(hue: 0.3, saturation: 0.5, brightness: 0.5, alpha: 1)
```

Now let's reverse the situation and let me show you how to get back these components from an actual UIColor instance with the help of an extension.

```swift
public extension UIColor {
    public var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        return (r, g, b, a)
    }

    public var hsba: (hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        self.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return (h, s, b, a)
    }
}
```

So here it is how to read the red, green blue slash hue saturation brightness and alpha components from a UIColor. With this little neat extension you can simply get the component values and use them through their proper names.

```swift
UIColor.yellow.rgba.red
UIColor.yellow.hsba.hue
```

## How to convert HEX colors to RGB and vica versa for UIColor objects in Swift?

iOS developer 101 course, first questions:

- How the fuck can I create a UIColor from a hex string?
- How to convert a hex color to a UIColor?
- How to use a hext string to make a UIColor?

Ok, maybe these are not the first questions, but it's definitely inside common ones. The answer is pretty simple: through an extension. I have a really nice solution for your needs, which will handle most of the cases like using only 1, 2, 3 or 6 hex values.

```swift
public extension UIColor {

    public convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hex & 0xFF00) >> 8) / 255.0
        let blue = CGFloat((hex & 0xFF)) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }

    public convenience init(hex string: String, alpha: CGFloat = 1.0) {
        var hex = string.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if hex.hasPrefix("#") {
            let index = hex.index(hex.startIndex, offsetBy: 1)
            hex = String(hex[index...])
        }

        if hex.count < 3 {
            hex = "\(hex)\(hex)\(hex)"
        }

        if hex.range(of: "(^[0-9A-Fa-f]{6}$)|(^[0-9A-Fa-f]{3}$)", options: .regularExpression) != nil {
            if hex.count == 3 {

                let startIndex = hex.index(hex.startIndex, offsetBy: 1)
                let endIndex = hex.index(hex.startIndex, offsetBy: 2)

                let redHex = String(hex[..<startIndex])
                let greenHex = String(hex[startIndex..<endIndex])
                let blueHex = String(hex[endIndex...])

                hex = redHex + redHex + greenHex + greenHex + blueHex + blueHex
            }

            let startIndex = hex.index(hex.startIndex, offsetBy: 2)
            let endIndex = hex.index(hex.startIndex, offsetBy: 4)
            let redHex = String(hex[..<startIndex])
            let greenHex = String(hex[startIndex..<endIndex])
            let blueHex = String(hex[endIndex...])

            var redInt: CUnsignedInt = 0
            var greenInt: CUnsignedInt = 0
            var blueInt: CUnsignedInt = 0

            Scanner(string: redHex).scanHexInt32(&redInt)
            Scanner(string: greenHex).scanHexInt32(&greenInt)
            Scanner(string: blueHex).scanHexInt32(&blueInt)

            self.init(red: CGFloat(redInt) / 255.0,
                      green: CGFloat(greenInt) / 255.0,
                      blue: CGFloat(blueInt) / 255.0,
                      alpha: CGFloat(alpha))
        }
        else {
            self.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        }
    }

    var hexValue: String {
        var color = self

        if color.cgColor.numberOfComponents < 4 {
            let c = color.cgColor.components!
            color = UIColor(red: c[0], green: c[0], blue: c[0], alpha: c[1])
        }
        if color.cgColor.colorSpace!.model != .rgb {
            return "#FFFFFF"
        }
        let c = color.cgColor.components!
        return String(format: "#%02X%02X%02X", Int(c[0]*255.0), Int(c[1]*255.0), Int(c[2]*255.0))
    }
}
```
Here is how you can use it with multiple input variations:

```swift
let colors = [
    UIColor(hex: "#cafe00"),
    UIColor(hex: "cafe00"),
    UIColor(hex: "c"),
    UIColor(hex: "ca"),
    UIColor(hex: "caf"),
    UIColor(hex: 0xcafe00),
]
let values = colors.map { $0.hexValue }
print(values) //["#CAFE00", "#CAFE00", "#CCCCCC", "#CACACA", "#CCAAFF", "#CAFE00"]
```

As you can see I've tried to replicate the behavior of the CSS rules, so you will have the freedom of less characters if a hext string is like #ffffff (you can use just f, because # is optional). Also you can provide integers as well, that's just a simple "overloaded" convenience init method.

Also `.hexValue` will return the string representation of a UIColor instance. 👏👏👏

## How to generate a random UIColor in Swift?

This is also a very common question for beginners, I don't really want to waste the space here by deep explanation, arc4random() is just doing it's job and the output is a nice randomly generated color.

```swift
public extension UIColor {
    public static var random: UIColor {
        let max = CGFloat(UInt32.max)
        let red = CGFloat(arc4random()) / max
        let green = CGFloat(arc4random()) / max
        let blue = CGFloat(arc4random()) / max

        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
```

## How to create a 1x1 pixel big UIImage object with a single solid color in Swift?

I'm using this trick to set the background color of a UIButton object. The reason for this is state management. If you press the button the background image will be darker, so there will be a visual feedback for the user. However by setting the background color directly of a UIButton instance won't work like this, and the color won't change at all on the event. 👆

```swift
public extension UIColor {
    public var imageValue: UIImage {
        let rect = CGRect(origin: .zero, size: CGSize(width: 1, height: 1))
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(self.cgColor)
        context.fill(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}
```
The snippet above will produce a 1x1 pixel image object from the source color. You can use that anywere, but here is my example with a button background:

```swift
button.setBackgroundImage(UIColor.red.imageValue, for: .normal)
```

## Online color palettes

You can't find the right color? No problem, these links will help you to choose the proper one and to get some inspiration. Also if you are looking for flat UI colors or material design colors these are the right links where you should head first.

- [HTML Color Names](https://www.w3schools.com/colors/colors_names.asp)
- [Color Hunt](http://colorhunt.co/)
- [Flat UI Colors](https://flatuicolors.com/)
- [flatuicolorpicker](http://www.flatuicolorpicker.com/)
- [Material Design Colors](https://www.materialui.co/colors)

A personal thing of mine: dear designers, please never ever try to use material design principles for iOS apps. Thank you. [HIG](https://developer.apple.com/ios/human-interface-guidelines/overview/themes/)

## Convert colors online

Finally there are some great online color converter tools, if you are looking for a great one, you should try these first.

- [uicolor.xyz](http://uicolor.xyz/)
- [rgb.to](http://rgb.to/)
- [colorizer.org](http://www.colorizer.org/)

## Managing UIColors

If your app target is iOS 11+ you can use [asset catalogs](https://devblog.xero.com/managing-ui-colours-with-ios-11-asset-catalogs-16500ba48205) to organize your color palettes, but if you need to go below iOS 11, I'd suggest to use an enum or struct with static UIColor properties. Nowadays I'm usually doing something like this.

```swift
class App {
    struct Color {
        static var green: UIColor { return UIColor(hex: 0x4cd964) }
        static var yellow: UIColor { return UIColor(hex: 0xffcc00) }
        static var red: UIColor { return UIColor(hex: 0xff3b30) }
    }

    /* ... */
}

App.Color.yellow
```

Usually I'm grouping together fonts, colors etc inside structs, but this is just one way of doing things. You can also use something like [R.swift](https://github.com/mac-cain13/R.swift) or anything that you prefer.

That's it for now, I think I've covered most of the basic questions about UIColor.

Feel free to contact me if you have a topic or suggestion that you'd like to see covered here in the blog. I'm always open for new ideas. 😉
