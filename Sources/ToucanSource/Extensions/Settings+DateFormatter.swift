//
//  File.swift
//  toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 03. 26..
//

import Foundation
import ToucanModels

public extension Settings {
    
    func dateFormatter(_ dateFormat: LocalizedDateFormat) -> DateFormatter {
        let formatter = DateFormatter.default
        formatter.config(with: self)
        formatter.config(with: dateFormat)
        return formatter
    }
    
    func dateFormatter(_ format: String? = nil) -> DateFormatter {
        let formatter = DateFormatter.default
        formatter.config(with: self)
        if let format {
            formatter.dateFormat = format
        }
        return formatter
    }
}
