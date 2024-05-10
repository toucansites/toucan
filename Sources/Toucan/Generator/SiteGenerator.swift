//
//  File.swift
//
//
//  Created by Tibor Bodecs on 07/05/2024.
//

import Foundation
import Algorithms

struct SiteGenerator {

    let site: Site
    let path: String

    func generate() throws {
        let fileManager = FileManager.default
        let output = URL(fileURLWithPath: path)

        if fileManager.exists(at: output) {
            try fileManager.removeItem(at: output)
        }
        try fileManager.createDirectory(at: output)

        let postPages = site.posts
            .sorted(by: { $0.publication > $1.publication })
            .chunks(ofCount: 2)

        let htmlRenderer = HTMLRenderer()

        let postsDirUrl = output.appendingPathComponent("posts")
        try fileManager.createDirectory(at: postsDirUrl)

        for (index, posts) in postPages.enumerated() {
            let postPageDirUrl =
                postsDirUrl
                .appendingPathComponent("\(index+1)")

            try fileManager.createDirectory(at: postPageDirUrl)

            let postPageUrl =
                postPageDirUrl
                .appendingPathComponent("index.html")

            try "\(index+1)"
                .write(
                    to: postPageUrl,
                    atomically: true,
                    encoding: .utf8
                )

            for item in posts {

                let postDirUrl = output.appendingPathComponent(item.slug)
                try fileManager.createDirectory(at: postDirUrl)

                let postUrl = postDirUrl.appendingPathComponent("index.html")

                // TODO: use proper rendering...
                let html = htmlRenderer.render(markdown: item.markdown)

                try html.write(
                    to: postUrl,
                    atomically: true,
                    encoding: .utf8
                )
            }
        }

    }
}

//func processContentAssets(
//        at url: URL,
//        slug: String,
//        assetsUrl: URL,
//        fileManager: FileManager,
//        needToCopy: Bool
//    ) throws -> [String] {
//        var assets: [String] = []
//        // create assets dir
//        let assetsDir = assetsUrl.appendingPathComponent(slug)
//        if needToCopy {
//            try fileManager.createDirectory(at: assetsDir)
//        }
//
//        // check for image assets
//        let imagesUrl = url.appendingPathComponent("images")
//        var imageList: [String] = []
//        if fileManager.directoryExists(at: imagesUrl) {
//            imageList = fileManager.listDirectory(at: imagesUrl)
//        }
//
//        // copy image assets
//        if !imageList.isEmpty {
//            let assetImagesDir = assetsDir.appendingPathComponent("images")
//            if needToCopy {
//                try fileManager.createDirectory(at: assetImagesDir)
//            }
//            for image in imageList {
//                let sourceUrl = imagesUrl.appendingPathComponent(image)
//                let assetPath = assetImagesDir.appendingPathComponent(image)
//                if needToCopy {
//                    try fileManager.copy(from: sourceUrl, to: assetPath)
//                }
//                assets.append(image)
//            }
//        }
//
//        // copy cover + dark version
//        let coverUrl = url.appendingPathComponent("cover.jpg")
//        let coverAssetUrl = assetsDir.appendingPathComponent("cover.jpg")
//        if fileManager.fileExists(at: coverUrl) {
//            if needToCopy {
//                try fileManager.copy(from: coverUrl, to: coverAssetUrl)
//            }
//            assets.append("cover.jpg")
//        }
//        else {
//            print("[WARNING] Cover image issues in `\(slug)`.")
//        }
//
//        // copy dark cover image if exists
//        let darkCoverUrl = url.appendingPathComponent("cover~dark.jpg")
//        let darkCoverAssetUrl = assetsDir.appendingPathComponent(
//            "cover~dark.jpg"
//        )
//        if fileManager.fileExists(at: darkCoverUrl) {
//            if needToCopy {
//                try fileManager.copy(from: darkCoverUrl, to: darkCoverAssetUrl)
//            }
//            assets.append("cover~dark.jpg")
//        }
//        return assets
//    }
//
//}
