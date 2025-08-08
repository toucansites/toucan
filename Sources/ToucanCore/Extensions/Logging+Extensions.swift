//
//  Logging+Extensions.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 18..
//

import class Foundation.ProcessInfo
import Logging

public extension Logger {

    /// Returns a logger instance for the specified subsystem.
    ///
    /// Constructs a logger with a label based on the subsystem identifier and sets its log level.
    /// The log level is determined by checking environment variables
    /// for subsystem-specific or global log level settings. If none are found, the provided default level is used.
    ///
    /// - Parameters:
    ///   - id: The subsystem identifier (e.g., `"generate"`, `"object-loader"`).
    ///   - level: The default log level to use if not specified elsewhere. Defaults to `.info`.
    /// - Returns: A configured `Logger` instance for the subsystem.
    static func subsystem(
        _ id: String = "",
        _ level: Logger.Level = .info
    ) -> Logger {
        var logger = Logger(label: id.loggerLabel())
        logger.logLevel = findEnvLogLevel(id) ?? level

        return logger
    }
}

private extension Logger {
    
    /// Returns the log level from environment variables for the given subsystem identifier.
    ///
    /// Checks for a subsystem-specific log level key and a global log level key (`TOUCAN_LOG_LEVEL`)
    /// in the environment. If a valid log level string is found, it is converted to a `Logger.Level`.
    ///
    /// - Parameter id: The subsystem identifier.
    /// - Returns: The log level if found and valid, otherwise `nil`.
    static func findEnvLogLevel(_ id: String) -> Logger.Level? {
        let env = ProcessInfo.processInfo.environment
        let keys = [
            id.subsystemLogLevelKey(),
            "TOUCAN_LOG_LEVEL"
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
}

private extension String {

    /// Returns the logger label for a subsystem.
    ///
    /// Constructs a logger label by joining "TOUCAN" and the subsystem identifier with a hyphen.
    /// If the identifier is empty, returns "TOUCAN".
    ///
    /// - Examples:
    ///   - For an empty string: `"TOUCAN"`
    ///   - For `"generate"`: `"TOUCAN-generate"`
    ///   - For `"object-loader"`: `"TOUCAN-object-loader"`
    func loggerLabel() -> String {
        let prefix = "toucan"
        let parts = isEmpty ? [prefix] : [prefix, self]
        return parts.joined(separator: "-")
    }

    /// Returns the environment variable key for the log level of a subsystem.
    ///
    /// This method constructs a log level key by converting the logger label to uppercase,
    /// replacing hyphens with underscores, and appending "_LOG_LEVEL".
    ///
    /// - Examples:
    ///   - For an empty string: `"TOUCAN_LOG_LEVEL"`
    ///   - For `"generate"`: `"TOUCAN_GENERATE_LOG_LEVEL"`
    ///   - For `"object-loader"`: `"TOUCAN_OBJECT_LOADER_LOG_LEVEL"`
    func subsystemLogLevelKey() -> String {
        loggerLabel()
            .uppercased()
            .replacingOccurrences(of: "-", with: "_")
            .appending("_LOG_LEVEL")
    }
}