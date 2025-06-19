//
//  TransformerExecutor.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2024. 10. 15..
//

import Foundation
import Logging
import SwiftCommand

/// Executes a sequence of shell-based transformation commands defined in a `TransformerPipeline`,
/// allowing content to be programmatically modified.
public struct TransformerExecutor {
    /// The transformation pipeline consisting of commands to execute.
    public var pipeline: TransformerPipeline

    /// File manager utility for file system interactions, including temp files and cleanup.
    public var fileManager: FileManager

    /// Logger instance.
    public var logger: Logger

    // MARK: - Lifecycle

    /// Initializes a `TransformerExecutor` with a transformation pipeline and file manager.
    ///
    /// - Parameters:
    ///   - pipeline: A sequence of external commands to run for transformation.
    ///   - fileManager: A file manager abstraction for working with files.
    ///   - logger: A logger for capturing stdout, stderr, and errors.
    public init(
        pipeline: TransformerPipeline,
        fileManager: FileManager = .default,
        logger: Logger = .init(label: "TransformerExecutor")
    ) {
        self.pipeline = pipeline
        self.fileManager = fileManager
        self.logger = logger
    }

    // MARK: - Functions

    /// Transforms the given content string using the defined pipeline.
    ///
    /// This function:
    /// - Saves the content to a temporary file.
    /// - Executes each command in the pipeline sequentially, modifying the file in place.
    /// - Captures and logs output and errors.
    /// - Returns the final transformed content.
    ///
    /// - Parameters:
    ///   - contents: The raw content to be transformed.
    ///   - id: An identifier used to pass context to the commands.
    ///   - slug: The slug of the content.
    ///
    /// - Throws: Rethrows any error encountered during reading, writing, or transformation.
    /// - Returns: The final transformed content string.
    public func transform(
        contents: String,
        id: String,
        slug: String
    ) throws -> String {
        // Step 1: Write the content to a temp file
        let tempDirectoryURL = fileManager.temporaryDirectory
        let fileName = UUID().uuidString
        let fileURL = tempDirectoryURL.appendingPathComponent(fileName)
        try contents.write(to: fileURL, atomically: true, encoding: .utf8)

        // Step 2: Run each command in the transformation pipeline
        for command in pipeline.run {
            do {
                let arguments: [String] = [
                    "--id", id,
                    "--file", fileURL.path,
                    "--slug", slug,
                ]
                let commandURL = URL(fileURLWithPath: command.path)
                    .appendingPathComponent(command.name)

                let command = Command(executablePath: .init(commandURL.path()))
                    .addArguments(arguments)

                let result = try command.waitForOutput()

                // Log output and errors
                if !result.stdout.isEmpty {
                    logger.debug("\(result)")
                }
                if let err = result.stderr, !err.isEmpty {
                    logger.error("\(err)")
                }
            }
            catch {
                logger.error("\(error))")
            }
        }

        // Step 3: Read the transformed contents, clean up, and return
        do {
            let finalContents = try String(contentsOf: fileURL)
            try fileManager.removeItem(at: fileURL)
            return finalContents
        }
        catch {
            // Ensure cleanup is still performed
            try fileManager.removeItem(at: fileURL)
            throw error
        }
    }
}
