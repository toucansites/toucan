////
////  File.swift
////  toucan
////
////  Created by Tibor Bodecs on 2024. 10. 11..
////
//
//import Foundation
//import FileManagerKit
//
//struct PageBundleLocation {
//    /// The original path of the page bundle directory, also serves as the page bundle identifier.
//    let path: String
//    /// The slug, derermined by the path and noindex files.
//    let slug: String
//}
//
//struct PageBundleLocator {
//
//    let fileManager: FileManagerKit
//    let contentsUrl: URL
//
//    init(
//        fileManager: FileManagerKit,
//        contentsUrl: URL
//    ) {
//        self.fileManager = fileManager
//        self.contentsUrl = contentsUrl
//    }
//
//    private let indexName = "index"
//    private let noindexName = "noindex"
//    private let mdExtensions = ["md", "markdown"]
//    private let yamlExtensions = ["yaml", "yml"]
//
//    private var extensions: [String] {
//        mdExtensions + yamlExtensions
//    }
//
//    func locate() throws -> [PageBundleLocation] {
//        try loadBundleLocations()
//            .sorted { $0.path < $1.path }
//    }
//
//    private func containsIndexFile(
//        name: String,
//        at url: URL
//    ) -> Bool {
//        for ext in extensions {
//            let fileUrl = url.appendingPathComponent("\(name).\(ext)")
//            if fileManager.fileExists(at: fileUrl) {
//                return true
//            }
//        }
//        return false
//    }
//
//    private func loadBundleLocations(
//        slug: [String] = [],
//        path: [String] = []
//    ) throws -> [PageBundleLocation] {
//        var result: [PageBundleLocation] = []
//
//        let p = path.joined(separator: "/")
//        let url = contentsUrl.appendingPathComponent(p)
//
//        if containsIndexFile(name: indexName, at: url) {
//            result.append(
//                .init(
//                    path: p,
//                    slug: slug.joined(separator: "/")
//                )
//            )
//        }
//
//        let list = fileManager.listDirectory(at: url)
//        for item in list {
//            var newSlug = slug
//            let childUrl = url.appendingPathComponent(item)
//            if !containsIndexFile(name: noindexName, at: childUrl) {
//                newSlug += [item]
//            }
//            let newPath = path + [item]
//            result += try loadBundleLocations(slug: newSlug, path: newPath)
//        }
//
//        // filter out site bundle
//        return result.filter { !$0.slug.isEmpty }
//    }
//}
