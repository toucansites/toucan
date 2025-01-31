//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 01. 31..
//

import Foundation

extension String {

    var baseName: String {
        URL(fileURLWithPath: self).deletingPathExtension().lastPathComponent
    }
}
