//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2024. 10. 13..
//

import Foundation
import Logging
import ShellKit
import Markdown
import SwiftSoup

// TODO: better sort algorithm using data types
extension [PageBundle] {

    func sorted(
        key: String?,
        order: ContentType.Order?
    ) -> [PageBundle] {
        guard let key, let order else {
            return self
        }
        switch key {
        case "publication":
            return sorted { lhs, rhs in
                switch order {
                case .asc:
                    return lhs.publication < rhs.publication
                case .desc:
                    return lhs.publication > rhs.publication
                }
            }
        default:
            return sorted { lhs, rhs in
                guard
                    let l = lhs.frontMatter[key] as? String,
                    let r = rhs.frontMatter[key] as? String
                else {
                    guard
                        let l = lhs.frontMatter[key] as? Int,
                        let r = rhs.frontMatter[key] as? Int
                    else {
                        return false
                    }
                    switch order {
                    case .asc:
                        return l < r
                    case .desc:
                        return l > r
                    }
                }
                // TODO: proper case insensitive compare
                switch order {
                case .asc:
                    //                    switch l.caseInsensitiveCompare(r) {
                    //                    case .orderedAscending:
                    //                        return true
                    //                    case .orderedDescending:
                    //                        return false
                    //                    case .orderedSame:
                    //                        return false
                    //                    }
                    return l.lowercased() < r.lowercased()
                case .desc:
                    return l.lowercased() > r.lowercased()
                }
            }
        }
    }

    func limited(_ value: Int?) -> [PageBundle] {
        Array(prefix(value ?? Int.max))
    }

    func filtered(_ filter: ContentType.Filter?) -> [PageBundle] {
        guard let filter else {
            return self
        }
        return self.filter { pageBundle in
            guard let field = pageBundle.frontMatter[filter.field] else {
                return false
            }
            switch filter.method {
            case .equals:
                // this is horrible... 😱
                return String(describing: field) == filter.value
            }
        }
    }
}

struct PageBundleContext {
    let pageBundle: PageBundle
    let context: [String: Any]
}

struct ContextStore {

    let sourceConfig: SourceConfig
    let contentTypes: [ContentType]
    let pageBundles: [PageBundle]
    let logger: Logger
    
    let fileManager = FileManager.default
    let htmlToCParser: HTMLToCParser
    let markdownToCParser: MarkdownToCParser

    init(
        sourceConfig: SourceConfig,
        contentTypes: [ContentType],
        pageBundles: [PageBundle],
        logger: Logger
    ) {
        self.sourceConfig = sourceConfig
        self.contentTypes = contentTypes
        self.pageBundles = pageBundles
        self.logger = logger
        
        self.htmlToCParser = .init(logger: logger)
        self.markdownToCParser = .init()
    }

    func build() {
        for pageBundle in pageBundles {
            let ctx = standardContext(for: pageBundle)
            print("------------------------------------")
            print(pageBundle.slug)
            print(ctx.keys)
            if pageBundle.slug == "introducing-toucan-a-new-markdown-based-static-site-generator" {
                print(ctx["authors"])
            }
        }
    }
    
    private func readingTime(_ value: String) -> Int {
        max(value.split(separator: " ").count / 238, 1)
    }

    private func baseContext(
        for pageBundle: PageBundle
    ) -> [String: Any] {
        pageBundle.dict
    }

    private func properties(
        for pageBundle: PageBundle
    ) -> [String: Any] {
        var properties: [String: Any] = [:]
        for (key, _) in pageBundle.contentType.properties ?? [:] {
            let value = pageBundle.frontMatter[key]
            properties[key] = value
        }
        return properties
    }
    
