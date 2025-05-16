//
//  ContextBundleToJSONRenderer.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 05. 13..
//

import ToucanModels
import Foundation
import Logging

struct ContextBundleToJSONRenderer {

    let pipeline: Pipeline
    let encoder: JSONEncoder

    let logger: Logger

    let keyPath: String?
    let keyPaths: [String: AnyCodable]?

    init(
        pipeline: Pipeline,
        logger: Logger
    ) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [
            .prettyPrinted,
            .withoutEscapingSlashes,
            .sortedKeys,
        ]

        self.pipeline = pipeline
        self.encoder = encoder
        self.logger = logger

        self.keyPath = pipeline.engine.options.string("keyPath")
        self.keyPaths = pipeline.engine.options.value(
            "keyPaths",
            as: [String: AnyCodable].self
        )
    }

    func render(_ contextBundles: [ContextBundle]) -> [PipelineResult] {
        contextBundles.compactMap {
            render($0)
        }
    }

    func render(_ contextBundle: ContextBundle) -> PipelineResult? {
        let metadata: Logger.Metadata = [
            "slug": "\(contextBundle.content.slug.value)"
        ]

        let context = contextBundle.context
        let unboxedContext = context.unboxed(encoder)

        let encodedData = firstSucceeding([
            {
                try data(
                    from: unboxedContext,
                    keyPaths: keyPaths,
                    using: encoder
                )
            },
            { try data(from: unboxedContext, at: keyPath, using: encoder) },
            { try encoder.encode(context) },
        ])

        guard let encodedData else {
            logger.warning(
                "Could not encode context data as JSON object.",
                metadata: metadata
            )
            return nil
        }

        let json = String(data: encodedData, encoding: .utf8)

        guard let json else {
            logger.warning(
                "Could not encode context data as JSON output.",
                metadata: metadata
            )
            return nil
        }
        return .init(
            source: .content(json),
            destination: contextBundle.destination
        )
    }

    private func data(
        from context: [String: Any],
        at keyPath: String?,
        using encoder: JSONEncoder
    ) throws -> Data? {
        guard let keyPath else {
            return nil
        }

        if let value = context.value(forKeyPath: keyPath) {
            return try encoder.encode(AnyCodable(value))
        }

        return nil
    }

    private func data(
        from context: [String: Any],
        keyPaths: [String: AnyCodable]?,
        using encoder: JSONEncoder
    ) throws -> Data? {
        var result: [String: AnyCodable] = [:]

        guard let keyPaths else {
            return nil
        }

        for (keyPath, value) in keyPaths {
            guard let newKeyPath = value.value(as: String.self) else {
                continue
            }

            if let value = context.value(forKeyPath: keyPath) {
                result[newKeyPath] = .init(value)
            }
        }

        return try encoder.encode(result)
    }
}
