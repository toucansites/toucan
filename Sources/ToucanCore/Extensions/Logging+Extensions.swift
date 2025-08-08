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
        var logger = Logger(label: "toucan." + id)
        logger.logLevel = findEnvLogLevel(id) ?? findArgLogLevel(id) ?? level

        return logger
    }
}

private extension Logger {
    
    static func findEnvLogLevel(_ id: String) -> Logger.Level? {
        let env = ProcessInfo.processInfo.environment
        let subsystemLogLevelKey = id
            .uppercased()
            .replacingOccurrences(of: "-", with: "_")
            .appending("_LOG_LEVEL")
        let keys = [
            subsystemLogLevelKey,
            "LOG_LEVEL"
        ]
        
        for key in keys {
            if 
                let rawLevel = env[key]?.lowercased(),
                let level = Logger.Level(rawValue: rawLevel) 
            {
                return level
            }
        }
        
        return nil
    }

    static func findArgLogLevel(_ id: String) -> Logger.Level? {
        let arguments = ProcessInfo.processInfo.arguments
        let prefix = "--log-level="        

        if let rawLogLevel = arguments
            .first(where: { $0.hasPrefix(prefix) })?
            .replacingOccurrences(of: prefix, with: "")
        {
            return Logger.Level(rawValue: rawLogLevel)
        }
        
        return nil
    }
}
