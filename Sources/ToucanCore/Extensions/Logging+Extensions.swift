//
//  Logging+Extensions.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 18..
//

import class Foundation.ProcessInfo
import Logging

public extension Logger {
    static func subsystem(
        _ id: String,
        _ level: Logger.Level = .info
    ) -> Logger {
        var logger = Logger(label: id)

        logger.logLevel = level

        let env = ProcessInfo.processInfo.environment

        if let rawLevel = env["LOG_LEVEL"]?.lowercased(),
            let level = Logger.Level(rawValue: rawLevel)
        {
            logger.logLevel = level
        }

        let envKey =
            id
            .appending("-log-level")
            .replacingOccurrences(of: "-", with: "_")
            .uppercased()

        if let rawLevel = env[envKey]?.lowercased(),
            let level = Logger.Level(rawValue: rawLevel)
        {
            logger.logLevel = level
        }

        return logger
    }
}
