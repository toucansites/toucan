//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 27/06/2024.
//

import Foundation
import FileManagerKit
import Yams


struct ConfigLoader {
    
    /// An enumeration representing possible errors that can occur while loading the configuration.
    enum Error: Swift.Error {
        case missing
        /// Indicates an error related to file operations.
        case file(Swift.Error)
        /// Indicates an error related to parsing YAML.
        case yaml(YamlError)
    }
    
    /// The URL of the source files.
    let sourceUrl: URL
    /// The file manager used for file operations.
    let fileManager: FileManager

    
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
                let rawYaml = try String(contentsOf: yamlConfigUrl)
                let rawYamlData = try Data(contentsOf: yamlConfigUrl)

                let yaml = try Yams.load(
                    yaml: String(rawYaml),
                    Resolver.default.removing(.timestamp)
                ) as? [String: Any] ?? [:]

                let decoder = YAMLDecoder()
                return try decoder.decode(Config.self, from: rawYamlData)
                
            }
            catch let error as YamlError {
                throw Error.yaml(error)
            }
            catch {
                throw Error.file(error)
            }
        }
        throw Error.missing
    }
}
