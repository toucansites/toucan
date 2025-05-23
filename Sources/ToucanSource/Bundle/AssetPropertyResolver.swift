//
//  AssetPropertyResolver.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 04. 19..
//

import Foundation
import ToucanModels
import ToucanSerialization

struct AssetPropertyResolver {

    var contentsUrl: URL
    var assetsPath: String
    var baseUrl: String
    var config: Pipeline.Assets

    func resolve(
        _ contents: [Content]
    ) throws -> [Content] {
        var results: [Content] = []

        for content in contents {
            var item: Content = content

            for property in config.properties {
                let path = item.rawValue.origin.path
                let url = contentsUrl.appendingPathComponent(path)
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
                            slug: content.slug
                        )
                }

                let finalAssets =
                    property.resolvePath ? resolvedAssets : filteredAssets

                switch property.action {
                case .add:
                    if let originalItems = item.properties[property.property]?
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

}
