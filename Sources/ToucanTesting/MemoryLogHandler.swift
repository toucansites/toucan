//
//  MemoryLogHandler.swift
//  toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 04. 09..
//

import Logging
import Foundation

extension Logger {

    public static func inMemory(
        label: String,
        logLevel: Logger.Level = .trace
    ) -> (logger: Logger, handler: MemoryLogHandler) {
        let handler = MemoryLogHandler(label: label)
        var logger = Logger(label: label + label) { _ in
            handler
        }
        logger.logLevel = logLevel
        return (logger: logger, handler: handler)
    }
}

public struct MemoryLogHandler: LogHandler {
    
    public var logLevel: Logger.Level = .info
    public var metadata: Logger.Metadata = [:]

    public var messages: [Logger.Message] {
        storage.messages
    }

    private let label: String
    private let storage = Storage()

    public init(label: String) {
        self.label = label
    }

    public func log(
        level: Logger.Level,
        message: Logger.Message,
        metadata: Logger.Metadata?,
        source: String,
        file: String,
        function: String,
        line: UInt
    ) {
        let isoFormatter = ISO8601DateFormatter()
        let timestamp = isoFormatter.string(from: Date())
        let mergedMetadata = self.metadata.merging(metadata ?? [:]) { _, new in new }
        let metadataText = formattedMetadata(mergedMetadata)
        let messageComponents = [
            timestamp,
            "\(level)",
            label,
            ":",
            metadataText,
            "[\(source)]",
            "\(message)"
        ]
        let finalMessage = messageComponents
            .compactMap { $0 }
            .joined(separator: " ")
        
        storage.append(.init(stringLiteral: finalMessage))
    }

    public subscript(metadataKey metadataKey: String) -> Logger.Metadata.Value? {
        get { metadata[metadataKey] }
        set { metadata[metadataKey] = newValue }
    }

    private func formattedMetadata(_ metadata: Logger.Metadata) -> String? {
        guard !metadata.isEmpty else { return nil }
        let elements = metadata.map { key, value in
            "\(key)=\(value)"
        }.sorted()
        return elements.joined(separator: " ")
    }

    private final class Storage: @unchecked Sendable {
        private var _messages: [Logger.Message] = []
        private let queue = DispatchQueue(
            label: "MemoryLogHandler.Storage.queue"
        )

        var messages: [Logger.Message] {
            queue.sync { _messages }
        }

        func append(_ message: Logger.Message) {
            queue.sync {
                _messages.append(message)
            }
        }
    }
}
