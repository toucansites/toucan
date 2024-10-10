//
//  File.swift
//
//
//  Created by Tibor Bodecs on 27/06/2024.
//

import Foundation
import FileManagerKit
import Yams
import Logging


public struct ConfigLoader {

    /// An enumeration representing possible errors that can occur while loading the configuration.
    public enum Error: Swift.Error {
        case missing(URL)
        /// Indicates an error related to file operations.
        case file(Swift.Error)
        /// Indicates an error related to parsing YAML.
        case yaml(YamlError)
    }

    /// The URL of the source files.
    let sourceUrl: URL
    /// The file manager used for file operations.
    let fileManager: FileManager
    /// The base URL to use for the configuration.
    let baseUrl: String?
    /// The logger instance
    let logger: Logger

    /// Loads the configuration.
    ///
    /// - Returns: A `Config` object.
    /// - Throws: An error if the configuration fails to load.
    func load() throws -> Config {
        let configUrl = sourceUrl.appendingPathComponent("config")

        let yamlConfigUrls = [
            configUrl.appendingPathExtension("yaml"),
            configUrl.appendingPathExtension("yml"),
        ]
        for yamlConfigUrl in yamlConfigUrls {
            guard fileManager.fileExists(at: yamlConfigUrl) else {
                continue
            }
            do {
                logger.debug(
                    "Loading config file: `\(yamlConfigUrl.absoluteString)`."
                )
                let rawYaml = try String(
                    contentsOf: yamlConfigUrl,
                    encoding: .utf8
                )
                let dict = try Yams.load(yaml: rawYaml) as? [String: Any] ?? [:]
                return .init(dict)
            }
            catch let error as YamlError {
                throw Error.yaml(error)
            }
            catch {
                throw Error.file(error)
            }
        }
        throw Error.missing(sourceUrl)
    }

}
