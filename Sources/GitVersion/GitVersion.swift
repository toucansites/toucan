//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 01. 23..
//

import libgitversion

public func GitVersion() -> String {
    .init(cString: git_version())
}
