//
//  TransformerExecutor.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2024. 10. 15..
//

import Foundation
import SwiftCommand
import Logging
import ToucanModels
import FileManagerKit

public struct TransformerExecutor {

    public var pipeline: TransformerPipeline
    public var fileManager: FileManagerKit
    public var logger: Logger

    public init(
        pipeline: TransformerPipeline,
        fileManager: FileManagerKit,
        logger: Logger = .init(label: "TransformerExecutor")
    ) {
        self.pipeline = pipeline
        self.fileManager = fileManager
        self.logger = logger
    }

    public func transform(contents: String, slug: Slug) throws -> String {
        // Create a temporary directory URL
        let tempDirectoryURL = fileManager.temporaryDirectory
        let fileName = UUID().uuidString
        let fileURL = tempDirectoryURL.appendingPathComponent(fileName)
        try contents.write(to: fileURL, atomically: true, encoding: .utf8)

        for command in pipeline.run {
            do {
                let contextAwareIdentifier = slug.contextAwareIdentifier()
                let arguments: [String] = [
                    "--id", contextAwareIdentifier,
                    "--file", fileURL.path,
                    "--slug", slug.value,
                ]
                let commandUrl = URL(fileURLWithPath: command.url)
                    .appendingPathComponent(command.name)
                let command = Command(executablePath: .init(commandUrl.path()))
                    .addArguments(arguments)

                let result = try command.waitForOutput()

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

        do {
            let finalContents = try String(contentsOf: fileURL, encoding: .utf8)
            try fileManager.delete(at: fileURL)
            return finalContents
        }
        catch {
            try fileManager.delete(at: fileURL)
            throw error
        }
    }
}
