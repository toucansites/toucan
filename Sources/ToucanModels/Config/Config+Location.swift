//
//  Config+Location.swift
//  Toucan
//
//  Created by Tibor Bodecs on 2025. 02. 21..
//

extension Config {

    public struct Location: Codable, Equatable {
        public var path: String

        // MARK: - init

        public init(path: String) {
            self.path = path
        }
    }
}
