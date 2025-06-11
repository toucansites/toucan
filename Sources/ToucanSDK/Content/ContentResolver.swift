//
//  ContentResolver.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 21..
//

import Foundation
import ToucanCore
import ToucanSource
import ToucanSerialization
import Logging

fileprivate extension Path {

    func getTypeLocalIdentifier() -> String {
        let newRawPath =
            self.value
            .split(separator: "/")
            .last
            .map(String.init) ?? ""
        return Path(newRawPath).trimmingBracketsContent()
    }
}

enum ContentResolverError: ToucanError {

    case contentType(ContentTypeResolverError)
    case unknown(Error)

    var underlyingErrors: [any Error] {
        switch self {
        case .contentType(let error):
            return [error]
        case .unknown(let error):
            return [error]
        }
    }

    var logMessage: String {
        switch self {
        case .contentType(let error):
            return "Content type related error: \(error.logMessage)"
        case .unknown(let error):
            return error.localizedDescription
        }
    }

    var userFriendlyMessage: String {
        switch self {
        case .contentType(let error):
            return "Content type related error: \(error.userFriendlyMessage)"
        case .unknown:
            return "Unknown content conversion error."
        }
    }
}

struct ContentResolver {

    var contentTypeResolver: ContentTypeResolver
    var encoder: ToucanEncoder
    var decoder: ToucanDecoder
    var dateFormatter: ToucanInputDateFormatter
    var logger: Logger

    init(
        contentTypeResolver: ContentTypeResolver,
        encoder: ToucanEncoder,
        decoder: ToucanDecoder,
        dateFormatter: ToucanInputDateFormatter,
        logger: Logger = .subsystem("content-resolver")
    ) {
        self.contentTypeResolver = contentTypeResolver
        self.encoder = encoder
        self.decoder = decoder
        self.dateFormatter = dateFormatter
        self.logger = logger
    }

    // MARK: - conversion

    func convert(
        rawContents: [RawContent]
    ) throws(ContentResolverError) -> [Content] {
        do {
            return try rawContents.map {
                try convert(rawContent: $0)
            }
        }
        catch let error as ContentResolverError {
            throw error
        }
        catch {
            throw .unknown(error)
        }
    }

    // MARK: - error helper

    func getContentType(
        for origin: Origin,
        using id: String?
    ) throws(ContentResolverError) -> ContentDefinition {
        do {
            return try contentTypeResolver.getContentType(
                for: origin,
                using: id
            )
        }
        catch {
            throw .contentType(error)
        }
    }

    // MARK: - conversion helpers

    // TODO: throw instead of warning...
    func convert(
        property: Property,
        rawValue: AnyCodable?,
        forKey key: String
    ) -> AnyCodable? {
        let value = rawValue ?? property.default

        switch property.type {
        case .date(let config):
            guard
                let rawDateValue = value?.value(as: String.self)
            else {
                logger.warning(
                    "Date property is not a string (\(key): \(value?.value ?? "nil"))."
                )
                return nil
            }
            guard
                let date = dateFormatter.date(
                    from: rawDateValue,
                    using: config
                )
            else {
                logger.warning(
                    "Date property is not valid (\(key): \(rawDateValue))."
                )
                return nil
            }
            return .init(date.timeIntervalSince1970)
        default:
            return value
        }
    }

