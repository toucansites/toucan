//
//  ContentResolver.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 21..
//

import Foundation
import Logging
import ToucanCore
import ToucanSerialization
import ToucanSource

private extension Path {

    func getTypeAwareIdentifier() -> String {
        let newRawPath =
            value
            .split(separator: "/")
            .last
            .map(String.init) ?? ""
        return Path(newRawPath).trimmingBracketsContent()
    }
}

enum ContentResolverError: ToucanError {
    case contentType(ContentTypeResolverError)
    case missingProperty(String, String)
    case missingRelation(String, String)
    case invalidProperty(String, String, String)
    case invalidSlug(String)
    case unknown(Error)

    var underlyingErrors: [any Error] {
        switch self {
        case let .contentType(error):
            [error]
        case .missingProperty:
            []
        case .missingRelation:
            []
        case .invalidProperty:
            []
        case .invalidSlug:
            []
        case let .unknown(error):
            [error]
        }
    }

    var logMessage: String {
        switch self {
        case .contentType(_):
            "Content type related error."
        case let .missingProperty(name, slug):
            "Missing property `\(name)` for content: \(slug)."
        case let .missingRelation(name, slug):
            "Missing property `\(name)` for content: \(slug)."
        case let .invalidProperty(name, value, slug):
            "Invalid property `\(name): \(value)` for content: \(slug)."
        case let .invalidSlug(slug):
            "Invalid slug for content: \(slug)."
        case let .unknown(error):
            error.localizedDescription
        }
    }

