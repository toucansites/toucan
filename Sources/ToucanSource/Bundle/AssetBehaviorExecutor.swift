//
//  AssetBehaviorExecutor.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 12..
//

import Foundation
import ToucanModels

struct AssetBehaviorExecutor {

    var sourceBundle: SourceBundle

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
                inputPath == "*" || inputPath.isEmpty
                || path == inputPath
            let nameMatches =
                input.name == "*" || input.name.isEmpty
                || name == input.name
            let extMatches =
                input.ext == "*" || input.ext.isEmpty
                || ext == input.ext
            return pathMatches && nameMatches && extMatches
        }
    }

    func execute(
        pipeline: Pipeline,
        contents: [Content]
    ) throws -> [PipelineResult] {
        var results: [PipelineResult] = []

        let assetsPath = sourceBundle.config.contents.assets.path

        for content in contents {
            var assetsReady: Set<String> = .init()

            for behavior in pipeline.assets.behaviors {
                let isAllowed = pipeline.contentTypes.isAllowed(
                    contentType: content.definition.id
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
                        .split(separator: "/")
                        .dropLast()
                        .joined(separator: "/")

                    let sourcePath = [
                        basePath,
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

                    switch behavior.id {
                    case "compile-sass":
                        let fileUrl = sourceBundle.sourceConfig.contentsUrl
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
                        let fileUrl = sourceBundle.sourceConfig.contentsUrl
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