    private func contentContext(
        for pageBundle: PageBundle
    ) -> [String: Any] {
        let renderer = MarkdownRenderer(
            delegate: HTMLRendererDelegate(
                config: sourceConfig.config,
                pageBundle: pageBundle
            )
        )

        // TODO: check if transformer exists
        let transformersUrl = sourceConfig.sourceUrl
            .appendingPathComponent("transformers")
        let availableTransformers =
            fileManager
            .listDirectory(at: transformersUrl)
            .filter { !$0.hasPrefix(".") }
            .sorted()

        let contentType = pageBundle.contentType

        // TODO: handle multiple pipeline for same content type
        let pipeline = sourceConfig.config.transformers.pipelines
            .filter { p in
                p.types.contains(contentType.id)
            }
            .first

        let run = pipeline?.run ?? []
        let renderFallback = pipeline?.render ?? true

        let markdown = pageBundle.markdown.dropFrontMatter()
        var toc: [ToCNode]? = nil
        var time: Int? = nil
        var contents = ""

        // TODO: better transformers settings merge with page bundle
        if !run.isEmpty {
            let shell = Shell(env: ProcessInfo.processInfo.environment)

            // Create a temporary directory URL
            let tempDirectoryURL = FileManager.default.temporaryDirectory
            let fileName = UUID().uuidString
            let fileURL = tempDirectoryURL.appendingPathComponent(fileName)
            try! markdown.write(to: fileURL, atomically: true, encoding: .utf8)

            for r in run {
                guard availableTransformers.contains(r) else {
                    continue
                }
                var rawOptions: [String: String] = [:]
                rawOptions["file"] = fileURL.path
                // TODO: this is not necessary the right way...
                rawOptions["id"] = pageBundle.contextAwareIdentifier
                rawOptions["slug"] = pageBundle.slug

                let bin = transformersUrl.appendingPathComponent(r).path
                let options =
                    rawOptions
                    .map { #"--\#($0) "\#($1)""# }
                    .joined(separator: " ")

                do {
                    let cmd = #"\#(bin) \#(options)"#
                    let log = try shell.run(cmd)
                    if !log.isEmpty {
                        logger.debug("\(log)")
                    }
                }
                catch {
                    logger.error("\(error.localizedDescription)")
                }
            }
            contents = try! String(contentsOf: fileURL, encoding: .utf8)
            try? fileManager.delete(at: fileURL)

            time = readingTime(contents)
            toc = htmlToCParser.parse(from: contents)?.buildToCTree()
        }

        if renderFallback {
            contents = renderer.renderHTML(markdown: markdown)
        }

        var context: [String: Any] = [:]
        context["readingTime"] = time ?? readingTime(markdown)
        context["toc"] = toc ?? markdownToCParser.parse(from: markdown)?.buildToCTree()
        context["contents"] = contents

        return context
    }

    private func relations(
        for pageBundle: PageBundle
    ) -> [String: [PageBundle]] {
        var result: [String: [PageBundle]] = [:]
        for (key, value) in pageBundle.contentType.relations ?? [:] {
            let refIds = pageBundle.referenceIdentifiers(
                for: key,
                join: value.join
            )

            let refs =
                pageBundles
                .filter { $0.contentType.id == value.references }
                .filter { item in
                    refIds.contains(item.contextAwareIdentifier)
                }
                .sorted(key: value.sort, order: value.order)
                .limited(value.limit)

            result[key] = refs
        }
        return result
    }
    
    // MARK: -
    
    /// can be resolved without joining any relations.
    private func standardContext(
        for pageBundle: PageBundle
    ) -> [String: Any] {
        let _baseContext = baseContext(for: pageBundle)
        let _contentContext = contentContext(for: pageBundle)
        let _properties = properties(for: pageBundle)
        let _relations = relations(for: pageBundle)
            .mapValues { $0.map { standardContext(for: $0) } }

        // TODO: check merge order
        let context =
            _baseContext
            .recursivelyMerged(with: _contentContext)
            .recursivelyMerged(with: _properties)
            .recursivelyMerged(with: _relations)
            .sanitized()

        return context
    }
    
    // MARK: -

    private func localContext(
        for pageBundle: PageBundle
    ) -> [String: [PageBundle]] {
        let id = pageBundle.contextAwareIdentifier
        var localContext: [String: [PageBundle]] = [:]
        let contentType = pageBundle.contentType

        for (key, value) in contentType.context?.local ?? [:] {
            if value.foreignKey.hasPrefix("$") {
                var command = String(value.foreignKey.dropFirst())
                var arguments: [String] = []
                if command.contains(".") {
                    let all = command.split(separator: ".")
                    command = String(all[0])
                    arguments = all.dropFirst().map(String.init)
                }

                let refs =
                    pageBundles
                    .filter { $0.contentType.id == value.references }
                    .sorted(key: value.sort, order: value.order)

                guard
                    let idx = refs.firstIndex(where: {
                        $0.slug == pageBundle.slug
                    })
                else {
                    continue
                }

                switch command {
                case "prev":
                    guard idx > 0 else {
                        continue
                    }
                    localContext[key] = [refs[idx - 1]]
                case "next":
                    guard idx < refs.count - 1 else {
                        continue
                    }
                    localContext[key] = [refs[idx + 1]]
                case "same":
                    guard let arg = arguments.first else {
                        continue
                    }
                    let ids = Set(pageBundle.referenceIdentifiers(for: arg))
                    localContext[key] =
                        refs.filter { pb in
                            if pb.slug == pageBundle.slug {
                                return false
                            }
                            let pbIds = Set(pb.referenceIdentifiers(for: arg))
                            return !ids.intersection(pbIds).isEmpty
                        }
                        .limited(value.limit)
                default:
                    continue
                }
            }
            else {
                localContext[key] =
                    pageBundles
                    .filter { $0.contentType.id == value.references }
                    .filter {
                        $0.referenceIdentifiers(
                            for: value.foreignKey
                        )
                        .contains(id)
                    }
                    .sorted(key: value.sort, order: value.order)
                    .limited(value.limit)
            }
        }
        return localContext
    }

    func fullContext(
        for pageBundle: PageBundle
    ) -> [String: Any] {

        let metadata: Logger.Metadata = [
            "type": "\(pageBundle.contentType.id)",
            "slug": "\(pageBundle.slug)",
        ]

        logger.trace("Generating context", metadata: metadata)

        let _standardContext = standardContext(for: pageBundle)
        let _localContext = localContext(for: pageBundle)
            .mapValues { $0.map { standardContext(for: $0) } } // TODO: 2nd iteration

        // TODO: check merge order
        let context =
            _standardContext
            .recursivelyMerged(with: _localContext)
            .sanitized()

        return context
    }
    
    // MARK: -

    func getPageBundlesForSiteContext() -> [String: [PageBundle]] {
        var result: [String: [PageBundle]] = [:]
        for contentType in contentTypes {
            for (key, value) in contentType.context?.site ?? [:] {
                result[key] =
                    pageBundles
                    .filter { $0.contentType.id == contentType.id }
                    .sorted(key: value.sort, order: value.order)
                    .filtered(value.filter)
                    // TODO: proper pagination
                    .limited(value.limit)
            }
        }
        return result
    }

}