    var userFriendlyMessage: String {
        switch self {
        case .contentType(_):
            "Content type related error."
        case let .missingProperty(name, slug):
            "Missing property `\(name)` for content: `\(slug)`."
        case let .missingRelation(name, slug):
            "Missing property `\(name)` for content: `\(slug)`."
        case let .invalidProperty(name, value, slug):
            "Invalid property `\(name): \(value)` for content: \(slug)."
        case let .invalidSlug(slug):
            "Invalid slug for content: \(slug)."
        case .unknown:
            "Unknown content conversion error."
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

    private func rewrite(
        iteratorID: String,
        pageIndex: Int,
        _ value: inout String
    ) {
        value = value.replacingOccurrences([
            "{{\(iteratorID)}}": String(pageIndex)
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
    ) throws(ContentResolverError) -> ContentType {
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

    func convert(
        property: Property,
        rawValue: AnyCodable?,
        forKey key: String,
        slug: String
    ) throws(ContentResolverError) -> AnyCodable? {
        let value = rawValue ?? property.defaultValue

        switch property.type {
        case let .date(config):
            guard
                let rawDateValue = value?.value(as: String.self)
            else {
                throw .invalidProperty(
                    key,
                    value?.stringValue() ?? "nil",
                    slug
                )
            }
            guard
                let date = dateFormatter.date(
                    from: rawDateValue,
                    using: config
                )
            else {
                throw .invalidProperty(
                    key,
                    value?.stringValue() ?? "nil",
                    slug
                )
            }
            return .init(date.timeIntervalSince1970)
        default:
            return value
        }
    }

    func convert(
        rawContent: RawContent
    ) throws(ContentResolverError) -> Content {
        let typeID = rawContent.markdown.frontMatter.string(
            SystemPropertyKeys.type.rawValue
        )

        let contentType = try getContentType(
            for: rawContent.origin,
            using: typeID
        )

        var properties: [String: AnyCodable] = [:]

        // validate properties
        let frontMatter = rawContent.markdown.frontMatter
        let missingProperties = contentType.properties
            .filter { name, property in
                let isRequiredButMissing =
                    property.required && frontMatter[name] == nil
                let hasNoDefaultValue = property.defaultValue?.value == nil
                let isNotSystemProperty = !SystemPropertyKeys.allCases
                    .map { $0.rawValue }
                    .contains(name)

                return isRequiredButMissing && hasNoDefaultValue
                    && isNotSystemProperty
            }

        for name in missingProperties.keys {
            throw .missingProperty(name, rawContent.origin.slug)
        }

        /// validate relations
        let missingRelations = contentType.relations.keys.filter {
            frontMatter[$0] == nil
        }

        for name in missingRelations {
            throw .missingRelation(name, rawContent.origin.slug)
        }

        // Extrant `id` from front matter or path or fallback to origin path
        var typeAwareID = rawContent.origin.path.getTypeAwareIdentifier()

        if let id = rawContent.markdown.frontMatter.string(
            SystemPropertyKeys.id.rawValue
        ) {
            typeAwareID = id
        }

        // Extract `slug` from front matter or fallback to origin slug
        var slug: String = rawContent.origin.slug
        if let rawSlug = rawContent.markdown.frontMatter.string(
            SystemPropertyKeys.slug.rawValue,
            allowingEmptyValue: true
        ) {
            guard rawSlug.containsOnlyValidURLCharacters() else {
                throw .invalidSlug(rawSlug)
            }
            slug = rawSlug.slugify()
        }

        // Convert schema-defined properties
        for (key, property) in contentType.properties.sorted(by: {
            $0.key < $1.key
        }) {
            var rawValue: AnyCodable?

            switch key {
            case SystemPropertyKeys.id.rawValue:
                rawValue = .init(typeAwareID)
            case SystemPropertyKeys.lastUpdate.rawValue:
                rawValue = .init(rawContent.lastModificationDate)
            case SystemPropertyKeys.slug.rawValue:
                rawValue = .init(slug)
            case SystemPropertyKeys.type.rawValue:
                rawValue = .init(typeID)
            default:
                rawValue = rawContent.markdown.frontMatter[key]
            }

            properties[key] = try convert(
                property: property,
                rawValue: rawValue,
                forKey: key,
                slug: rawContent.origin.slug
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
            SystemPropertyKeys.allCases
            .map { $0.rawValue }
            + contentType.properties.keys
            + contentType.relations.keys

        var userDefined = rawContent.markdown.frontMatter
        for key in keysToRemove {
            userDefined.removeValue(forKey: key)
        }

        logger.trace(
            "Converting content",
            metadata: [
                "type": .string(contentType.id),
                "typeAwareID": .string(typeAwareID),
                "slug": .string(slug),
                "origin": .dictionary(
                    [
                        "path": .string(rawContent.origin.path.value),
                        "slug": .string(rawContent.origin.slug),
                    ]
                ),
            ]
        )

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
                    now: now,
                    logger: logger
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
            if let iteratorID = content.slug.extractIteratorID() {
                guard
                    let query = iterators[iteratorID]
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

                let total =
                    contents.run(query: countQuery, now: now, logger: logger)
                    .count
                let limit = max(1, query.limit ?? 10)
                let numberOfPages = (total + limit - 1) / limit

                for i in 0..<numberOfPages {
                    let offset = i * limit
                    let currentPageIndex = i + 1

                    var alteredContent = content
                    rewrite(
                        iteratorID: iteratorID,
                        pageIndex: currentPageIndex,
                        &alteredContent.typeAwareID
                    )
                    rewrite(
                        iteratorID: iteratorID,
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
                                baseURL: baseURL
                            )
                            return IteratorInfo.Link(
                                number: pageIndex,
                                permalink: permalink.replacingOccurrences(
                                    ["{{\(iteratorID)}}": String(pageIndex)]
                                ),
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
                        now: now,
                        logger: logger
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

    // MARK: - asset resolution

    func apply(
        assetProperties: [Pipeline.Assets.Property],
        to contents: [Content],
        contentsURL: URL,
        assetsPath: String,
        baseURL: String
    ) throws -> [Content] {
        var results: [Content] = []

        for content in contents {
            var item: Content = content

            for property in assetProperties {
                let path = item.rawValue.origin.path
                let url = contentsURL.appendingPathComponent(path.value)
                let assetsURL = url.appending(path: assetsPath)

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
                            baseURL: baseURL,
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
                    if filteredAssets.count == 1 {
                        let asset = filteredAssets[0]
                        let url = assetsURL.appending(path: asset)
                        let contents = try String(
                            contentsOf: url,
                            encoding: .utf8
                        )
                        item.properties[property.property] = .init(contents)
                    }
                    else {
                        var values: [String: AnyCodable] = [:]
                        for i in 0..<filteredAssets.count {
                            let asset = filteredAssets[i]
                            let url = assetsURL.appending(path: asset)
                            let contents = try String(
                                contentsOf: url,
                                encoding: .utf8
                            )
                            values[assetKeys[i]] = .init(contents)
                        }
                        item.properties[property.property] = .init(values)
                    }
                // TODO: check extension, add json support
                case .parse:
                    if filteredAssets.count == 1 {
                        let asset = filteredAssets[0]
                        let url = assetsURL.appending(path: asset)
                        let data = try Data(contentsOf: url)
                        let yaml = try ToucanYAMLDecoder()
                            .decode(AnyCodable.self, from: data)
                        item.properties[property.property] = yaml
                    }
                    else {
                        var values: [String: AnyCodable] = [:]
                        for i in 0..<filteredAssets.count {
                            let asset = filteredAssets[i]
                            let url = assetsURL.appending(path: asset)
                            let data = try Data(contentsOf: url)
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

    func applyBehaviors(
        pipeline: Pipeline,
        to contents: [Content],
        contentsURL: URL,
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

                    logger.trace(
                        "Resolving matching asset behavior.",
                        metadata: [
                            "behavior": .string(behavior.id),
                            "source": .string(sourcePath),
                            "destination": .string(destPath),
                        ]
                    )

                    let fileURL = contentsURL.appending(path: sourcePath)

                    switch behavior.id {
                    case CompileSASSBehavior.id:
                        let script = try CompileSASSBehavior()
                        let css = try script.run(fileURL: fileURL)

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

                    case MinifyCSSBehavior.id:
                        let script = MinifyCSSBehavior()
                        let css = try script.run(fileURL: fileURL)

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
