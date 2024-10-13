//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2024. 10. 13..
//

import Foundation
import Logging

actor ContextStore {

    let sourceConfig: SourceConfig
    let contentTypes: [ContentType]
    let pageBundles: [PageBundle]
    let logger: Logger

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
    }

    func build() {
        for pageBundle in pageBundles {
            _ = fullContext(pageBundle: pageBundle)
        }
    }

    private func baseContext(
        for pageBundle: PageBundle
    ) -> [String: Any] {
        pageBundle.dict
    }

    func properties(
        for pageBundle: PageBundle
    ) -> [String: Any] {
        var properties: [String: Any] = [:]
        for (key, _) in pageBundle.contentType.properties ?? [:] {
            let value = pageBundle.frontMatter[key]
            properties[key] = value
        }
        return properties
    }

    /// can be resolved without joining any relations.
    func standardContext(
        for pageBundle: PageBundle
    ) -> [String: Any] {
        let _baseContext = baseContext(for: pageBundle)
        let _properties = properties(for: pageBundle)
        return _baseContext.recursivelyMerged(with: _properties)
    }

    func relations(
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

    func localContext(
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
        pageBundle: PageBundle
    ) -> [String: Any] {

        let metadata: Logger.Metadata = [
            "type": "\(pageBundle.contentType.id)",
            "slug": "\(pageBundle.slug)",
        ]

        logger.trace("Generating context", metadata: metadata)

        let _baseContext = baseContext(for: pageBundle)
        let _properties = properties(for: pageBundle)
        let _relations = relations(for: pageBundle)
            .mapValues { $0.map { standardContext(for: $0) } }
        let _localContext = localContext(for: pageBundle)
            .mapValues { $0.map { standardContext(for: $0) } }

        // TODO: check merge order
        let context =
            _baseContext
            .recursivelyMerged(with: _properties)
            .recursivelyMerged(with: _relations)
            .recursivelyMerged(with: _localContext)
            .sanitized()
        print(pageBundle.slug, context.keys.sorted())
        print(context["posts"] ?? "n/a")
        return context
    }

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
