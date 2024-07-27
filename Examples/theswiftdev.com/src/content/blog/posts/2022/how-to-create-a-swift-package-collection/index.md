---
type: post
slug: how-to-create-a-swift-package-collection
title: How to create a Swift package collection?
description: In this tutorial I'm going to show you how to create your own package collection from your favorite Swift libraries.
publication: 2022-01-20 16:20:00
tags: Swift, SPM
authors:
  - tibor-bodecs
---

## What is a Swift package collection?

A [Swift package collection](https://github.com/apple/swift-evolution/blob/main/proposals/0291-package-collections.md) is a curated list of packages. Swift Package Manager users can subscribe to these collections, this way they are going to be able to search libraries and discover new ones. A collection is not equal with a package index or registry service, but usually means a smaller (somehow related) group of Swift packages.

For example if you take a look at the [Swift Package Index](https://swiftpackageindex.com/) website, it's all about discovering new Swift packages, but each author can have its own collection, so if we go to the [Vapor](https://swiftpackageindex.com/vapor) page, there you can see the URL of the Swift package collection link. This collection only contains those packages that are authored by Vapor. It's just a small, curated subset of the entire content of the Swift Package Index website.

So we can say that a package registry service is focused on hosting and serving package sources, a package index service is all about discovering and searching packages and a package collection is usually a smaller curated list that can be easily shared with others. It can be a list of your preferred Swift dependencies that your company uses for building new projects. 💡

## Preparing the environment

In order to create a package collection, you'll have to install a tool called [Swift package collection generator](https://github.com/apple/swift-package-collection-generator). It was created by Apple and it was introduced in this [WWDC session](https://developer.apple.com/videos/play/wwdc2021/10197/) in 2021.

You can install the package collection generator by running these commands:

```sh
git clone https://github.com/apple/swift-package-collection-generator
cd swift-package-collection-generator 
swift build --configuration release

sudo install .build/release/package-collection-generate /usr/local/bin/package-collection-generate
sudo install .build/release/package-collection-diff /usr/local/bin/package-collection-diff
sudo install .build/release/package-collection-sign /usr/local/bin/package-collection-sign
sudo install .build/release/package-collection-validate /usr/local/bin/package-collection-validate
```

You'll also need a certificate and a key in order to sign a package collection. Signing packages are not required, but it is recommended. The signature can be added with the package-collection-sign command, but first of all you'll need a developer certificate from the [Apple developer portal](https://developer.apple.com/account/resources/certificates/list). 🔨

Before you go to the dev portal, simply launch the Keychain Access app and use the Keychain Access > Certificate Assitant > Request a Certificate from a Certificate Authority menu item to generate a new CertificateSigningRequest.certSigningRequest file. Double check your email address and select the Saved to disk option and press the Continue button to generate the file.

Now you can use the CSR file to generate a new certificate using the Apple dev portal. Press the plus icon next to the Certificates text and scroll down to the Services section, there you should see a Swift Package Collection Certificate option, select that one and press the Continue button. Upload your CSR file and press Continue again, now you should be able to download the certificate that can be used to properly sign your Swift package collections. 🖊

We still have to export the private key that's behind the certificate and we also have to convert it to the right format before we can start dealing with the contents of the package collection itself. Double click the downloaded certificate file, this will add it to your keychain. Find the certificate (click My Certificates on the top), right click on it and choose the Export menu item, save the Certificates.p12 file somewhere on your disk. Don't forget to add password protection to the exported file, otherwise the key extraction won't work.

Now we should use the openssl to extract the private key from the p12 file using an RSA format.

```sh
openssl pkcs12 -nocerts -in Certificates.p12 -out key.pem && openssl rsa -in key.pem -out rsa_key.pem
```

Run the command and enter the password that you've used to export the p12 file. This command should extract the required key using the proper format for the package collection sign command. You'll need both the downloaded certificate and the RSA key file during the package creation. 📦

## Building a Swift package collection

It is time to create a brand new Swift package collection. I'm going to build one for my Swift repositories located under the [Binary Birds](https://github.com/binarybirds/) organization. Everything starts with a JSON file.

```json
{
    "name": "Binary Birds packages",
    "overview": "This collection contains the our favorite Swift packages.",
    "author": {
        "name": "Tibor Bödecs"
    },
    "keywords": [
        "favorite"
    ],
    "packages": [
        {
            "url": "https://github.com/binarybirds/swift-html"
        },
        {
            "url": "https://github.com/BinaryBirds/liquid"
        },
        {
            "url": "https://github.com/BinaryBirds/liquid-kit"
        },
        {
            "url": "https://github.com/BinaryBirds/liquid-local-driver"
        },
        {
            "url": "https://github.com/BinaryBirds/liquid-aws-s3-driver"
        },
        {
            "url": "https://github.com/BinaryBirds/spec"
        }
    ]
}
```

You can read more about the [Package Collection format file on GitHub](https://github.com/apple/swift-package-manager/blob/main/Sources/PackageCollectionsModel/Formats/v1.md), but if you want to stick with the basics, it is pretty much self-explanatory. You can give a name and a short overview description to your collection, set the author, add some related keywords to improve the search experience and finally define the included packages via URLs.

Save this file using the input.json name. If you run the generate command with this input file it'll try to fetch the repositories listed inside the JSON file. In order to get more metadata information about the GitHub repositories you can also provide an -auth-token parameter with your personal access token, you can read more about the available options by running the command with the -h or --help flag (package-collection-generate -h).

```sh
package-collection-generate input.json ./output.json
```

The generated output file will contain the required package collection metadata, but we still have to sign the output file if we want to properly use it as a collection file. Of course the sign step is optional, but it is recommend to work with signed collections. 😇

```sh
package-collection-sign output.json collection.json rsa_key.pem swift_package.cer
```

Finally you should upload your collection.json file to a public hosting service. For example I've created a simple [SPM](https://github.com/binarybirds/spm/) repository under my organization and I can use the [raw file URL](https://raw.githubusercontent.com/BinaryBirds/SPM/main/collection.json) of the collection JSON file to use it with SPM or Xcode.

If you prefer the command line you have several options to manipulate Swift Package Collections. For more info you can read the related [Swift Package Manager](https://github.com/apple/swift-package-manager/blob/main/Documentation/PackageCollections.md#remove-subcommand) documentation, but here are some example commands that you can use to add, list, refresh search or remove a collection:

```sh
swift package-collection list
swift package-collection add https://raw.githubusercontent.com/BinaryBirds/SPM/main/collection.json
swift package-collection refresh
swift package-collection search --keywords html

swift package-collection remove https://raw.githubusercontent.com/BinaryBirds/SPM/main/collection.json
```

If you are developing apps using Xcode, you can use the Package Dependencies menu under your project settings to manage your package dependencies and use package collections.

Swift Package Collections are great if you want to organize your Swift libraries and you want to share them with others. If you are a heavy Xcode user you'll enjoy using collections for sure. ☺️