    func convert(
        rawContent: RawContent
    ) throws(ContentResolverError) -> Content {

        //        logger.debug("Converting raw content")

        let typeId = rawContent.markdown.frontMatter.string("type")

        let contentType = try getContentType(
            for: rawContent.origin,
            using: typeId
        )

        var properties: [String: AnyCodable] = [:]

        // Convert schema-defined properties
        for (key, property) in contentType.properties.sorted(by: {
            $0.key < $1.key
        }) {

            let rawValue = rawContent.markdown.frontMatter[key]

            //            logger.debug("Converting property")
            properties[key] = convert(
                property: property,
                rawValue: rawValue,
                forKey: key
            )
        }

        // Convert schema-defined relations
        var relations: [String: RelationValue] = [:]
        for (key, relation) in contentType.relations.sorted(by: {
            $0.key < $1.key
        }) {
            let rawValue = rawContent.markdown.frontMatter[key]
            var identifiers: [String] = []

            switch relation.type {
            case .one:
                if let id = rawValue?.value as? String {
                    identifiers.append(id)
                }
            case .many:
                if let ids = rawValue?.value as? [String] {
                    identifiers.append(contentsOf: ids)
                }
            }

            relations[key] = .init(
                contentType: relation.references,
                type: relation.type,
                identifiers: identifiers
            )
        }

        // Filter out reserved keys and schema-mapped fields to extract user-defined fields
        let keysToRemove =
            ["id", "type", "slug"]
            + contentType.properties.keys
            + contentType.relations.keys

        var userDefined = rawContent.markdown.frontMatter
        for key in keysToRemove {
            userDefined.removeValue(forKey: key)
        }

        var typeAwareID = rawContent.origin.path.getTypeLocalIdentifier()
        if let id = rawContent.markdown.frontMatter.string("id") {
            typeAwareID = id
        }

        // Extract `slug` from front matter or fallback to origin slug
        var slug: String = rawContent.origin.slug
        if let rawSlug = rawContent.markdown.frontMatter.string(
            "slug",
            allowingEmptyValue: true
        ) {
            slug = rawSlug
        }

        //                print("------------------------")
        //                print(contentType.id)
        //                print(typeAwareID)
        //                print(".")
        //                print(rawContent.origin.path.value)
        //                print(rawContent.origin.slug)
        //                print(slug)
        //                print("------------------------")

        // Final assembled content object
        return .init(
            type: contentType,
            typeAwareID: typeAwareID,
            slug: .init(slug),
            rawValue: rawContent,
            properties: properties,
            relations: relations,
            userDefined: userDefined,
            iteratorInfo: nil
        )
    }

    // MARK: - filter

    /// Applies the filtering rules to the provided content items.
    ///
    /// - Parameters:
    ///   - filterRules: A dictionary mapping content type identifiers to filtering conditions.
    ///   - contents: The list of `Content` items to filter.
    ///   - now: The current timestamp used for time-based filtering.
    /// - Returns: A new list containing only the filtered content items.
    func apply(
        filterRules: [String: Condition],
        to contents: [Content],
        now: TimeInterval
    ) -> [Content] {
        let groups = Dictionary(grouping: contents, by: { $0.type.id })

        var result: [Content] = []
        for (id, contents) in groups {
            if let condition = filterRules[id] ?? filterRules["*"] {
                let items = contents.run(
                    query: .init(
                        contentType: id,
                        filter: condition
                    ),
                    now: now
                )
                result.append(contentsOf: items)
            }
            else {
                result.append(contentsOf: contents)
            }
        }
        return result
    }

    // MARK: - iterators

    func apply(
        iterators: [String: Query],
        to contents: [Content],
        baseURL: String,
        now: TimeInterval
    ) -> [Content] {
        var finalContents: [Content] = []

        for content in contents {
            if let iteratorId = content.slug.extractIteratorId() {
                guard
                    let query = iterators[iteratorId]
                else {
                    continue
                }

                let countQuery = Query(
                    contentType: query.contentType,
                    scope: query.scope,
                    limit: nil,
                    offset: nil,
                    filter: query.filter,
                    orderBy: query.orderBy
                )

                let total = contents.run(query: countQuery, now: now).count
                let limit = max(1, query.limit ?? 10)
                let numberOfPages = (total + limit - 1) / limit

                for i in 0..<numberOfPages {
                    let offset = i * limit
                    let currentPageIndex = i + 1

                    var alteredContent = content
                    rewrite(
                        iteratorId: iteratorId,
                        pageIndex: currentPageIndex,
                        &alteredContent.typeAwareID
                    )
                    rewrite(
                        iteratorId: iteratorId,
                        pageIndex: currentPageIndex,
                        &alteredContent.slug.value
                    )
                    rewrite(
                        number: currentPageIndex,
                        total: numberOfPages,
                        &alteredContent.properties
                    )
                    rewrite(
                        number: currentPageIndex,
                        total: numberOfPages,
                        &alteredContent.userDefined
                    )

                    if !alteredContent.rawValue.markdown.contents.isEmpty {
                        alteredContent.rawValue.markdown.contents = replace(
                            in: alteredContent.rawValue.markdown.contents,
                            number: currentPageIndex,
                            total: numberOfPages
                        )
                    }

                    let links = (0..<numberOfPages)
                        .map { i in
                            let pageIndex = i + 1
                            let permalink = content.slug.permalink(
                                baseUrl: baseURL,
                            )
                            return IteratorInfo.Link(
                                number: pageIndex,
                                permalink: permalink.replacingOccurrences(
                                    ["{{\(iteratorId)}}": String(pageIndex)]),
                                isCurrent: pageIndex == currentPageIndex
                            )
                        }

                    let items = contents.run(
                        query: .init(
                            contentType: query.contentType,
                            limit: limit,
                            offset: offset,
                            filter: query.filter,
                            orderBy: query.orderBy
                        ),
                        now: now
                    )

                    alteredContent.iteratorInfo = .init(
                        current: currentPageIndex,
                        total: numberOfPages,
                        limit: limit,
                        items: items,
                        links: links,
                        scope: query.scope
                    )

                    finalContents.append(alteredContent)
                }

            }
            else {
                finalContents.append(content)
            }
        }
        return finalContents
    }

