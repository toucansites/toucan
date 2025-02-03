//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 02. 03..
//

import ToucanModels

extension RenderPipeline {

    public struct ContentTypes: OptionSet {

        public static var single: Self { .init(rawValue: 1 << 0) }
        public static var bundle: Self { .init(rawValue: 1 << 1) }

        public static var all: Self { [single, bundle] }

        // MARK: -

        public let rawValue: UInt

        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }

        public init(stringValue: String) {
            switch stringValue.lowercased() {
            case "single":
                self = .single
            case "bundle":
                self = .bundle
            case "all":
                self = .all
            default:
                self = []
            }
        }
    }
}
