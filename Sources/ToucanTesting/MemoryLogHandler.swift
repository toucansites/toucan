//
//  MemoryLogHandler.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 04. 09..
//

import Logging
import Foundation

// MARK: - Logger Extension

extension Logger {

    /// Creates an in-memory logger for capturing log messages without printing or writing them to file.
    ///
    /// This is especially useful in unit testing or ephemeral environments where log output needs
    /// to be inspected programmatically.
    ///
    /// - Parameters:
    ///   - label: A string label for identifying the logger.
    ///   - logLevel: The minimum log level to capture. Defaults to `.trace`.
    /// - Returns: A tuple containing the configured `Logger` and the `MemoryLogHandler` to access messages.
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

// MARK: - MemoryLogHandler

/// A `LogHandler` that stores log messages in memory, rather than printing or writing to disk.
///
/// This is ideal for testing scenarios or lightweight diagnostics where you need
/// to inspect logs in a programmatic and non-persistent way.
public struct MemoryLogHandler: LogHandler {

    /// Minimum log level that will be stored. Defaults to `.info`.
    public var logLevel: Logger.Level = .info

    /// Static or dynamic metadata to be attached to each message.
    public var metadata: Logger.Metadata = [:]

    /// All captured log messages, in order of recording.
    public var messages: [Logger.Message] {
        storage.messages
    }

    private let label: String
    private let storage = Storage()

    /// Initializes a new in-memory log handler.
    ///
    /// - Parameter label: A unique identifier for the logger.
    public init(label: String) {
        self.label = label
    }

    /// Handles logging a message by formatting and storing it in memory.
    public func log(
        level: Logger.Level,
        message: Logger.Message,
        metadata metadataInput: Logger.Metadata?,
        source: String,
        file: String,
        function: String,
        line: UInt
    ) {
        let isoFormatter = ISO8601DateFormatter()
        let timestamp = isoFormatter.string(from: Date())

        let mergedMetadata = metadata.merging(metadataInput ?? [:]) { _, new in
            new
        }
        let metadataText = formattedMetadata(mergedMetadata)

        let messageComponents = [
            timestamp,
            "\(level)",
            label,
            ":",
            metadataText,
            "[\(source)]",
            "\(message)",
        ]

        let finalMessage =
            messageComponents
            .compactMap { $0 }
            .joined(separator: " ")

        storage.append(.init(stringLiteral: finalMessage))
    }

    /// Subscript for modifying metadata by key.
    public subscript(metadataKey metadataKey: String) -> Logger.Metadata.Value?
    {
        get { metadata[metadataKey] }
        set { metadata[metadataKey] = newValue }
    }

    // MARK: - Helpers

    private func formattedMetadata(_ metadata: Logger.Metadata) -> String? {
        guard !metadata.isEmpty else { return nil }
        let elements =
            metadata
            .map { key, value in "\(key)=\(value)" }
            .sorted()
        return elements.joined(separator: " ")
    }

    // MARK: - Thread-Safe Storage

    /// Thread-safe storage container for log messages.
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