    private func rewrite(
        iteratorId: String,
        pageIndex: Int,
        _ value: inout String
    ) {
        value = value.replacingOccurrences([
            "{{\(iteratorId)}}": String(pageIndex)
        ])
    }

    private func rewrite(
        number: Int,
        total: Int,
        _ array: inout [String: AnyCodable]
    ) {
        for (key, _) in array {
            if let stringValue = array[key]?.stringValue() {
                array[key] = .init(
                    replace(
                        in: stringValue,
                        number: number,
                        total: total
                    )
                )
            }
        }
    }

    private func replace(
        in value: String,
        number: Int,
        total: Int
    ) -> String {
        value.replacingOccurrences([
            "{{number}}": String(number),
            "{{total}}": String(total),
        ])
    }

    // MARK: - asset resolution

    func apply(
        assetProperties: [Pipeline.Assets.Property],
        to contents: [Content],
        contentsUrl: URL,
        assetsPath: String,
        baseUrl: String,
    ) throws -> [Content] {
        var results: [Content] = []

        for content in contents {
            var item: Content = content

            for property in assetProperties {
                let path = item.rawValue.origin.path
                let url = contentsUrl.appendingPathComponent(path.value)
                let assetsUrl = url.deletingLastPathComponent()
                    .appending(path: assetsPath)

                let filteredAssets = filterFilePaths(
                    from: content.rawValue.assets,
                    input: property.input
                )

                guard !filteredAssets.isEmpty else {
                    continue
                }

                let assetKeys =
                    filteredAssets.compactMap {
                        $0.split(separator: ".").first
                    }
                    .map(String.init)

                let resolvedAssets = filteredAssets.map {
                    "./\(assetsPath)/\($0)"
                        .resolveAsset(
                            baseUrl: baseUrl,
                            assetsPath: assetsPath,
                            slug: content.slug.value
                        )
                }

                let frontMatter = item.rawValue.markdown.frontMatter

                let finalAssets =
                    property.resolvePath ? resolvedAssets : filteredAssets

                switch property.action {
                case .add:
                    if let originalItems = frontMatter[property.property]?
                        .arrayValue(as: String.self)
                    {
                        item.properties[property.property] = .init(
                            originalItems + finalAssets
                        )
                    }
                    else {
                        item.properties[property.property] = .init(finalAssets)
                    }
                case .set:
                    if finalAssets.count == 1 {
                        let asset = finalAssets[0]
                        item.properties[property.property] = .init(asset)
                    }
                    else {
                        item.properties[property.property] = .init(
                            createDictionaryValues(
                                assetKeys: assetKeys,
                                array: finalAssets
                            )
                        )
                    }
                case .load:
                    if finalAssets.count == 1 {
                        let asset = finalAssets[0]
                        let contents = try String(
                            contentsOf: assetsUrl.appending(path: asset)
                        )
                        item.properties[property.property] = .init(contents)
                    }
                    else {
                        var values: [String: AnyCodable] = [:]
                        for i in 0..<finalAssets.count {
                            let contents = try String(
                                contentsOf: assetsUrl.appending(
                                    path: finalAssets[i]
                                )
                            )
                            values[assetKeys[i]] = .init(contents)
                        }
                        item.properties[property.property] = .init(values)
                    }
                // TODO: check extension, add json support
                case .parse:
                    if finalAssets.count == 1 {
                        let data = try Data(
                            contentsOf: assetsUrl.appending(
                                path: finalAssets[0]
                            )
                        )
                        let yaml = try ToucanYAMLDecoder()
                            .decode(AnyCodable.self, from: data)
                        item.properties[property.property] = yaml
                    }
                    else {
                        var values: [String: AnyCodable] = [:]
                        for i in 0..<finalAssets.count {
                            let data = try Data(
                                contentsOf: assetsUrl.appending(
                                    path: finalAssets[i]
                                )
                            )
                            let yaml = try ToucanYAMLDecoder()
                                .decode(AnyCodable.self, from: data)

                            values[assetKeys[i]] = yaml
                        }
                        item.properties[property.property] = .init(values)
                    }
                }
            }
            results.append(item)
        }
        return results
    }

