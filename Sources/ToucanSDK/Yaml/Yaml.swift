//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 23/07/2024.
//

import Yams
import FileManagerKit
import Foundation

public enum Yaml {

    static func parse(
        yaml: String
    ) throws -> [String: Any] {
        try parse(yaml: yaml, as: [String: Any].self) ?? [:]
    }

    static func parse<T>(
        yaml: String,
        as: T.Type
    ) throws -> T? {
        try Yams.load(
            yaml: yaml,
            Resolver.default.removing(.timestamp)
        ) as? T
    }

    static func load(
        at dirUrl: URL,
        name: String,
        extensions: [String] = ["yaml", "yml"],
        fileManager: FileManager = .default
    ) throws -> [String: Any] {
        let names = extensions.map { "\(name).\($0)" }
        var result: [String: Any] = [:]
        for name in names {
            let url = dirUrl.appendingPathComponent(name)
            guard fileManager.fileExists(at: url) else {
                continue
            }
            let yaml = try String(contentsOf: url, encoding: .utf8)
            if let data = try? parse(yaml: yaml) {
                result = result.recursivelyMerged(with: data)
            }
        }
        return result
    }

    static func load(
        at dirUrl: URL,
        name: String,
        extensions: [String] = ["yaml", "yml"],
        fileManager: FileManager = .default
    ) throws -> [[String: Any]] {
        let names = extensions.map { "\(name).\($0)" }
        var result: [[String: Any]] = []
        for name in names {
            let url = dirUrl.appendingPathComponent(name)
            guard fileManager.fileExists(at: url) else {
                continue
            }
            let yaml = try String(contentsOf: url, encoding: .utf8)
            if let data = try? parse(yaml: yaml, as: [[String: Any]].self) {
                result += data
            }
        }
        return result
    }

}
