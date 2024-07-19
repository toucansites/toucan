//
//  File.swift
//
//
//  Created by Tibor Bodecs on 13/06/2024.
//

import Foundation

struct Source {
    
    let url: URL
    let config: Config
    let contentTypes: [ContentType]
    let pageBundles: [PageBundle]


//    func all() -> [SourceMaterial] {
//        var result: [SourceMaterial?] = []
//
//        result += [pages.main.home]
//        result += [pages.main.notFound]
//        result += [pages.blog.home]
//        result += [pages.blog.authors]
//        result += [pages.blog.tags]
//        result += [pages.blog.posts]
//        result += [pages.docs.home]
//        result += [pages.docs.categories]
//        result += [pages.docs.guides]
//        result += [pages.custom.home]
//        result += pages.custom.pages
//        result += blog.authors
//        result += blog.tags
//        result += blog.posts
//        result += docs.categories
//        result += docs.guides
//
//        return result.compactMap { $0 }
//    }
//
//    func validateSlugs() throws {
//        let slugs = all().map(\.slug)
//        let uniqueSlugs = Set(slugs)
//        guard slugs.count == uniqueSlugs.count else {
//            var seenSlugs = Set<String>()
//            var duplicateSlugs = Set<String>()
//
//            for element in slugs {
//                if seenSlugs.contains(element) {
//                    duplicateSlugs.insert(element)
//                }
//                else {
//                    seenSlugs.insert(element)
//                }
//            }
//
//            for element in duplicateSlugs {
//                fatalError("Duplicate slug: \(element)")
//            }
//            fatalError("Invalid slugs")
//        }
//    }

    
    func bundleContext() -> [String: [PageBundle]] {

        var result: [String: [PageBundle]] = [:]
        for contentType in contentTypes {
            guard let key = contentType.context?.list?.name else {
                continue
            }
            result[key] = pageBundlesBy(type: contentType.id)
        }
        return result
    }
    
//    func bundleTypes() -> Set<String> {
//        var types: Set<String> = .init()
//        for bundle in pageBundles {
//            types.insert(bundle.type)
//        }
//        return types
//    }

    func pageBundlesBy(type: String) -> [PageBundle] {
        pageBundles.filter { $0.type == type }
    }
    
    
}

