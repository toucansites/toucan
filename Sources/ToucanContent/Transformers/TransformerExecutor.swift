//
//  File.swift
//  toucan
//
//  Created by Viasz-Kádi Ferenc on 2024. 10. 15..
//

import Foundation
import SwiftCommand
import Logging

public struct TransformerExecutor {

    public var commandsUrl: URL
    public var pipeline: TransformerPipeline
    public var fileManager: FileManager
    public var logger: Logger

    public init(
        commandsURL: URL,
        pipeline: TransformerPipeline,
        fileManager: FileManager = .default,
        logger: Logger = .init(label: "TransformerExecutor")
    ) {
        self.commandsUrl = commandsURL
        self.pipeline = pipeline
        self.fileManager = fileManager
        self.logger = logger
    }

    public func transform(
        contents: String
    ) throws -> String {
        // Create a temporary directory URL
        let tempDirectoryURL = fileManager.temporaryDirectory
        let fileName = UUID().uuidString
        let fileURL = tempDirectoryURL.appendingPathComponent(fileName)
        try contents.write(to: fileURL, atomically: true, encoding: .utf8)

        for command in pipeline.commands {

            do {
                let command = commandsUrl.appendingPathComponent(command.name)
                //            let options = [
                //                "file": fileURL.path,
                //                "id": pageBundle.contextAwareIdentifier,
                //                "slug": pageBundle.slug,
                //            ]
                //            .map { #"--\#($0) "\#($1)""# }
                //            .joined(separator: " ")

                let log = try Command(executablePath: .init(command.path()))
                    //                .init(executablePath: )
                    //                .findInPath(withName: command.name)!
                    //                .setEnvVariables([:]])
                    .waitForOutput()

                if !log.stdout.isEmpty {
                    logger.debug("\(log)")
                }
                if let err = log.stderr, !err.isEmpty {
                    logger.error("\(err)")
                }
            }
            catch {
                logger.error("\(error))")
            }
        }

        let finalContents = try String(contentsOf: fileURL, encoding: .utf8)
        // TODO: also remove if error thrown
        try fileManager.removeItem(at: fileURL)
        return finalContents
    }
}
