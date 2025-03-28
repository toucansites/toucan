//
//  File.swift
//  toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 03. 26..
//

import Foundation

extension DateFormatter.Mocks {

    public static func en_US(_ format: String? = nil) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = .init(identifier: "en_US")
        formatter.timeZone = .init(secondsFromGMT: 0)
        if let format {
            formatter.dateFormat = format
        }
        return formatter
    }
}