    private func createDictionaryValues(
        assetKeys: [String],
        array: [String]
    ) -> [String: AnyCodable] {
        var values: [String: AnyCodable] = [:]
        for i in 0..<array.count {
            values[assetKeys[i]] = .init(array[i])
        }
        return values
    }

    private func filterFilePaths(
        from paths: [String],
        input: Pipeline.Assets.Location
    ) -> [String] {
        paths.filter { filePath in
            guard let url = URL(string: filePath) else {
                return false
            }

            let path = url.deletingLastPathComponent().path
            let name = url.deletingPathExtension().lastPathComponent
            let ext = url.pathExtension

            let inputPath = input.path ?? ""
            let pathMatches =
                inputPath == "*" || inputPath.isEmpty || path == inputPath
            let nameMatches =
                input.name == "*" || input.name.isEmpty || name == input.name
            let extMatches =
                input.ext == "*" || input.ext.isEmpty || ext == input.ext
            return pathMatches && nameMatches && extMatches
        }
    }

    // MARK: - asset behaviors

    private func getNameAndExtension(
        from path: String
    ) -> (name: String, ext: String) {

        let safePath = path.split(separator: "/").last.map(String.init) ?? ""

        let parts = safePath.split(
            separator: ".",
            omittingEmptySubsequences: false
        )
        guard parts.count >= 2 else {
            return (String(safePath), "")  // No extension
        }

        let ext = String(parts.last!)
        let filename = parts.dropLast().joined(separator: ".")

        return (filename, ext)
    }

    // TODO: Behavior protocol?

    func applyBehaviors(
        pipeline: Pipeline,
        to contents: [Content],
        contentsUrl: URL,
        assetsPath: String
    ) throws -> [PipelineResult] {
        var results: [PipelineResult] = []

        for content in contents {
            var assetsReady: Set<String> = .init()

            for behavior in pipeline.assets.behaviors {
                let isAllowed = pipeline.contentTypes.isAllowed(
                    contentType: content.type.id
                )
                guard isAllowed else {
                    continue
                }
                let remainingAssets = Set(content.rawValue.assets)
                    .subtracting(assetsReady)

                let matchingRemainingAssets = filterFilePaths(
                    from: Array(remainingAssets),
                    input: behavior.input
                )

                guard !matchingRemainingAssets.isEmpty else {
                    continue
                }

                for inputAsset in matchingRemainingAssets {
                    let basePath = content.rawValue.origin.path

                    let sourcePath = [
                        basePath.value,
                        assetsPath,
                        inputAsset,
                    ]
                    .joined(separator: "/")

                    // TODO: log trace

                    let file = getNameAndExtension(from: inputAsset)

                    let destPath = [
                        assetsPath,
                        content.slug.value,
                        inputAsset,
                    ]
                    .filter { !$0.isEmpty }
                    .joined(separator: "/")
                    .split(separator: "/")
                    .dropLast()
                    .joined(separator: "/")

                    switch behavior.id {
                    case "compile-sass":
                        let fileUrl =
                            contentsUrl
                            .appending(
                                path: sourcePath
                            )

                        let script = try CompileSASSBehavior()
                        let css = try script.compile(fileUrl: fileUrl)

                        // TODO: proper output management later on
                        results.append(
                            .init(
                                source: .asset(css),
                                destination: .init(
                                    path: destPath,
                                    file: behavior.output.name,
                                    ext: behavior.output.ext
                                )
                            )
                        )

                    case "minify-css":
                        let fileUrl =
                            contentsUrl
                            .appending(
                                path: sourcePath
                            )

                        let script = MinifyCSSBehavior()
                        let css = try script.minify(fileUrl: fileUrl)

                        results.append(
                            .init(
                                source: .asset(css),
                                destination: .init(
                                    path: destPath,
                                    file: behavior.output.name,
                                    ext: behavior.output.ext
                                )
                            )
                        )

                    default:  // copy
                        results.append(
                            .init(
                                source: .assetFile(sourcePath),
                                destination: .init(
                                    path: destPath,
                                    file: file.name,
                                    ext: file.ext
                                )
                            )
                        )
                    }

                    assetsReady.insert(inputAsset)
                }
            }
        }

        return results
    }
}
