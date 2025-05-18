//
//  File.swift
//  toucan
//
//  Created by Tibor Bödecs on 2025. 05. 18..
//

import Logging

public protocol LoggerMetadataRepresentable {
    var logMetadata: [String: Logger.MetadataValue] { get }
}
